//
//  TranscriptionButtonView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct TranscriptionButtonView : View {
    var modelID : PersistentIdentifier
    @State private var showTranscription : Bool = false
    @State private var showCopyAlert : Bool = false
    @StateObject private var recognizer : SpeechRecognizer
    
    init(modelContainer: ModelContainer, modelID: PersistentIdentifier) {
        self.modelID = modelID
        self._recognizer = StateObject(wrappedValue: SpeechRecognizer(modelContainer: modelContainer))
        
    }
    
    var body: some View {
        Button("Recording transcript") {
            showTranscription.toggle()
        }
        .buttonStyle(PurpleButtonStyle())
        .sheet(isPresented: $showTranscription) {
            VStack {
                Text("Transcription")
                    .font(.headline)
                    .padding()
                ScrollView {
                    Text(recognizer.transcription)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity)
                }
                VStack {
                    Button("Cancel") {
                        showTranscription.toggle()
                    }
                    .buttonStyle(PurpleButtonStyle())
                    Button("Copy transcript") {
                        if recognizer.transcription != "No transcription available. Either it's still loading or no speech was detected." {
                            copy()
                            showTranscription.toggle()
                        } else {
                            showCopyAlert.toggle()
                        }
                    }
                    .buttonStyle(PurpleButtonStyle())
                    .alert("No transcription available to copy!", isPresented: $showCopyAlert) {
                        Button("OK", role: .cancel) { showTranscription.toggle() }
                    }
                }
            }
        }
        .task {
            await recognizer.transcribe(recordingID: modelID)
        }
    }
    
    func copy() {
        UIPasteboard.general.setValue(self.recognizer.transcription, forPasteboardType: UTType.plainText.identifier)
        return
    }
    
}
