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
        let player = Player(soundURL: soundURL)
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: player.isPlaying() ? "pause.fill" : "play.fill")
                    .onTapGesture {
                        self.isPlaying.toggle()
                        switch player.isPlaying() {
                        case true:
                            player.pause()
                        case false:
                            player.play()
                        }
                        print(self.isPlaying)
                    }
                Spacer()
            }
            Spacer()
        }
        .onAppear {
        }
    }
}
