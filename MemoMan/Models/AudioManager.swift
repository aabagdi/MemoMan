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
    
    private let seekInterval: TimeInterval = 15.0
    
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
        
        commandCenter.seekForwardCommand.addTarget { [weak self] event in
            guard let self = self,
                  let player = self.currentPlayer,
                  let seekEvent = event as? MPSeekCommandEvent else { return .commandFailed }
            
            let seekTime = player.currentTime + (seekEvent.type == .beginSeeking ? self.seekInterval : 0)
            self.seek(to: seekTime)
            return .success
        }
        
        commandCenter.seekBackwardCommand.addTarget { [weak self] event in
            guard let self = self,
                  let player = self.currentPlayer,
                  let seekEvent = event as? MPSeekCommandEvent else { return .commandFailed }
            
            let seekTime = max(0, player.currentTime - (seekEvent.type == .beginSeeking ? self.seekInterval : 0))
            self.seek(to: seekTime)
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
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
        guard let player = currentPlayer else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = player.recording.name
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.isPlaying ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
