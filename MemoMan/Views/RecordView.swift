//
//  ContentView.swift
//  MemoMan clean
//
//  Created by Aadit Bagdi on 11/1/23.
//


import SwiftUI
import AVFoundation
import SwiftData
import UIKit

struct RecordView: View {
    @State private var recorder : Recorder = Recorder()
    @State private var model : RecordViewModel = RecordViewModel()
    
    private var originalBrightness: CGFloat = UIScreen.main.brightness
    
    @State private var deviceOrientation : UIDeviceOrientation = .portrait
    
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { g in
                    ZStack {
                        Circle()
                            .fill(Color(red: 255 / 255, green: 160 / 255, blue: 69 / 255))
                            .opacity(model.fadeInOut ? 0.2 : 0.0)
                            .frame(width: circleSize(for: recorder.avgPower, maxWidth: g.size.width), height: circleSize(for: recorder.avgPower, maxWidth: g.size.width))
                        Circle()
                            .fill(Color(red: 255 / 255, green: 157 / 255, blue: 115 / 255))
                            .opacity(model.fadeInOut ? 0.3 : 0.0)
                            .frame(width: circleSize(for: recorder.avgPower, maxWidth: g.size.width) * 0.9, height: circleSize(for: recorder.avgPower, maxWidth: g.size.width) * 0.9)
                        Circle()
                            .fill(Color(red: 255 / 255, green: 167 / 255, blue: 61 / 255))
                            .opacity(model.fadeInOut ? 0.5 : 0.0)
                            .frame(width: circleSize(for: recorder.avgPower, maxWidth: g.size.width) * 0.8, height: circleSize(for: recorder.avgPower, maxWidth: g.size.width) * 0.8)
                        
                        Button(action: {}) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: g.size.width/12))
                                .imageScale(.medium)
                                .frame(width: g.size.width/4, height: g.size.width/4)
                                .foregroundColor(.white)
                                .background(model.fadeInOut ? Color.red : Color("MemoManPurple"))
                                .clipShape(Circle())
                        }
                        .overlay(
                            Circle()
                                .stroke(model.isRecording ? Color.red : Color("MemoManPurple"), lineWidth: 3)
                                .scaleEffect(model.animationAmount)
                                .opacity(2 - model.animationAmount)
                                .animation(
                                    model.isRecording ?
                                        Animation.easeOut(duration: 1)
                                            .repeatForever(autoreverses: false) :
                                        Animation.easeOut(duration: 0.3),
                                    value: model.animationAmount
                                )
                        )
                        .onChange(of: model.isRecording) {
                            if model.isRecording {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    model.animationAmount = 2.0
                                }
                            } else {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    model.animationAmount = 1.0
                                }
                            }
                        }
                        .simultaneousGesture(TapGesture(count: 2).onEnded({
                            model.isRecording.toggle()
                            switch model.isRecording {
                            case true:
                                try? recorder.record()
                                let brightnessWorkItem = DispatchWorkItem {
                                     if model.isRecording {
                                         UIScreen.main.brightness = 0.25
                                     }
                                 }
                                model.brightnessTask = brightnessWorkItem
                                DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: brightnessWorkItem)
                            case false:
                                try? recorder.stop(modelContainer: ModelContainer(for: Recording.self))
                                UIScreen.main.brightness = originalBrightness
                                model.brightnessTask?.cancel()
                                model.brightnessTask = nil
                            }
                        }))
                        .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                            .onEnded({_ in
                                if model.isRecording {
                                    model.isRecording.toggle()
                                    try? recorder.stop(modelContainer: ModelContainer(for: Recording.self))
                                }
                                try? recorder.record()
                                model.isRecording.toggle()
                            })
                                .sequenced(before: DragGesture(minimumDistance: 0)
                                    .onEnded({_ in
                                        model.isRecording.toggle()
                                        try? recorder.stop(modelContainer: ModelContainer(for: Recording.self))
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
                Text(recorder.startTime ?? Date(), style: .timer)
                    .font(.title)
                    .opacity(model.isRecording ? 1 : 0)
                    .animation(.easeInOut, value: model.isRecording)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if model.isRecording {
                            model.isRecording.toggle()
                            try? recorder.stop(modelContainer: ModelContainer(for: Recording.self))
                        }
                        model.showFiles.toggle()
                    } label: {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(Color("MemoManPurple"))
                    }
                    .navigationDestination(isPresented: $model.showFiles) {
                        FilesView()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if model.isRecording {
                            model.isRecording.toggle()
                            try? recorder.stop(modelContainer: ModelContainer(for: Recording.self))
                        }
                        model.showSettings.toggle()
                        
                    } label: {
                        Image(systemName: "gearshape.2.fill")
                            .foregroundStyle(Color("MemoManPurple"))
                    }
                    .navigationDestination(isPresented: $model.showSettings) {
                        SettingsView()
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
                try await recorder.updateOrientation(deviceOrientation: deviceOrientation)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            let orientation = UIDevice.current.orientation
            guard orientation.isValidInterfaceOrientation else { return }
            self.deviceOrientation = orientation
            Task {
                do {
                    if !model.isRecording {
                        try await recorder.updateOrientation(deviceOrientation: deviceOrientation)
                    }
                } catch {
                    print("Failed to update orientation: \(error)")
                }
            }
        }
        .environment(\.modelContext, modelContext)
    }
}
