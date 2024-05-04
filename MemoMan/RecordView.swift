//
//  ContentView.swift
//  MemoMan clean
//
//  Created by Aadit Bagdi on 11/1/23.
//

import SwiftUI

//
//  ContentView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 4/7/23.
//

import SwiftUI
import AVFoundation
import AVFAudio
import CoreData
import CloudKit

struct RecordView: View {
    @StateObject private var recorder : Recorder = Recorder()
    @StateObject private var model : RecordViewModel = RecordViewModel()
    @State var recordings : [Recording] = []
    
    var body: some View {
        NavigationStack {
            GeometryReader { g in
                ZStack {
                    Circle()
                        .fill(Color(red: 255 / 255, green: 160 / 255, blue: 69 / 255))
                        .opacity(model.fadeInOut ? 0.2 : 0.0)
                        .frame(width: model.fadeInOut ? (g.size.width)/2.1 : g.size.width/4, height: model.fadeInOut ? (g.size.width )/2.1 : g.size.width/4)
                    Circle()
                        .fill(Color(red: 255 / 255, green: 157 / 255, blue: 115 / 255))
                        .opacity(model.fadeInOut ? 0.3 : 0.0)
                        .frame(width: model.fadeInOut ? (g.size.width)/2.50384615384
                               : g.size.width/4, height: model.fadeInOut ? (g.size.width )/2.50384615384
                               : g.size.width/4)
                    Circle()
                        .fill(Color(red: 255 / 255, green: 167 / 255, blue: 61 / 255))
                        .opacity(model.fadeInOut ? 0.5 : 0.0)
                        .frame(width: model.fadeInOut ? (g.size.width)/3.1 : g.size.width/4, height: model.fadeInOut ? (g.size.width )/3.1 : g.size.width/4)
                    
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: g.size.width/12))
                            .imageScale(.medium)
                            .frame(width: g.size.width/4, height: g.size.width/4)
                            .foregroundColor(Color.white)
                            .background(model.fadeInOut ? Color.red : Color(red: 166/255, green: 104/255, blue: 247/255))
                            .clipShape(Circle())
                    }
                    .overlay(
                        Circle()
                            .stroke(model.isRecording ? Color.white : Color(red: 166/255, green: 104/255, blue: 247/255), lineWidth: 3)
                            .scaleEffect(model.isRecording ? 2.4 : model.animationAmount)
                            .opacity(model.isRecording ? 0 : 2 - model.animationAmount)
                            .animation(model.isRecording ? Animation.easeOut(duration: model.animationAmount)
                                .repeatForever(autoreverses: false) : .default, value: model.isRecording)
                    )
                    .onChange(of: model.isRecording){
                        model.animationAmount = model.isRecording ? 2.0 : 1.0
                    }
                    .simultaneousGesture(TapGesture(count: 2).onEnded({
                        model.isRecording.toggle()
                        switch model.isRecording {
                        case true:
                            Task {
                                try? recorder.record()
                            }
                            print("recording")
                        case false:
                            recorder.stop()
                            print("stopped")
                        }
                    }))
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                        .onEnded({_ in
                            if model.isRecording {
                                model.isRecording.toggle()
                                recorder.stop()
                            }
                            Task {
                                 try? recorder.record()
                            }
                            
                            model.isRecording.toggle()
                        })
                            .sequenced(before: DragGesture(minimumDistance: 0)
                                .onEnded({_ in
                                    model.isRecording.toggle()
                                    recorder.stop()
                                }))
                    )
                }
                .onChange(of: model.isRecording) {
                    withAnimation(Animation.easeInOut(duration: 0.6)) {
                        model.fadeInOut.toggle()
                    }
                }
                .frame(width: g.size.width, height: g.size.height, alignment: .center)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Recordings") {
                        if model.isRecording {
                            model.isRecording.toggle()
                            recorder.stop()
                        }
                        model.showFiles.toggle()
                    }
                    .navigationDestination(isPresented: $model.showFiles) {
                        FilesView()
                    }
                }
            }
        }
        .alert("Microphone permissions not enabled, you can change this in Privacy & Security settings", isPresented: $model.showAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            Task {
                if await AVAudioApplication.requestRecordPermission() {
                    // The user grants access. Present recording interface.
                    print("Permission granted")
                } else {
                    // The user denies access. Present a message that indicates
                    // that they can change their permission settings in the
                    // Privacy & Security section of the Settings app.
                    model.showAlert.toggle()
                }
            }
        }
    }
    
    func fetchRecordings() {
        
    }
    
}
