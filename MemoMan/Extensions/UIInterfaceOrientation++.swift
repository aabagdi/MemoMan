//
//  UIInterfaceOrientation++.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/1/24.
//

import Foundation
import UIKit
import AVFoundation

extension UIInterfaceOrientation {
    var inputOrientation: AVAudioSession.StereoOrientation {
        return AVAudioSession.StereoOrientation(rawValue: rawValue)!
    }
}
