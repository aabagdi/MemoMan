import Foundation
import UIKit
import AVFoundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class Recorder: NSObject, @preconcurrency AVAudioRecorderDelegate {
    // MARK: - Properties
    var startTime : Date?
    private var audioRecorder : AVAudioRecorder!
    private var currentURL : URL?
    private var recording : Recording?
    private var meteringWorkItem : DispatchWorkItem?

    var avgPower : Float = 0.0
    
    private var isStereoSupported : Bool = false {
        didSet {
            try? setupAudioRecorder()
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        do {
            try configureAudioSession()
            try enableMicrophone()
            try setupAudioRecorder()
        } catch {
            // If any errors occur during initialization,
            // terminate the app with a fatalError.
            fatalError("Error: \(error)")
        }
    }
    
    // MARK: - Audio Session and Recorder Configuration
    
    private func enableMicrophone() throws {
        let audioSession = AVAudioSession.sharedInstance()
        let portName = UserDefaults.standard.string(forKey: "inputSource") ?? "iPhone Microphone"
        let preferredInput = getAVAudioPortDescription(portName: portName)
        
        do {
            try audioSession.setPreferredInput(preferredInput)
        } catch {
            throw Errors.UnableToSetMicrophone
        }
    }
    
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [.allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            throw Errors.FailedToInitSessionError
        }
    }
    
    private func setupAudioRecorder() throws {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
        let timestamp = dateFormatter.string(from: date)
        self.recording = Recording(name: timestamp)
        
        guard let fileURL = recording?.fileURL else {
            fatalError("Failed to create file URL")
        }
        self.currentURL = fileURL
        
        do {
            let audioSettings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: UserDefaults.standard.double(forKey: "sampleRate"),
                AVNumberOfChannelsKey: isStereoSupported ? 2 : 1,
                AVEncoderAudioQualityKey: UserDefaults.standard.integer(forKey: "audioQuality")
            ]
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: audioSettings)
            audioRecorder.isMeteringEnabled = true
        } catch {
            throw Errors.UnableToCreateAudioRecorder
        }
        
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
    }
    
    // MARK: recording controls
    func record() throws {
        try configureAudioSession()
        try setupAudioRecorder()
        guard audioRecorder != nil else {
            fatalError("Audio Recorder is not initialized")
        }
        startTime = Date()
        audioRecorder.record()
        startMetering()
    }
    
    func stop(modelContext: ModelContext) {
        guard audioRecorder != nil else {
            fatalError("Audio Recorder is not initialized")
        }
        audioRecorder.stop()
        stopMetering()
        saveRecording(modelContext: modelContext)
    }
    
    //MARK: update orientation
    public func updateOrientation(deviceOrientation: UIDeviceOrientation) async throws {
        let session = AVAudioSession.sharedInstance()
        guard let preferredInput = session.preferredInput ?? session.availableInputs?.first,
              let dataSources = preferredInput.dataSources else {
            throw Errors.UnableToUpdateOrientation
        }
        
        let microphoneOrientation = deviceOrientation.microphoneOrientation
        
        // Try to find the exact match first, then fall back to other orientations
        let newDataSource = dataSources.first { $0.orientation == microphoneOrientation }
            ?? dataSources.first { $0.orientation == .front }
            ?? dataSources.first { $0.orientation == .back }
            ?? dataSources.first { $0.orientation == .bottom }
            ?? dataSources.first
        
        guard let newDataSource,
              let supportedPolarPatterns = newDataSource.supportedPolarPatterns else {
            throw Errors.UnableToUpdateOrientation
        }
        
        isStereoSupported = supportedPolarPatterns.contains(.stereo)
        if isStereoSupported {
            try newDataSource.setPreferredPolarPattern(.stereo)
        } else {
            try newDataSource.setPreferredPolarPattern(.omnidirectional)
        }
        
        try preferredInput.setPreferredDataSource(newDataSource)
        
        let inputOrientation = deviceOrientation.inputOrientation
        try session.setPreferredInputOrientation(inputOrientation)
    }
    
    //MARK: Audio metering
    private func startMetering() {
        stopMetering()
        meteringWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.updateMeters()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: self.meteringWorkItem!)
        }
        DispatchQueue.main.async(execute: meteringWorkItem!)
    }
    
    private func stopMetering() {
        meteringWorkItem?.cancel()
        meteringWorkItem = nil
    }
    
    func updateMeters() {
        audioRecorder.updateMeters()
        if isStereoSupported {
            let averagePower = max(audioRecorder.averagePower(forChannel: 0), audioRecorder.averagePower(forChannel: 1))
            self.avgPower = pow(10, (0.05 * averagePower))
        }
        else {
            let averagePower = audioRecorder.averagePower(forChannel: 0)
            self.avgPower = pow(10, (0.05 * averagePower))
        }
    }
    
    
    //MARK: save recording functions
    private func saveRecording(modelContext: ModelContext) {
        guard let newRecording = recording else {
            return
        }
        
        do {
            modelContext.insert(newRecording)
            try modelContext.save()
        } catch {
            print("Failed to save recording: \(error)")
        }
    }
    
    //MARK: Audio input functions
    private func getAVAudioPortDescription(portName: String) -> AVAudioSessionPortDescription? {
        let session = AVAudioSession.sharedInstance()
        let inputList = session.availableInputs ?? []
        for input in inputList {
            if input.portName == portName {
                return input
            }
        }
        return nil
    }
    
    
    //MARK: Audio delegate functions
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            print("Recording finished.")
        } else {
            print("Recording failed.")
        }
        self.recording = nil
    }
}
