//
//  RecordModel.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/1/23.
//

import Foundation
import SwiftUI

extension RecordView {
    class RecordModel : ObservableObject {
        @Published var isRecording : Bool = false
        @Published var fadeInOut : Bool = false
        @Published var showFiles : Bool = false
        @Published var animationAmount : Double = 1.0
    }
}
