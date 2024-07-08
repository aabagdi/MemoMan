//
//  SettingsView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/4/24.
//

import SwiftUI
import AVFoundation

struct SettingsView: View {
    @AppStorage("sampleRate") var sampleRate : Double = 44_100
    @AppStorage("audioQuality") var audioQuality : Int = AVAudioQuality.max.rawValue
    @AppStorage("inputSource") var inputSource: String = {
        let availableInputs = AVAudioSession.sharedInstance().availableInputs
        return availableInputs?.first!.portName ?? "iPhone Microphone"
    }()
    
    private var inputSourceList : [String] {
        var inputs : [String] = []
        let session = AVAudioSession.sharedInstance()
        let availableInputs = session.availableInputs
        availableInputs?.forEach( { input in
            inputs.append(input.portName)
        } )
        return inputs
    }
    
    private var sampleRateList: [Double] = [8_000, 11_025, 22_050, 44_100, 48_000]
    private var audioQualityList : [Int] = [AVAudioQuality.min.rawValue, AVAudioQuality.low.rawValue, AVAudioQuality.medium.rawValue, AVAudioQuality.high.rawValue, AVAudioQuality.max.rawValue]

    
    var body: some View {
        List {
            Picker("Input source", selection: $inputSource) {
                ForEach(inputSourceList, id: \.self) { inputSource in
                    Text(inputSource)
                }
            }
            Picker("Sample rate", selection: $sampleRate) {
                ForEach(sampleRateList, id: \.self) { sampleRate in
                    switch sampleRate {
                        case 8_000: Text("8 kHz (space saver++)")
                        case 11_025: Text("11 kHz (space saver+)")
                        case 22_050: Text("22 kHz (space saver)")
                        case 44_100: Text("44.1 kHz (CD quality)")
                        case 48_000: Text("48 kHz (studio quality)")
                        default: Text("44.1 kHz (CD quality)")
                    }
                }
            }
            Picker("Audio quality", selection: $audioQuality) {
                ForEach(audioQualityList, id: \.self) { audioQuality in
                    switch audioQuality {
                        case 0: Text("Minimum")
                        case 32: Text("Low")
                        case 64: Text("Medium")
                        case 96: Text("High")
                        case 127: Text("Maximum")
                        default: Text("Maximum")
                    }
                }
            }
        }
        .onAppear {
            updateInputSources()
        }
    }
    
    private func updateInputSources() {
        let session = AVAudioSession.sharedInstance()
        let inputs = session.availableInputs?.map { $0.portName } ?? []
        let availableInputSources = inputs
        if !availableInputSources.contains(inputSource) {
            inputSource = "iPhone Microphone"
        }
    }
}

#Preview {
    SettingsView()
}
