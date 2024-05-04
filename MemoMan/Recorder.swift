//
//  Recorder.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/1/23.
//

import Foundation
import AVFoundation

@MainActor
class Recorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder!

    
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
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
        } catch {
            throw Errors.FailedToRecordError
        }
    }
    
    func stop() {
        audioRecorder.stop()
    }
    
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}
