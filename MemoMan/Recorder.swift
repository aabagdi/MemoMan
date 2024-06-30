import Foundation
import AVFoundation
import SwiftData

class Recorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder!
    private var currentURL: URL?
    private var recording: Recording?
    
    func record() throws {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timestamp = dateFormatter.string(from: date)
        self.recording = Recording(name: timestamp)
        let fileURL = documentsDirectory.appendingPathComponent("\(recording?.name ?? "").m4a")
        print("File URL: \(fileURL)")
        self.currentURL = fileURL
        
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session: \(error)")
            throw Errors.FailedToInitSessionError
        }
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: currentURL!, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print("Failed to start recording: \(error)")
            throw Errors.FailedToRecordError
        }
    }
    
    func stop(modelContext: ModelContext) {
        audioRecorder.stop()
        saveRecording(modelContext: modelContext)
    }
    
    private func saveRecording(modelContext: ModelContext) {
        let newRecording = recording
        
        do {
            modelContext.insert(newRecording!)
            try modelContext.save()
            //print("Recording saved successfully at URL: \(url.path)")
        } catch {
            //print("Failed to save recording: \(error)")
        }
    }
}
