//
//  UIDeviceOrientation++.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/28/24.
//

import Foundation
import AVFoundation
import UIKit

extension UIDeviceOrientation {
  var inputOrientation: AVAudioSession.StereoOrientation {
    switch self {
    case .portrait, .portraitUpsideDown:
      return .portrait
    case .landscapeLeft:
      return .landscapeLeft
    case .landscapeRight:
      return .landscapeRight
    default:
      return .portrait
    }
  }
  
  var microphoneOrientation: AVAudioSession.Orientation {
    switch self {
    case .portrait:
      return .front
    case .portraitUpsideDown:
      return .back
    case .landscapeLeft:
      return .right
    case .landscapeRight:
      return .left
    default:
      return .front
    }
  }
}
