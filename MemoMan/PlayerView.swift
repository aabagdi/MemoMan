//
//  Player.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 5/4/23.
//

import SwiftUI
import AVFoundation

struct PlayerView: View {
    let soundURL : URL
    @ObservedObject var player = Player()
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .onTapGesture {
                        switch player.isPlaying {
                        case true:
                            player.pause()
                        case false:
                            try? player.play(soundURL: soundURL)
                        }
                    }
                Spacer()
            }
            Spacer()
        }
    }
}
