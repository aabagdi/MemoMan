//
//  ContentView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 4/7/23.
//

import SwiftUI
import AVFoundation
import CoreData
import CloudKit

struct RecordView: View {
    @State private var isRecording : Bool = false
    @State private var fadeInOut : Bool = false
    @State private var circleMultiplier : CGFloat = 1.0
    @State private var showFiles : Bool = false
    private var recorder : AudioRecorder = AudioRecorder()
    
    var body: some View {
        NavigationStack {
            GeometryReader { g in
                ZStack {
                    Circle()
                        .fill(Color(red: 255 / 255, green: 160 / 255, blue: 69 / 255))
                        .opacity(fadeInOut ? 0.2 : 0.0)
                        .frame(width: fadeInOut ? (g.size.width * circleMultiplier)/2.1 : g.size.width/4, height: fadeInOut ? (g.size.width * circleMultiplier)/2.1 : g.size.width/4)
                    Circle()
                        .fill(Color(red: 255 / 255, green: 157 / 255, blue: 115 / 255))
                        .opacity(fadeInOut ? 0.3 : 0.0)
                        .frame(width: fadeInOut ? (g.size.width * circleMultiplier)/2.50384615384
                               : g.size.width/4, height: fadeInOut ? (g.size.width * circleMultiplier)/2.50384615384
                               : g.size.width/4)
                    Circle()
                        .fill(Color(red: 255 / 255, green: 167 / 255, blue: 61 / 255))
                        .opacity(fadeInOut ? 0.5 : 0.0)
                        .frame(width: fadeInOut ? (g.size.width * circleMultiplier)/3.1 : g.size.width/4, height: fadeInOut ? (g.size.width * circleMultiplier)/3.1 : g.size.width/4)
                    
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: g.size.width/12))
                            .imageScale(.medium)
                            .frame(width: g.size.width/4, height: g.size.width/4)
                            .foregroundColor(Color.white)
                            .background(fadeInOut ? Color.red : Color.yellow)
                            .clipShape(Circle())
                    }
                    .simultaneousGesture(TapGesture(count: 2).onEnded({
                        isRecording.toggle()
                        switch isRecording {
                        case true:
                            try? recorder.record()
                        case false:
                            recorder.stop()
                        }
                    }))
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                        .onEnded({_ in
                            if isRecording {
                                isRecording.toggle()
                                recorder.stop()
                            }
                            try? recorder.record()
                            isRecording.toggle()
                        })
                            .sequenced(before: DragGesture(minimumDistance: 0)
                                .onEnded({_ in
                                    isRecording.toggle()
                                    recorder.stop()
                                }))
                    )
                }
                .onChange(of: isRecording) {newValue in
                    withAnimation(Animation.easeInOut(duration: 0.6)) {
                        fadeInOut.toggle()
                    }
                }
                .frame(width: g.size.width, height: g.size.height, alignment: .center)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Stuff") {
                        showFiles.toggle()
                    }
                }
            }
            .navigationDestination(isPresented: $showFiles) {
                FilesView()
            }
        }
        .onDisappear {
            if isRecording {
                isRecording.toggle()
                recorder.stop()
            }
        }
    }
}
