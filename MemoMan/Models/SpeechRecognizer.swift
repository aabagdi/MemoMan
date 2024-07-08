//
//  SpeechRecognizer.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import Foundation
import Speech

actor SpeechRecognizer : ObservableObject {
    let recognizer: SFSpeechRecognizer?
    
    init() {
        self.recognizer = SFSpeechRecognizer()
    }
    
    func transcribe(recording: Recording) async {
        guard let recognizer = recognizer else {
            print("Recognizer not available")
            return
        }
        
        do {
            guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                throw Errors.NotAuthorizedToRecognize
            }
        } catch {
            print("Authorization error: \(error)")
            return
        }
        
        let url = recording.fileURL
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = true
        
        await withCheckedContinuation { continuation in
            recognizer.recognitionTask(with: request) { (result, error) in
                if let error = error {
                    print("Recognition error: \(error)")
                    continuation.resume()
                    return
                }
                
                guard let result = result else {
                    print("No speech detected")
                    continuation.resume()
                    return
                }
                
                if result.isFinal {
                    recording.transcript = result.bestTranscription.formattedString
                    print(result.bestTranscription.formattedString)
                    continuation.resume()
                }
            }
        }
    }
}

func transcribeRecordings(recordings: [Recording], recognizer: SpeechRecognizer) async {
    await withTaskGroup(of: Void.self) { taskGroup in
        for recording in recordings {
            if recording.transcript == nil {
                taskGroup.addTask {
                    await recognizer.transcribe(recording: recording)
                }
            }
        }
    }
}
