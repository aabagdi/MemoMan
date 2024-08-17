import Foundation
import AVFoundation
import SwiftUI
import Combine

final class Player: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime : TimeInterval = 0
    
    private var player : AVAudioPlayer?
    private var timer : AnyCancellable?
    
    init?(recording: Recording) {
        super.init()
        guard FileManager.default.fileExists(atPath: recording.fileURL.path),
              let player = try? AVAudioPlayer(contentsOf: recording.fileURL) else {
            print("Failed to initialize AVAudioPlayer")
            return nil
        }
        
        self.player = player
        player.delegate = self
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func play() {
        guard let player = player, !isPlaying else { return }
        player.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        guard isPlaying else { return }
        player?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        resetPlayback()
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }
    
    var duration: TimeInterval {
        player?.duration ?? 0
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCurrentTime()
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    private func resetPlayback() {
        player?.currentTime = 0
        updateCurrentTime()
    }
    
    private func updateCurrentTime() {
        currentTime = player?.currentTime ?? 0
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
            stopTimer()
            resetPlayback()
        }
    }
}
