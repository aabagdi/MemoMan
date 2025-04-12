//
//  RecordModel.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/1/23.
//

import Foundation
import SwiftUI

extension RecordView {
  @Observable
  @MainActor
  final class RecordViewModel {
    var isRecording : Bool = false
    var fadeInOut : Bool = false
    var showFiles : Bool = false
    var showSettings : Bool = false
    var showAlert : Bool = false
    var animationAmount : CGFloat = 1.0
  }
}
