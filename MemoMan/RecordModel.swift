//
//  RecordModel.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 5/4/23.
//

import Foundation

extension RecordView {
    class RecordModel : ObservableObject {
        @Published private var isRecording : Bool = false
        @Published private var fadeInOut : Bool = false
        @Published private var circleMultiplier : CGFloat = 1.0
        @Published private var showFiles : Bool = false
        
        
    }
}
