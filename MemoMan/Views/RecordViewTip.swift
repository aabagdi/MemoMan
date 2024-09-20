//
//  RecordingViewTip.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 9/20/24.
//

import Foundation
import TipKit

struct RecordViewTip: Tip {
    var title: Text {
        Text("Welcome!")
    }
    
    var message: Text? {
        Text("To start recording, hold or double-tap the record button!")
    }
    
    var image: Image? {
        Image(systemName: "mic.fill")
    }
}
