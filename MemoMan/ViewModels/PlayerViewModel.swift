import Foundation
import Combine
import AVFoundation
import Accelerate

extension PlayerView {
    class PlayerViewModel: ObservableObject {
        @Published var currentTime : TimeInterval = 0
        var player : Player
        var recording : Recording
        private var cancellables = Set<AnyCancellable>()
        private var seekingSubject = PassthroughSubject<TimeInterval, Never>()
        
        @MainActor
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
            
            Task {
                await loadAudioSamples()
            }
        }
        
        @MainActor
        func play() {
            player.play()
        }
        
        @MainActor
        func pause() {
            player.pause()
        }
        
        @MainActor
        func stop() {
            player.stop()
        }
        
        func seek(to time: TimeInterval) {
            seekingSubject.send(time)
        }
        
        var duration: TimeInterval {
            player.duration
        }
        
        private func loadAudioSamples() async {
            let url = recording.fileURL
            if let audioFile = loadAudioFile(url: url) {
                if recording.samples == nil {
                    recording.samples = try? await processSamples(from: audioFile)
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

        private func processSamples(from audioFile: AVAudioFile) async throws -> [Float] {
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
            
            var audioData = [[Float]](repeating: [Float](repeating: 0, count: samplesPerSegment * channelCount), count: sampleCount)
            
            for segment in 0..<sampleCount {
                let segmentStart = AVAudioFramePosition(segment * samplesPerSegment)
                audioFile.framePosition = segmentStart
                try audioFile.read(into: buffer)
                
                if let channelData = buffer.floatChannelData {
                    let dataCount = samplesPerSegment * channelCount
                    audioData[segment] = Array(UnsafeBufferPointer(start: channelData[0], count: dataCount))
                }
            }

            let processedResults = try await withThrowingTaskGroup(of: (Int, Float).self) { taskGroup in
                for segment in 0..<sampleCount {
                    let segmentData = audioData[segment]
                    
                    taskGroup.addTask {
                        var squaredBuffer = [Float](repeating: 0, count: samplesPerSegment * channelCount)
                        var rms: Float = 0

                        vDSP_vsq(segmentData, 1, &squaredBuffer, 1, vDSP_Length(samplesPerSegment * channelCount))
                        vDSP_meanv(squaredBuffer, 1, &rms, vDSP_Length(samplesPerSegment * channelCount))
                        rms = sqrt(rms)

                        return (segment, rms)
                    }
                }

                var results = [(Int, Float)]()
                for try await result in taskGroup {
                    results.append(result)
                }
                return results
            }

            for (segment, rms) in processedResults {
                samples[segment] = rms
            }

            let noiseFloorArray = [Float](repeating: noiseFloor, count: sampleCount)
            var lowerBounds = [Float](repeating: noiseFloor, count: sampleCount)
            var upperBounds = [Float](repeating: Float.greatestFiniteMagnitude, count: sampleCount)

            vDSP_vclip(samples, 1, &lowerBounds, &upperBounds, &samples, 1, vDSP_Length(sampleCount))

            vDSP_vsub(noiseFloorArray, 1, samples, 1, &samples, 1, vDSP_Length(sampleCount))

            vDSP_maxv(samples, 1, &maxSample, vDSP_Length(sampleCount))
            maxSample = max(maxSample, 0.001)

            var scale = 1.0 / maxSample
            vDSP_vsmul(samples, 1, &scale, &samples, 1, vDSP_Length(sampleCount))

            return samples
        }
    }
}
