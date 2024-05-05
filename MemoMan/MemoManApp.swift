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
    
    let container : ModelContainer
    
    init() {
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
