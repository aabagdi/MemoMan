//
//  SpeechRecognizer.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import Foundation
import Speech

actor SpeechRecognizer : ObservableObject {
    let recognizer : SFSpeechRecognizer?
    
    init(recording: Recording) {
        self.recognizer = SFSpeechRecognizer()
        guard recognizer != nil else {
            return
        }
        
        Task {
            do {
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw Errors.NotAuthorizedToRecognize
                }
            } catch {
                print("Error")
            }
        }
    }
    
    func transcribe(recording: Recording) {
        let url = recording.fileURL
        let request = SFSpeechURLRecognitionRequest(url: url)
        recognizer?.recognitionTask(with: request) { (result, error) in
            guard let result = result else {
                print("No speech detected")
                return
            }
            if result.isFinal {
                recording.transcript = result.bestTranscription.formattedString
                print(result.bestTranscription.formattedString)
            }
        }
    }
    
    
}
