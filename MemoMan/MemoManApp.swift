//
//  MemoManApp.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 4/7/23.
//

import SwiftUI
import SwiftData
import AVFoundation
import TipKit

@main
struct MemoManApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
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
        .task {
          do {
            try Tips.configure([.displayFrequency(.immediate),
                                .datastoreLocation(.applicationDefault)
            ])
          } catch {
            print("Error initializing TipKit \(error.localizedDescription)")
          }
        }
    }
    .modelContext(ModelContext(container))
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    application.beginReceivingRemoteControlEvents()
    return true
    
  }
}
