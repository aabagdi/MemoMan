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
    
    func transcribe(recordingID: PersistentIdentifier) async throws {
        guard let recognizer else {
            throw Errors.NilSpeechRecognizer
        }
        
        guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
            throw Errors.NotAuthorizedToRecognize
        }
        
        guard let recording = modelContext.model(for: recordingID) as? Recording else {
            throw Errors.InvalidRecording
        }
        
        let url = recording.fileURL
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        for try await result in recognizer.results(for: request) {
            transcription = result.transcription.isEmpty ? "No transcription available. Either it's still loading or no speech was detected." : result.transcription
            if result.isFinal {
                break
            }
        }
    }
}
