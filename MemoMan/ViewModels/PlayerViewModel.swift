import Foundation
import Combine
import AVFoundation
import Accelerate

extension PlayerView {
    final class PlayerViewModel: ObservableObject {
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
            loadAudioSamples()
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
        
        @MainActor
        func seek(to time: TimeInterval) {
            seekingSubject.send(time)
        }
        
        var duration: TimeInterval {
            player.duration
        }
        
        @MainActor
        private func loadAudioSamples() {
            let url = recording.fileURL
            if let audioFile = loadAudioFile(url: url) {
                if recording.samples == nil {
                    Task {
                        recording.samples = try? await processSamples(from: audioFile)
                    }
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
        
        private func processSamples(from audioFile: AVAudioFile)  async throws -> [Float] {
            let sampleCount = 128
            let frameCount = Int(audioFile.length)
            let samplesPerSegment = frameCount / sampleCount
            
            let buffer = try createAudioBuffer(for: audioFile, frameCapacity: AVAudioFrameCount(samplesPerSegment))
            let channelCount = Int(buffer.format.channelCount)
            
            let audioData = try readAudioData(from: audioFile, into: buffer, sampleCount: sampleCount, samplesPerSegment: samplesPerSegment, channelCount: channelCount)
            
            let processedResults = try await processAudioSegments(audioData: audioData, sampleCount: sampleCount, samplesPerSegment: samplesPerSegment, channelCount: channelCount)
            
            var samples = await createSamplesArray(from: processedResults, sampleCount: sampleCount)
            
            samples = await applyNoiseFloor(to: samples, noiseFloor: 0.01)
            samples = await normalizeSamples(samples)
            
            return samples
        }
        
        private func createAudioBuffer(for audioFile: AVAudioFile, frameCapacity: AVAudioFrameCount) throws -> AVAudioPCMBuffer {
            guard let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCapacity) else {
                throw Errors.AudioProcessingError
            }
            return buffer
        }
        
        private func readAudioData(from audioFile: AVAudioFile, into buffer: AVAudioPCMBuffer, sampleCount: Int, samplesPerSegment: Int, channelCount: Int) throws -> [[Float]] {
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
            
            return audioData
        }

        private func processAudioSegments(audioData: [[Float]], sampleCount: Int, samplesPerSegment: Int, channelCount: Int) async throws -> [(Int, Float)] {
            let batchSize = 16 // Process 16 segments at once
            let dataCount = samplesPerSegment * channelCount

            return try await withThrowingTaskGroup(of: [(Int, Float)].self) { taskGroup in
                for batchStart in stride(from: 0, to: sampleCount, by: batchSize) {
                    let batchEnd = min(batchStart + batchSize, sampleCount)
                    
                    taskGroup.addTask {
                        // Allocate a buffer for the entire batch
                        var batchBuffer = [Float](repeating: 0, count: dataCount * (batchEnd - batchStart))
                        var results = [(Int, Float)]()

                        // Copy batch data into contiguous memory
                        for (index, segment) in audioData[batchStart..<batchEnd].enumerated() {
                            batchBuffer.replaceSubrange(index * dataCount..<(index + 1) * dataCount, with: segment)
                        }

                        // Process the entire batch at once
                        var squaredBuffer = [Float](repeating: 0, count: batchBuffer.count)
                        vDSP_vsq(batchBuffer, 1, &squaredBuffer, 1, vDSP_Length(batchBuffer.count))

                        for segmentIndex in batchStart..<batchEnd {
                            let startIndex = (segmentIndex - batchStart) * dataCount
                            let endIndex = startIndex + dataCount

                            var mean: Float = 0
                            squaredBuffer.withUnsafeBufferPointer { bufferPointer in
                                vDSP_meanv(bufferPointer.baseAddress! + startIndex, 1, &mean, vDSP_Length(dataCount))
                            }
                            let rms = sqrt(mean)
                            results.append((segmentIndex, rms))
                        }

                        return results
                    }
                }

                var allResults = [(Int, Float)]()
                for try await batchResults in taskGroup {
                    allResults.append(contentsOf: batchResults)
                }

                return allResults.sorted(by: { $0.0 < $1.0 })
            }
        }
        
        private func createSamplesArray(from processedResults: [(Int, Float)], sampleCount: Int) async -> [Float] {
            var samples = [Float](repeating: 0, count: sampleCount)
            vDSP_vfill([0], &samples, 1, vDSP_Length(sampleCount))
            
            for (segment, rms) in processedResults {
                samples[segment] = rms
            }
            
            return samples
        }
        
        private func applyNoiseFloor(to samples: [Float], noiseFloor: Float) async -> [Float] {
            var result = samples
            let noiseFloorArray = [Float](repeating: noiseFloor, count: samples.count)
            vDSP_vsub(noiseFloorArray, 1, samples, 1, &result, 1, vDSP_Length(samples.count))
            return result
        }
        
        private func normalizeSamples(_ samples: [Float]) async -> [Float] {
            var result = samples
            var min: Float = 0
            var max: Float = 0
            vDSP_minv(samples, 1, &min, vDSP_Length(samples.count))
            vDSP_maxv(samples, 1, &max, vDSP_Length(samples.count))
            
            if max > min {
                var a: Float = 1.0 / (max - min)
                var b: Float = -min / (max - min)
                vDSP_vsmsa(samples, 1, &a, &b, &result, 1, vDSP_Length(samples.count))
            } else {
                vDSP_vfill([0.5], &result, 1, vDSP_Length(samples.count))
            }
            
            return result
        }
    }
}
