//
//  Components.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 3/29/24.
//

import Foundation

enum Errors: Error, LocalizedError {
   case AudioProcessingError
   case FailedToInitPlayer
   case FailedToInitSessionError
   case FailedToPlayURL
   case FailedToRecordError
   case FileDeletionError
   case FileRenameError
   case InvalidModelContainer
   case InvalidModelContext
   case InvalidRecording
   case InvalidViewModel
   case NilPlayer
   case NilSpeechRecognizer
   case NotAuthorizedToRecord
   case NotAuthorizedToRecognize
   case SaveFailed
   case UnableToCreateAudioRecorder
   case UnableToSelectDataSource
   case UnableToSetMicrophone
   case UnableToUpdateOrientation

   var errorDescription: String? {
      switch self {
      case .AudioProcessingError:
         "Unable to process the audio file. The file may be corrupted."
      case .FailedToInitPlayer:
         "Unable to load the audio player. Please try again."
      case .FailedToInitSessionError:
         "Unable to start the audio session. Please restart the app."
      case .FailedToPlayURL:
         "Unable to play this recording. The file may be missing."
      case .FailedToRecordError:
         "Unable to start recording. Please check your microphone."
      case .FileDeletionError:
         "Unable to delete the recording. Please try again."
      case .FileRenameError:
         "Unable to rename the recording. Please try again."
      case .InvalidModelContainer:
         "A data error occurred. Please restart the app."
      case .InvalidModelContext:
         "A data error occurred. Please restart the app."
      case .InvalidRecording:
         "This recording could not be found."
      case .InvalidViewModel:
         "An internal error occurred. Please restart the app."
      case .NilPlayer:
         "The audio player is unavailable. Please try again."
      case .NilSpeechRecognizer:
         "Speech recognition is not available on this device."
      case .NotAuthorizedToRecord:
         "Microphone access is required. You can enable it in Settings > Privacy & Security."
      case .NotAuthorizedToRecognize:
         "Speech recognition permission is required. You can enable it in Settings > Privacy & Security."
      case .SaveFailed:
         "Unable to save the recording. Please try again."
      case .UnableToCreateAudioRecorder:
         "Unable to set up the recorder. Please restart the app."
      case .UnableToSelectDataSource:
         "Unable to select the audio input source."
      case .UnableToSetMicrophone:
         "Unable to configure the microphone."
      case .UnableToUpdateOrientation:
         "Unable to update the microphone orientation."
      }
   }
}
