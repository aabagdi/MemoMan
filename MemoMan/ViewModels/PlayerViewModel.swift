import Foundation
import Combine
import AVFoundation
import Accelerate

extension PlayerView {
    @MainActor
    class PlayerViewModel: ObservableObject {
        @Published var currentTime : TimeInterval = 0
        var player : Player
        var recording : Recording
        private var cancellables = Set<AnyCancellable>()
        private var seekingSubject = PassthroughSubject<TimeInterval, Never>()
        
        init(player: Player?, recording: Recording) throws {
            guard let player else {
                throw Errors.NilPlayer
            }
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
                return nil
            }
        }
        
        private func processSamples(from audioFile: AVAudioFile) -> [Float] {
            let sampleCount = 128
            let frameCount = AVAudioFrameCount(audioFile.length)
            let frameCapacity = AVAudioFrameCount(min(4096, Int(frameCount)))
            var samples = [Float](repeating: 0, count: sampleCount)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCapacity) else {
                return samples
            }
            
            let channelCount = Int(buffer.format.channelCount)
            let samplesPerSegment = Int(frameCount) / sampleCount
            var maxSample: Float = 0.001
            
            do {
                var tempBuffer = [Float](repeating: 0, count: Int(frameCapacity) * channelCount)
                
                for segment in 0..<sampleCount {
                    let segmentStart = AVAudioFramePosition(segment * samplesPerSegment)
                    let segmentLength = AVAudioFrameCount(min(samplesPerSegment, Int(frameCount) - segment * samplesPerSegment))
                    
                    audioFile.framePosition = segmentStart
                    try audioFile.read(into: buffer, frameCount: segmentLength)
                    
                    if let channelData = buffer.floatChannelData {
                        vDSP_mmov(channelData.pointee, &tempBuffer, vDSP_Length(segmentLength), vDSP_Length(channelCount), vDSP_Length(channelCount), vDSP_Length(1))
                        
                        vDSP_vabs(tempBuffer, 1, &tempBuffer, 1, vDSP_Length(segmentLength) * vDSP_Length(channelCount))
                        
                        var maxValue: Float = 0
                        vDSP_maxv(tempBuffer, 1, &maxValue, vDSP_Length(segmentLength) * vDSP_Length(channelCount))
                        
                        samples[segment] = maxValue
                        maxSample = max(maxSample, maxValue)
                    }
                }
                
                var scale = 1.0 / maxSample
                vDSP_vsmul(samples, 1, &scale, &samples, 1, vDSP_Length(sampleCount))
                
            } catch {
                print("Error reading audio file: \(error.localizedDescription)")
            }
            
            return samples
        }
    }
}
