//
//  Player.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 5/4/23.
//

import SwiftUI

struct PlayerView: View {
    @State private var isPlaying : Bool = false
    @EnvironmentObject var player : PlayerRecorder
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
                            player.play(url: soundURL)
                        case false:
                            player.pause()
                        }
                    }
                Spacer()
                Image(systemName: "goforward.5")
            }
        }
    }
}

