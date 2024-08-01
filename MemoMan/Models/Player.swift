import Foundation
import AVFoundation
import SwiftUI
import Combine

final class Player: NSObject, ObservableObject, AVAudioPlayerDelegate {
    private var player : AVAudioPlayer?
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var isPlaying = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var currentTime: TimeInterval = 0
    private var timer: AnyCancellable?
    
    init(recording: Recording) {
        super.init()
        let path = recording.fileURL
        if FileManager.default.fileExists(atPath: path.path) {
            do {
                self.player = try AVAudioPlayer(contentsOf: path)
                player?.prepareToPlay()
                self.player?.delegate = self
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("AVAudioPlayer failed to initialise")
            }
        }
        else {
            print("File not found")
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
