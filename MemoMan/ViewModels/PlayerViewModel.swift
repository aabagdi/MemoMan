import Foundation
import Combine
import AVFoundation

extension PlayerView {
    @MainActor
    class PlayerViewModel: ObservableObject {
        @Published var currentTime: TimeInterval = 0
        @Published var samples: [Float] = []
        
        var player: Player
        var recording: Recording
        private var cancellables = Set<AnyCancellable>()
        private var seekingSubject = PassthroughSubject<TimeInterval, Never>()
        
        init(player: Player, recording: Recording) {
            self.player = player
            self.recording = recording
            self.player.objectWillChange
                .sink { [weak self] in
                    self?.currentTime = self?.player.currentTime ?? 0
                }
                .store(in: &cancellables)
            
            seekingSubject
                .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
                .sink { [weak self] time in
                    self?.player.seek(to: time)
                }
                .store(in: &cancellables)
            
            loadAudioSamples()
        }
        
        func play() {
            player.play()
        }
        
        func pause() {
            player.pause()
        }
        
        func stop() {
            player.stop()
        }
        
        func seek(to time: TimeInterval) {
            seekingSubject.send(time)
        }
        
        var duration: TimeInterval {
            player.duration
        }
        
        private func loadAudioSamples() {
            let url = recording.fileURL
            if let audioFile = loadAudioFile(url: url) {
                samples = processSamples(from: audioFile)
            }
        }
        
        private func loadAudioFile(url: URL) -> AVAudioFile? {
            do {
                let audioFile = try AVAudioFile(forReading: url)
                return audioFile
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
                return nil
            }
        }
        
        private func processSamples(from audioFile: AVAudioFile) -> [Float] {
            let frameCount = Int(audioFile.length)
            let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(frameCount))!
            do {
                try audioFile.read(into: buffer)
            } catch {
                print("Error reading audio file: \(error.localizedDescription)")
                return []
            }
            let channelData1 = buffer.floatChannelData?[0]
            let channelData2 = buffer.floatChannelData?[1]
            var samples: [Float] = []
            let sampleCount = min(frameCount, 100)
            let sampleStride = frameCount / sampleCount
            for i in stride(from: 0, to: frameCount, by: sampleStride) {
                if channelData2 != nil {
                    let sample = abs(floatAverage(channelData1?[i] ?? 0.0, channelData2?[i] ?? 0.0))
                    samples.append(sample)
                }
                else {
                    let sample = abs(channelData1?[i] ?? 0.0)
                    samples.append(sample)
                }
            }
            return samples
        }
        
        private func floatAverage(_ number1: Float, _ number2: Float) -> Float {
            return (number1 + number2) / Float(2)
        }
    }
}
