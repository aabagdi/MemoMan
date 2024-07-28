import Foundation
import Combine
import AVFoundation

extension PlayerView {
    @MainActor
    class PlayerViewModel: ObservableObject {
        @Published var currentTime: TimeInterval = 0
        
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
                if recording.samples == nil {
                    recording.samples = processSamples(from: audioFile)
                }
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
            let sampleCount = 128
            let frameCount = Int(audioFile.length)
            let sampleStride = frameCount / sampleCount
            let frameCapacity = min(sampleStride, 1024)
            var samples = [Float](repeating: 0, count: sampleCount)

            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(frameCapacity)) else {
                print("Failed to create AVAudioPCMBuffer")
                return samples
            }

            let channelCount = Int(buffer.format.channelCount)
            let bytesPerFrame = buffer.format.streamDescription.pointee.mBytesPerFrame

            do {
                var sampleIndex = 0
                while audioFile.framePosition < audioFile.length && sampleIndex < sampleCount {
                    try audioFile.read(into: buffer)
                    let framesRead = Int(buffer.frameLength)
                    
                    guard let rawBuffer = buffer.audioBufferList.pointee.mBuffers.mData else {
                        print("Failed to access raw audio buffer")
                        break
                    }
                    
                    for i in stride(from: 0, to: framesRead, by: sampleStride) {
                        guard sampleIndex < sampleCount else { break }
                        
                        var sample: Float = 0
                        for channel in 0..<channelCount {
                            let offset = i * Int(bytesPerFrame) + channel * MemoryLayout<Float>.size
                            sample += abs(rawBuffer.load(fromByteOffset: offset, as: Float.self))
                        }
                        samples[sampleIndex] = sample / Float(channelCount)
                        sampleIndex += 1
                    }
                }
            } catch {
                print("Error reading audio file: \(error.localizedDescription)")
            }

            return samples
        }
    }
}
