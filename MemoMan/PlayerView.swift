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
    let soundURL : URL
    
    var body: some View {
        var player = Player(soundURL: soundURL)
        VStack {
            HStack {
                Image(systemName: "gobackward.5")
                Spacer()
                Image(systemName: player.isPlaying() ? "pause.fill" : "play.fill")
                    .onTapGesture {
                        switch player.isPlaying() {
                        case true:
                            player.pause()
                        case false:
                            player.play()
                        }
                        print(player.isPlaying)
                    }
                Spacer()
                Image(systemName: "goforward.5")
            }
        }
        .onAppear {
        }
    }
}
