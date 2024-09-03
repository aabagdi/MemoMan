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
            let frameCount = Int(audioFile.length)
            let samplesPerSegment = frameCount / sampleCount
            var samples = [Float](repeating: 0, count: sampleCount)
            
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(samplesPerSegment)) else {
                return samples
            }
            
            let channelCount = Int(buffer.format.channelCount)
            let noiseFloor: Float = 0.01
            var maxSample: Float = 0.001
            
            do {
                var squaredBuffer = [Float](repeating: 0, count: samplesPerSegment * channelCount)
                var rmsBuffer = [Float](repeating: 0, count: sampleCount)
                
                var lowerBounds = [Float](repeating: noiseFloor, count: sampleCount)
                var upperBounds = [Float](repeating: Float.greatestFiniteMagnitude, count: sampleCount)
                
                for segment in 0..<sampleCount {
                    let segmentStart = AVAudioFramePosition(segment * samplesPerSegment)
                    audioFile.framePosition = segmentStart
                    try audioFile.read(into: buffer)
                    
                    if let channelData = buffer.floatChannelData {
                        let dataCount = samplesPerSegment * channelCount
                        
                        vDSP_vsq(channelData.pointee, 1, &squaredBuffer, 1, vDSP_Length(dataCount))
                        
                        var rms: Float = 0
                        vDSP_meanv(squaredBuffer, 1, &rms, vDSP_Length(dataCount))
                        
                        rms = sqrt(rms)
                        rmsBuffer[segment] = rms
                    }
                }

                vDSP_vclip(rmsBuffer, 1, &lowerBounds, &upperBounds, &rmsBuffer, 1, vDSP_Length(sampleCount))

                var noiseFloorArray = [Float](repeating: noiseFloor, count: sampleCount)
                vDSP_vsub(noiseFloorArray, 1, rmsBuffer, 1, &rmsBuffer, 1, vDSP_Length(sampleCount))

                vDSP_maxv(rmsBuffer, 1, &maxSample, vDSP_Length(sampleCount))
                maxSample = max(maxSample, 0.001)

                var scale = 1.0 / maxSample
                vDSP_vsmul(rmsBuffer, 1, &scale, &samples, 1, vDSP_Length(sampleCount))
                
            } catch {
                print("Error reading audio file: \(error.localizedDescription)")
            }
            
            return samples
        }
    }
}
