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
import CoreData
import CloudKit

struct RecordView: View {
    @State private var isRecording : Bool = false
    @State private var fadeInOut : Bool = false
    @State private var showFiles : Bool = false
    @State private var animationAmount : Double = 1.0
    //@StateObject var recorder : Recorder = Recorder()
    
    var body: some View {
        NavigationStack {
            GeometryReader { g in
                ZStack {
                    Circle()
                        .fill(Color(red: 255 / 255, green: 160 / 255, blue: 69 / 255))
                        .opacity(fadeInOut ? 0.2 : 0.0)
                        .frame(width: fadeInOut ? (g.size.width)/2.1 : g.size.width/4, height: fadeInOut ? (g.size.width )/2.1 : g.size.width/4)
                    Circle()
                        .fill(Color(red: 255 / 255, green: 157 / 255, blue: 115 / 255))
                        .opacity(fadeInOut ? 0.3 : 0.0)
                        .frame(width: fadeInOut ? (g.size.width )/2.50384615384
                               : g.size.width/4, height: fadeInOut ? (g.size.width )/2.50384615384
                               : g.size.width/4)
                    Circle()
                        .fill(Color(red: 255 / 255, green: 167 / 255, blue: 61 / 255))
                        .opacity(fadeInOut ? 0.5 : 0.0)
                        .frame(width: fadeInOut ? (g.size.width )/3.1 : g.size.width/4, height: fadeInOut ? (g.size.width )/3.1 : g.size.width/4)
                    
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: g.size.width/12))
                            .imageScale(.medium)
                            .frame(width: g.size.width/4, height: g.size.width/4)
                            .foregroundColor(Color.white)
                            .background(fadeInOut ? Color.red : Color(red: 166/255, green: 104/255, blue: 247/255))
                            .clipShape(Circle())
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .scaleEffect(isRecording ? 2.4 : animationAmount)
                            .opacity(isRecording ? 0 : 2 - animationAmount)
                            .animation(isRecording ? Animation.easeOut(duration: animationAmount)
                                .repeatForever(autoreverses: false) : .default, value: isRecording)
                    )
                    .onChange(of: isRecording){
                        animationAmount = isRecording ? 2.0 : 1.0
                    }
                    .simultaneousGesture(TapGesture(count: 2).onEnded({
                        isRecording.toggle()
                        switch isRecording {
                        case true:
                            //recorder.record()
                            print("recording")
                        case false:
                            //recorder.stop()
                            print("stopped")
                        }
                    }))
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                        .onEnded({_ in
                            if isRecording {
                                isRecording.toggle()
                                //recorder.stop()
                            }
                            //recorder.record()
                            isRecording.toggle()
                        })
                            .sequenced(before: DragGesture(minimumDistance: 0)
                                .onEnded({_ in
                                    isRecording.toggle()
                                    //recorder.stop()
                                }))
                    )
                }
                .onChange(of: isRecording) {
                    withAnimation(Animation.easeInOut(duration: 0.6)) {
                        fadeInOut.toggle()
                    }
                }
                .frame(width: g.size.width, height: g.size.height, alignment: .center)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Stuff") {
                        if isRecording {
                            isRecording.toggle()
                            //recorder.stop()
                        }
                        showFiles.toggle()
                    }
                }
            }
        }
    }
}
