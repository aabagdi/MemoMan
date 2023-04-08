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
    var body: some View {
        GeometryReader { g in
            VStack {
                Text("Recording...")
                    .font(.title)
                    .bold()
                    .foregroundColor(.red)
                    .onChange(of: isRecording) {newValue in
                        withAnimation(Animation.easeInOut(duration: 0.6)) {
                            fadeInOut.toggle()
                        }
                    }.opacity(fadeInOut ? 1.0 : 0.0)
                ZStack {
                    /*Circle()
                        .fill(Color(red: 255 / 255, green: 157 / 255, blue: 86 / 255))
                        .opacity(0.1)
                        .frame(width: isRecording ? g.size.width/2 : g.size.width/4, height: isRecording ? g.size.width/2 : g.size.width/4)
                    Circle()
                        .fill(Color(red: 255 / 255, green: 157 / 255, blue: 115 / 255))
                        .opacity(0.3)
                        .frame(width: isRecording ? g.size.width : g.size.width/4, height: isRecording ? g.size.width : g.size.width/4)
                    Circle()
                        .fill(Color(red: 255 / 255, green: 160 / 255, blue: 69 / 255))
                        .opacity(0.7)
                        .frame(width: g.size.width/4, height: g.size.width/4)
                     */
                    Button(action: {}) {
                        Image(systemName: "mic.fill")
                            .font(.largeTitle)
                            .imageScale(.medium)
                            .frame(width: g.size.width/4, height: g.size.width/4)
                            .foregroundColor(Color.white)
                            .background(Color.yellow)
                            .clipShape(Circle())
                    }
                    .simultaneousGesture(TapGesture(count: 2).onEnded({
                        print("Double tap")
                        isRecording.toggle()
                        print(isRecording)
                    }))
                    .simultaneousGesture(LongPressGesture(minimumDuration: 0.5)
                        .onEnded({_ in
                            isRecording.toggle()
                            print(isRecording)
                            print("Held press")
                        })
                            .sequenced(before: DragGesture(minimumDistance: 0)
                                .onEnded({_ in
                                    isRecording.toggle()
                                    print(isRecording)
                                    print("Released")
                                }))
                    )
                }
            }.frame(width: g.size.width, height: g.size.height, alignment: .center)
        }
    }
}

struct RecordViewPreview : PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
