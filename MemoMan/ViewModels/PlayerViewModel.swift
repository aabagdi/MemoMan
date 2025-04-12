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
          Task { [weak self] in
            guard let self else { return }
            do {
              self.recording.samples = try await self.processSamples(from: audioFile)
            } catch {
              self.recording.samples = nil
              print("Error processing audio samples: \(error)")
            }
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
    
    private func processSamples(from audioFile: AVAudioFile) async throws -> [Float] {
      let sampleCount = 128
      let frameCount = Int(audioFile.length)
      let samplesPerSegment = frameCount / sampleCount
      
      let buffer = try createAudioBuffer(for: audioFile, frameCapacity: AVAudioFrameCount(samplesPerSegment))
      let channelCount = Int(buffer.format.channelCount)
      
      var samples = [Float](repeating: 0, count: sampleCount)
      
      for segment in 0..<sampleCount {
        let segmentStart = AVAudioFramePosition(segment * samplesPerSegment)
        audioFile.framePosition = segmentStart
        try audioFile.read(into: buffer)
        
        if let channelData = buffer.floatChannelData {
          let dataCount = samplesPerSegment * channelCount
          let segmentData = UnsafeBufferPointer(start: channelData[0], count: dataCount)
          samples[segment] = processSegment(segmentData)
        }
      }
      
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
    
    private func processSegment(_ segmentData: UnsafeBufferPointer<Float>) -> Float {
      var squaredSum: Float = 0
      vDSP_svesq(segmentData.baseAddress!, 1, &squaredSum, vDSP_Length(segmentData.count))
      return sqrt(squaredSum / Float(segmentData.count))
    }
    
    private func applyNoiseFloor(to samples: [Float], noiseFloor: Float) async -> [Float] {
      var result = samples
      vDSP_vthr(samples, 1, [noiseFloor], &result, 1, vDSP_Length(samples.count))
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
