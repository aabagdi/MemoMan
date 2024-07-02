import Foundation
import AVFoundation
import SwiftData
import UIKit

class Recorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    // MARK: - Properties
    private var audioRecorder: AVAudioRecorder!
    private var currentURL: URL?
    private var recording: Recording?
    
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
        // Get the instance of audio session.
        let audioSession = AVAudioSession.sharedInstance()

        // Get the audio inputs.
        let availableInputs = audioSession.availableInputs
        
        // Find the available input that corresponds to the built-in microphone.
        guard let builtInMicInput = availableInputs?.first(where: { $0.portType == .builtInMic }) else {
            // If no built-in microphone is found, throw an error.
            throw Errors.NoBuiltInMic
        }
        
        do {
            // Set the built-in microphone as the preferred input.
            try audioSession.setPreferredInput(builtInMicInput)
        } catch {
            // If an error occurs while setting the preferred input, throw an appropriate error.
            throw Errors.UnableToSetBuiltInMicrophone
        }
    }
    
    private func configureAudioSession() throws {
        do {
            // Get the instance of audio session.
            let audioSession = AVAudioSession.sharedInstance()
            
            // Set the audio session category to record.
            try audioSession.setCategory(.record, mode: .default)
            
            // Activate the audio session.
            try audioSession.setActive(true)
        } catch {
            // If an error occurs during configuration, throw an appropriate error.
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
        let fileURL = recording?.returnURL()
        self.currentURL = fileURL
        
        do {
            let audioSettings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVLinearPCMIsNonInterleaved: false,
                AVSampleRateKey: 44_100.0,
                AVNumberOfChannelsKey: isStereoSupported ? 2 : 1,
                AVLinearPCMBitDepthKey: 16,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
            audioRecorder = try AVAudioRecorder(url: fileURL!, settings: audioSettings)
        } catch {
            throw Errors.UnableToCreateAudioRecorder
        }
        
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
    }
    
    // MARK: recording controls
    func record() throws {
        audioRecorder.record()
    }
    
    func stop(modelContext: ModelContext) {
        audioRecorder.stop()
        saveRecording(modelContext: modelContext)
    }
    
    
    //MARK: update orientation
    public func updateOrientation(withDataSourceOrientation orientation: AVAudioSession.Orientation = .front, interfaceOrientation: UIInterfaceOrientation) async throws {
        // Get the shared audio session.
        let session = AVAudioSession.sharedInstance()

        // Find the data source matching the specified orientation.
        guard let preferredInput = session.preferredInput,
              let dataSources = preferredInput.dataSources,
              let newDataSource = dataSources.first(where: { $0.orientation == orientation }),
              let supportedPolarPatterns = newDataSource.supportedPolarPatterns else {
            return
        }

        do {
            // Check for iOS 14.0 availability to handle stereo support.
            if #available(iOS 14.0, *) {
                isStereoSupported = supportedPolarPatterns.contains(.stereo)

                // Set the preferred polar pattern to stereo if supported.
                if isStereoSupported {
                    try newDataSource.setPreferredPolarPattern(.stereo)
                }
            }

            // Set the preferred data source.
            try preferredInput.setPreferredDataSource(newDataSource)

            // Set the preferred input orientation based on the interface orientation.
            if #available(iOS 14.0, *) {
                try session.setPreferredInputOrientation(interfaceOrientation.inputOrientation)
            }
        } catch {
            throw Errors.UnableToSelectDataSource
        }
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
        } catch {
            print("Failed to save recording: \(error)")
        }
        self.recording = nil
    }
}
