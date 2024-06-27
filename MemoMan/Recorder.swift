//
//  Recorder.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/1/23.
//

import Foundation
import AVFoundation
import SwiftData
import SwiftUI

class Recorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Environment(\.modelContext) var modelContext
    private var audioRecorder: AVAudioRecorder!
    private var currentURL: URL?
    
    func record() throws {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a, MMM d yyyy"
        
        // The user grants access. Present recording interface.
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            throw Errors.FailedToInitSessionError
        }
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = path.appendingPathComponent("\(dateFormatter.string(from: date)).m4a")
        currentURL = fileName
        
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
    
    func stop() {
        audioRecorder.stop()
    }
    
    private func saveRecording(with fileURL: URL) {
        let now = Date.now
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let recordingName = formatter.string(from: now)
        
        let newRecording = Recording(name: recordingName, url: fileURL)
        
        do {
            modelContext.insert(newRecording)
            try modelContext.save()
            print("Recording saved successfully")
        } catch {
            print("Failed to save recording: \(error)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag, let fileName = currentURL {
            saveRecording(with: fileName)
            print("Recording saved")
        } else {
            print("Recording failed")
        }
    }
}
