//
//  RecordModel.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 4/10/23.
//

import Foundation
import AVFoundation

class PlayerRecorder : ObservableObject {
    enum RecordingState {
        case recording
        case paused
        case stopped
        case playing
    }
    
    private var engine: AVAudioEngine!
    private var mixNode: AVAudioMixerNode!
    private var playNode: AVAudioPlayerNode!
    private var state: RecordingState = .stopped
    
    init() {
        setUpSesh()
        setUpEngine()
    }
    
    private func setUpSesh() {
        do {
            let sesh = AVAudioSession.sharedInstance()
            try sesh.setCategory(.playAndRecord)
            try sesh.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch let error as NSError {
          print("ERROR:", error)
        }
    }
    
    private func setUpEngine() {
        engine = AVAudioEngine()
        mixNode = AVAudioMixerNode()
        playNode = AVAudioPlayerNode()
        mixNode.volume = 0
        engine.attach(mixNode)
        engine.attach(playNode)
        nodeConnect()
        engine.prepare()
    }
    
    private func nodeConnect() {
        let input = engine.inputNode
        let inputFormat = input.outputFormat(forBus: 0)
        engine.connect(input, to: mixNode, format: inputFormat)
        
        let mainMixNode = engine.mainMixerNode
        let mixFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
        engine.connect(mixNode, to: mainMixNode, format: mixFormat)
    }
    
    func record() throws {
        let mytime = Date()
        let dateFormat = DateFormatter()
        dateFormat.timeStyle = .medium
        dateFormat.dateStyle = .medium
        let tapNode: AVAudioNode = mixNode
        let format = tapNode.inputFormat(forBus: 0)
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = dateFormat.string(from: mytime) + ".caf"
        let file = try AVAudioFile(forWriting: documentURL.appendingPathComponent(fileName), settings: format.settings)
        tapNode.installTap(onBus: 0, bufferSize: 4096, format: format, block: {
            (buffer, time) in
            try? file.write(from: buffer)
        })
        try engine.start()
        state = .recording
    }
    
    func stop() {
        mixNode.removeTap(onBus: 0)
        engine.stop()
        state = .stopped
    }
    
    func play(url: URL) {
        do {
            let file = try! AVAudioFile(forReading: url)
            engine.connect(playNode, to: engine.mainMixerNode, format: file.processingFormat)
            playNode.scheduleFile(file, at: nil)
            try engine.start()
            playNode.play()
            state = .playing
        } catch {
            print("Engine not started!!")
        }


    }
}
