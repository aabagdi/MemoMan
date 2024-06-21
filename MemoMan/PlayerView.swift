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
    @State private var isOpened : Bool = false
    
    @ObservedObject var player = Player()
    
    var body: some View {
        DisclosureGroup(soundURL.lastPathComponent, isExpanded: $isOpened) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: player.isPlaying ? "stop.fill" : "play.fill")
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
                FileNameButtonView(soundURL: soundURL)
            }
        }
    }
    
    func deleteRecording() throws {
        do {
            try FileManager.default.removeItem(at: soundURL)
        } catch {
            throw Errors.FileDeletionError
        }
    }
}
