//
//  AVAudioSession + Codable.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/5/24.
//

import Foundation
import AVFoundation

extension AVAudioSessionPortDescription : Codable {
    private enum CodingKeys : String, CodingKey {
        case portType
        case portName
        case uid
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    }
    
    public required convenience init(from decoder: any Decoder) throws {
        return AVAus
    }
    
    
}
