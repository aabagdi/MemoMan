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
   @State private var showErrorAlert = false
   @State private var currentError : Errors?
   @State private var recognizer : SpeechRecognizer
   
   @AppStorage("hasUserSeenTranscriptionAlert") var hasUserSeenTranscriptionAlert = false
   
   var presentNoSpeechAlert: Binding<Bool> {
      Binding<Bool>(
         get: { showErrorAlert && !hasUserSeenTranscriptionAlert && currentError == .NoSpeechDetected },
         set: { _ in }
      )
   }
   
   init(modelContext: ModelContext, modelID: PersistentIdentifier) throws {
      self.modelID = modelID
      guard let recognizer = try? SpeechRecognizer(modelContext: modelContext) else {
         throw Errors.NilSpeechRecognizer
      }
      _recognizer = State(wrappedValue: recognizer)
   }
   
   var body: some View {
      Button("Transcript") {
         showTranscription.toggle()
      }
      .buttonStyle(PurpleButtonStyle())
      .accessibilityLabel("View transcript")
      .accessibilityHint("Shows the speech transcription for this recording")
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
      .alert("Error", isPresented: presentNoSpeechAlert) {
         Button("OK", role: .cancel) { hasUserSeenTranscriptionAlert = true }
      } message: {
         Text(currentError?.localizedDescription ?? "An unknown error occurred.")
      }
      .task {
         do {
            try await recognizer.transcribe(recordingID: modelID)
         } catch let error as Errors {
            currentError = error
            showErrorAlert = true
         } catch {
            currentError = nil
            showErrorAlert = true
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
            .accessibilityAddTraits(.isHeader)
         TextEditor(text: .constant(transcription))
            .padding()
            .overlay {
               RoundedRectangle(cornerRadius: 10)
                  .stroke(Color.gray)
                  .padding()
            }
            .accessibilityLabel("Transcription text")
            .accessibilityValue(transcription)
         HStack {
            Button("Cancel", action: onDismiss)
               .buttonStyle(PurpleButtonStyle())
               .accessibilityLabel("Close transcript")
            Button("Copy", action: onCopy)
               .buttonStyle(PurpleButtonStyle())
               .accessibilityLabel("Copy transcript to clipboard")
         }
         .padding()
      }
   }
}
