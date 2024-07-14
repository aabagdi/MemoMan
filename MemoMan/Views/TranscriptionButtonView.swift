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
        Button("Transcript") {
            showTranscription.toggle()
        }
        .buttonStyle(PurpleButtonStyle())
        .sheet(isPresented: $showTranscription) {
            VStack {
                Text("Transcript")
                    .font(.headline)
                    .padding()
                TextEditor(text: .constant(recognizer.transcription))
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("MemoManPurple"))
                            .padding()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                /*ScrollView {
                    Text(recognizer.transcription)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity)
                }*/
                VStack {
                    Button("Copy transcript") {
                        if recognizer.transcription != "No transcription available. Either it's still loading or no speech was detected." {
                            copy()
                            showTranscription.toggle()
                        } else {
                            showCopyAlert.toggle()
                        }
                    }
                    .buttonStyle(PurpleButtonStyle())
                    .padding()
                    .alert("No transcription available to copy!", isPresented: $showCopyAlert) {
                        Button("OK", role: .cancel) { showTranscription.toggle() }
                    }
                    Button("Cancel") {
                        showTranscription.toggle()
                    }
                    .padding()
                    .buttonStyle(PurpleButtonStyle())
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
