//
//  TranscriptionButtonView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct TranscriptionButtonView: View {
  let modelID : PersistentIdentifier
  @State private var showTranscription = false
  @State private var showCopyAlert = false
  @State private var showNoCopyAlert = false
  @State private var recognizer : SpeechRecognizer
  
  init(modelContainer: ModelContainer?, modelID: PersistentIdentifier) throws {
    self.modelID = modelID
    guard let recognizer = try? SpeechRecognizer(modelContainer: modelContainer) else {
      throw Errors.NilSpeechRecognizer
    }
    _recognizer = State(wrappedValue: recognizer)
  }
  
  var body: some View {
    Button("Transcript") {
      showTranscription.toggle()
    }
    .buttonStyle(PurpleButtonStyle())
    .fullScreenCover(isPresented: $showTranscription) {
      TranscriptionView(
        transcription: recognizer.transcription,
        onDismiss: { showTranscription = false },
        onCopy: copyTranscription
      )
    }
    .alert("Transcript copied to clipboard!", isPresented: $showCopyAlert) {
      Button("OK", role: .cancel) { }
    }
    .alert("No transcription available to copy!", isPresented: $showNoCopyAlert) {
      Button("OK", role: .cancel) { }
    }
    .task {
      do {
        try await recognizer.transcribe(recordingID: modelID)
      } catch {
        print(error.localizedDescription)
      }
    }
  }
  
  private func copyTranscription() {
    let noTranscriptionMessage = "No transcription available. Either it's still loading or no speech was detected."
    
    if recognizer.transcription != noTranscriptionMessage {
      UIPasteboard.general.string = recognizer.transcription
      showCopyAlert = true
      showTranscription = false
    } else {
      showNoCopyAlert = true
    }
  }
}

struct TranscriptionView: View {
  let transcription: String
  let onDismiss: () -> Void
  let onCopy: () -> Void
  
  var body: some View {
    VStack {
      Text("Transcript")
        .font(.headline)
        .padding()
      TextEditor(text: .constant(transcription))
        .padding()
        .overlay {
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color.gray)
            .padding()
        }
      HStack {
        Button("Cancel", action: onDismiss)
          .buttonStyle(PurpleButtonStyle())
        Button("Copy", action: onCopy)
          .buttonStyle(PurpleButtonStyle())
      }
      .padding()
    }
  }
}
