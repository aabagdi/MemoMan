//
//  AudioManager.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 8/27/24.
//

import Foundation
import MediaPlayer

@MainActor
final class LockScreenControlManager {
    static let shared = LockScreenControlManager()

    private var currentPlayer : Player?
    
    private init() {
        setupRemoteTransportControls()
    }
    
    func createPlayer(for recording: Recording) -> Player? {
        let player = Player(recording: recording)
        return player
    }
    
    func setCurrentPlayer(_ player: Player) {
        currentPlayer = player
        updateNowPlayingInfo()
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self, let player = self.currentPlayer else { return .commandFailed }
            player.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self, let player = self.currentPlayer else { return .commandFailed }
            player.pause()
            return .success
        }
        
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            guard let self, let player = self.currentPlayer else { return .commandFailed }
            self.seek(to: player.currentTime + 10)
            return .success
        }
        
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            guard let self, let player = self.currentPlayer else { return .commandFailed }
            self.seek(to: player.currentTime - 10)
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self, let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            self.seek(to: positionEvent.positionTime)
            return .success
        }
    }
    
    func seek(to time: TimeInterval) {
        guard let player = currentPlayer else { return }
        let clampedTime = max(0, min(time, player.duration))
        player.seek(to: clampedTime)
        updateNowPlayingInfo()
    }
    
    func updateNowPlayingInfo() {
        guard let player = currentPlayer, let image = UIImage(named: "MemoMan") else { return }
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = player.recording.name
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.isPlaying ? 1.0 : 0.0
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
