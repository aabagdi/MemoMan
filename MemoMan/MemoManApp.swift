//
//  MemoManApp.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 4/7/23.
//

import SwiftUI
import SwiftData
import AVFoundation

@main
struct MemoManApp: App {
    
    let container : ModelContainer
    
    init() {
        UserDefaults.standard.register(defaults: ["sampleRate" : 44_100, "audioQuality" : AVAudioQuality.max.rawValue])
        do {
            container = try ModelContainer(for: Recording.self)
        } catch {
            fatalError("Could not initialize container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RecordView()
        }
        .modelContainer(container)
    }
}
