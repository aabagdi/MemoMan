//
//  Orientation.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/2/24.
//

import Foundation
import AVFoundation

enum Orientation: Int {
    case unknown = 0
    case portrait = 1
    case portraitUpsideDown = 2
    case landscapeRight = 3
    case landscapeLeft = 4
}

extension Orientation {
    // The convenience property to retrieve the AVAudioSession.StereoOrientation.
    var inputOrientation: AVAudioSession.StereoOrientation {
        return AVAudioSession.StereoOrientation(rawValue: rawValue)!
    }
}
