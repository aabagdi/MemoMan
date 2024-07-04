import Foundation
import UIKit
import AVFoundation
import SwiftData

class Recorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    // MARK: - Properties
    private var audioRecorder: AVAudioRecorder!
    private var currentURL: URL?
    private var recording: Recording?
    private var meteringWorkItem: DispatchWorkItem?

    @Published var avgPower : Float = 0.0
    
    private var isStereoSupported: Bool = false {
        didSet {
            try? setupAudioRecorder()
        }
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        do {
            try configureAudioSession()
            try enableBuiltInMicrophone()
            try setupAudioRecorder()
        } catch {
            // If any errors occur during initialization,
            // terminate the app with a fatalError.
            fatalError("Error: \(error)")
        }
    }
    
    // MARK: - Audio Session and Recorder Configuration
    
    private func enableBuiltInMicrophone() throws {
        let audioSession = AVAudioSession.sharedInstance()
        let availableInputs = audioSession.availableInputs
        
        guard let builtInMicInput = availableInputs?.first(where: { $0.portType == .builtInMic }) else {
            throw Errors.NoBuiltInMic
        }
        
        do {
            try audioSession.setPreferredInput(builtInMicInput)
        } catch {
            throw Errors.UnableToSetBuiltInMicrophone
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
        print("Recording URL: \(fileURL)")
        
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
        print("Starting recording...")
        audioRecorder.record()
        startMetering()
    }
    
    func stop(modelContext: ModelContext) {
        guard audioRecorder != nil else {
            fatalError("Audio Recorder is not initialized")
        }
        audioRecorder.stop()
        stopMetering()
        print("Stopping recording...")
        saveRecording(modelContext: modelContext)
    }
    
    //MARK: update orientation
    public func updateOrientation(withDataSourceOrientation orientation: AVAudioSession.Orientation = .front, interfaceOrientation: UIInterfaceOrientation) async throws {
        let session = AVAudioSession.sharedInstance()
        guard let preferredInput = session.preferredInput ?? session.availableInputs?.first,
              let dataSources = preferredInput.dataSources,
              let newDataSource = dataSources.first(where: { $0.orientation == orientation }),
              let supportedPolarPatterns = newDataSource.supportedPolarPatterns else {
            return
        }
        isStereoSupported = supportedPolarPatterns.contains(.stereo)
        if isStereoSupported {
            try newDataSource.setPreferredPolarPattern(.stereo)
        }
        try preferredInput.setPreferredDataSource(newDataSource)
        try session.setPreferredInputOrientation(interfaceOrientation.inputOrientation)
    }
    
    //MARK: Audio metering
    private func startMetering() {
        stopMetering()
        meteringWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
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
        let averagePower = audioRecorder.averagePower(forChannel: 0)
        self.avgPower = pow(10, (0.05 * averagePower))
    }
    
    
    //MARK: save recording functions
    private func saveRecording(modelContext: ModelContext) {
        guard let newRecording = recording else {
            print("Recording is nil")
            return
        }
        
        do {
            modelContext.insert(newRecording)
            try modelContext.save()
            print("Recording saved: \(newRecording.name ?? "")")
        } catch {
            print("Failed to save recording: \(error)")
        }
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
