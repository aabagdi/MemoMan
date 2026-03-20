//
//  SFSpeechRecognizer++.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import Foundation
@preconcurrency import Speech

extension SFSpeechRecognizer {
   static func hasAuthorizationToRecognize() async -> Bool {
      await withCheckedContinuation { continuation in
         requestAuthorization { status in
            continuation.resume(returning: status == .authorized)
         }
      }
   }
   
   func results(for request: SFSpeechURLRecognitionRequest) -> AsyncThrowingStream<TranscriptionResult, Error> {
      AsyncThrowingStream { continuation in
         let task = self.recognitionTask(with: request) { result, error in
            if let error {
               let nsError = error as NSError
               if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1110 {
                  continuation.finish(throwing: Errors.NoSpeechDetected)
               } else {
                  continuation.finish(throwing: error)
               }
            } else if let result {
               let transcriptionResult = TranscriptionResult(
                  transcription: result.bestTranscription.formattedString,
                  isFinal: result.isFinal
               )
               continuation.yield(transcriptionResult)
               if result.isFinal {
                  continuation.finish()
               }
            }
         }
         
         continuation.onTermination = { @Sendable _ in
            task.cancel()
         }
      }
   }
}
