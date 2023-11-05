//
//  MemoManApp.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 4/7/23.
//

import SwiftUI
import SwiftData

@main
struct MemoManApp: App {
    var body: some Scene {
        WindowGroup {
            RecordView()
        }
        .modelContainer(for: Recording.self)
    }
}
