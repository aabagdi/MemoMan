//
//  Components.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 3/29/24.
//

import Foundation

enum Errors: Error {
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
}
