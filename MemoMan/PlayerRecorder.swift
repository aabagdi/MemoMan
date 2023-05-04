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
        let fileName : String = dateFormat.string(from: mytime)
        let tapNode: AVAudioNode = mixNode
        let format = tapNode.inputFormat(forBus: 0)
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileNameExtension = dateFormat.string(from: mytime) + ".caf"
        let file = RecordingContainer(name: fileName, date: fileName, tag: nil, url: documentURL.appendingPathComponent(fileNameExtension), settings: format.settings)
        //let file = try AVAudioFile(forWriting: documentURL.appendingPathComponent(fileName), settings: format.settings)
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
    
    func pause() {
        engine.pause()
        state = .paused
    }
    
    func play(url: URL) {
        do {
            let sesh = AVAudioSession.sharedInstance()
            try sesh.setCategory(.playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
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

class RecordingContainer : AVAudioFile {
    fileprivate var name : String
    fileprivate var date : String
    fileprivate var tag : String?
    
    required init(name: String, date: String, tag: String!, url: URL, settings: [String : Any]) {
        self.name = name
        self.date = date
        self.tag = tag
        try! super.init(forWriting: url, settings: settings)
    }
    
    override init(forWriting: URL, settings: [String : Any], commonFormat: AVAudioCommonFormat, interleaved: Bool) throws {
        let dateFormat = DateFormatter()
        let mytime = Date()
        self.name = "Woo"
        self.date = dateFormat.string(from: mytime)
        self.tag = nil
        try! super.init(forWriting: forWriting, settings: settings, commonFormat: commonFormat, interleaved: interleaved)
    }
    
    func setName(newName: String) {
        name = newName
    }
    
    func getName() -> String {
        return name
    }
    
    func getDate() -> String {
        return date
    }
    
    func setTag(newTag: String) {
        tag = newTag
    }
    
    func getTag() -> String? {
        return tag
    }
}
