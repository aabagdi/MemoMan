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
                        self.transcription = result.bestTranscription.formattedString
                        continuation.resume()
                    }
                }
            }
        }
    }
}
