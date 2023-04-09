//
//  ContentView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 4/7/23.
//

import SwiftUI
import AVFoundation

struct RecordView: View {
    @State private var isRecording : Bool = false
    @State private var fadeInOut : Bool = false
    @State private var AudioSesh : AVAudioSession!
    @State private var AudioRecoder : AVAudioRecorder!
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Circle()
                    .fill(Color(red: 255 / 255, green: 160 / 255, blue: 69 / 255))
                    .opacity(0.2)
                    .frame(width: fadeInOut ? g.size.width/2.1 : g.size.width/4, height: fadeInOut ? g.size.width/2.1 : g.size.width/4)
                Circle()
                    .fill(Color(red: 255 / 255, green: 157 / 255, blue: 115 / 255))
                    .opacity(0.3)
                    .frame(width: fadeInOut ? g.size.width/2.50384615384
                           : g.size.width/4, height: fadeInOut ? g.size.width/2.50384615384
                           : g.size.width/4)
                Circle()
                    .fill(Color(red: 255 / 255, green: 167 / 255, blue: 61 / 255))
                    .opacity(0.5)
                    .frame(width: fadeInOut ? g.size.width/3.1 : g.size.width/4, height: fadeInOut ? g.size.width/3.1 : g.size.width/4)
                
                Button(action: {}) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: g.size.width/12))
                        .imageScale(.medium)
                        .frame(width: g.size.width/4, height: g.size.width/4)
                        .foregroundColor(Color.white)
                        .foregroundColor(.red)
                        .background(Color.yellow)
                        .clipShape(Circle())
                }
                .simultaneousGesture(TapGesture(count: 2).onEnded({
                    print("Double tap")
                    isRecording.toggle()
                    switch isRecording {
                    case true:
                        //AudioRecoder.record()
                        print("Record")
                    case false:
                        //AudioRecoder.stop()
                        print("Stop")
                    }
                }))
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                    .onEnded({_ in
                        isRecording.toggle()
                        //AudioRecoder.record()
                    })
                        .sequenced(before: DragGesture(minimumDistance: 0)
                            .onEnded({_ in
                                isRecording.toggle()
                                //AudioRecoder.stop()
                            }))
                )
            }.onAppear {
                do {
                    AudioSesh = AVAudioSession.sharedInstance()
                    try AudioSesh.setCategory(.playAndRecord)
                    AudioSesh.requestRecordPermission { (status) in
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            .onChange(of: isRecording) {newValue in
                withAnimation(Animation.easeInOut(duration: 0.6)) {
                    fadeInOut.toggle()
                }
            }
            .frame(width: g.size.width, height: g.size.height, alignment: .center)
        }
    }
}
