//
//  Player.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 9/1/23.
//

import Foundation
import AVFoundation

class Player : ObservableObject {
    private var player: AVAudioPlayer!
    let soundURL: URL
    
    init(soundURL: URL) {
        self.soundURL = soundURL
        self.player = try! AVAudioPlayer(contentsOf: soundURL)
    }
    
    func play() {
        self.player.play()
    }
    
    func pause() {
        self.player.pause()
    }
    
    func isPlaying() -> Bool {
        return self.player.isPlaying
    }
    
}
