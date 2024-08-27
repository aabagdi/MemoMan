//
//  AudioManager.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 8/27/24.
//

import Foundation
import MediaPlayer
import Combine

final class AudioManager: ObservableObject, @unchecked Sendable {
    static let shared = AudioManager()
    
    @Published private(set) var currentPlayer: Player?
    private var players: [Player] = []
    
    private init() {
        setupRemoteTransportControls()
    }
    
    func createPlayer(for recording: Recording) -> Player? {
        let player = Player(recording: recording)
        if let player = player {
            players.append(player)
        }
        return player
    }
    
    func setCurrentPlayer(_ player: Player) {
        currentPlayer = player
        updateNowPlayingInfo()
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self, let player = self.currentPlayer else { return .commandFailed }
            player.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self, let player = self.currentPlayer else { return .commandFailed }
            player.pause()
            return .success
        }
    }
    
    func updateNowPlayingInfo() {
        guard let player = currentPlayer else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = player.recording.name
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.isPlaying ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
