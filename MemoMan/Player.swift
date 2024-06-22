import Foundation
import AVFoundation
import SwiftUI
import Combine

class Player: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var player: AVAudioPlayer?
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var isPlaying = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var currentTime: TimeInterval = 0
    private var timer: AnyCancellable?

    init(soundURL: URL) throws {
        super.init()
        if FileManager().fileExists(atPath: soundURL.path) {
            do {
                self.player = try AVAudioPlayer(contentsOf: soundURL)
                player?.prepareToPlay()
                self.player?.delegate = self
            } catch {
                throw Errors.FailedToPlayURL
            }
        } else {
            print("URL not valid!")
        }
    }
    
    func play() {
        self.player?.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        if isPlaying {
            self.player?.pause()
            isPlaying = false
            stopTimer()
        }
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
                guard let self = self else { return }
                self.currentTime = self.player?.currentTime ?? 0
                self.objectWillChange.send()
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
            stopTimer()
            resetPlayback()
        }
    }
    
    private func resetPlayback() {
        currentTime = 0
        player?.currentTime = 0
        objectWillChange.send()
    }
}
