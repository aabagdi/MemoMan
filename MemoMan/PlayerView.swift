//
//  Player.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 5/4/23.
//

import SwiftUI
import AVFoundation

struct PlayerView: View {
    @State private var isPlaying : Bool = false
    @State private var player : AVAudioPlayer!
    let soundURL : URL
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "gobackward.5")
                Spacer()
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .onTapGesture {
                        isPlaying.toggle()
                        switch isPlaying {
                        case true:
                            player.play()
                        case false:
                            player.pause()
                        }
                    }
                Spacer()
                Image(systemName: "goforward.5")
            }
        }
        .onAppear {
            let sound = soundURL
            self.player = try! AVAudioPlayer(contentsOf: sound)
        }
    }
}

