//
//  RecordModel.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/1/23.
//

import Foundation
import SwiftUI
import Speech

extension RecordView {
    @MainActor
    @Observable
    class RecordViewModel {
        var isRecording : Bool = false
        var fadeInOut : Bool = false
        var showFiles : Bool = false
        var showSettings : Bool = false
        var showAlert : Bool = false
        var animationAmount : Double = 1.0
    }
}
