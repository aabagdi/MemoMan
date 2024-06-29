//
//  Recorder.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/1/23.
//

import Foundation
import AVFoundation
import SwiftData

class Recorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder!
    private var currentURL: URL?
    
    func record() throws {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.record, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            throw Errors.FailedToInitSessionError
        }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("\(dateFormatter.string(from: date)).m4a")
        currentURL = fileName
        print("Recording will be saved to: \(fileName.path)")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            throw Errors.FailedToRecordError
        }
    }
    
    func stop(modelContext: ModelContext) {
        audioRecorder.stop()
        saveRecording(modelContext: modelContext)
    }
    
    private func saveRecording(modelContext: ModelContext) {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
        let recordingName = dateFormatter.string(from: now)
        
        guard let url = currentURL else {
            print("Current URL is nil")
            return
        }
        
        let newRecording = Recording(name: recordingName, url: url)
        
        do {
            modelContext.insert(newRecording)
            try modelContext.save()
            print("Recording saved successfully at URL: \(url.path)")
        } catch {
            print("Failed to save recording: \(error)")
        }
    }
}
