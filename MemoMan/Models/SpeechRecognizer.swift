//
//  SpeechRecognizer.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import Foundation
import Speech
import SwiftData
import SwiftUI

@MainActor
@Observable
class SpeechRecognizer {
    let recognizer : SFSpeechRecognizer?
    let modelContext : ModelContext
    var transcription : String = "No transcription available. Either it's still loading or no speech was detected."
    
    init(modelContainer: ModelContainer) {
        self.recognizer = SFSpeechRecognizer()
        self.modelContext = ModelContext(modelContainer)
    }
    
    func transcribe(recordingID: PersistentIdentifier) async {
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
        if let recording = modelContext.model(for: recordingID) as? Recording {
            let url = recording.fileURL
            let request = SFSpeechURLRecognitionRequest(url: url)
            
            await withCheckedContinuation { continuation in
                var didResume = false
                
                recognizer.recognitionTask(with: request) { (result, error) in
                    if let error {
                        print("Recognition error: \(error)")
                        if !didResume {
                            continuation.resume()
                            didResume = true
                        }
                        return
                    }
                    
                    guard let result else {
                        print("No speech detected")
                        if !didResume {
                            continuation.resume()
                            didResume = true
                        }
                        return
                    }
                    
                    if result.isFinal {
                        self.transcription = result.bestTranscription.formattedString
                        if !didResume {
                            continuation.resume()
                            didResume = true
                        }
                    }
                }
            }
        }
    }
}
