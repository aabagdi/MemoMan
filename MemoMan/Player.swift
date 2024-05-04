//
//  Player.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 9/1/23.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class Player : NSObject, ObservableObject, AVAudioPlayerDelegate {
    var player: AVAudioPlayer!
    let objectWillChange = PassthroughSubject<Player, Never>()
    
    var isPlaying = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func play(soundURL : URL) throws {
        if FileManager().fileExists(atPath:(soundURL.path)) {
            do {
                self.player = try AVAudioPlayer(contentsOf: soundURL)
                player.prepareToPlay()
                self.player.delegate = self
                self.player.play()
                isPlaying = true
            }
            catch {
                throw Errors.FailedToPlayURL
            }
        }
        else {
            print("URL not valid!")
        }
    }
    
    func pause() {
        self.player.pause()
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
}
