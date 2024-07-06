//
//  iCloudManager.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/5/24.
//

import Foundation
import SwiftData
import CloudKit

actor iCloudManager {
    let coordinator = NSFileCoordinator()
    
    
    
    func pushToiCloud(recording: Recording) throws {
        var coordinationError: NSError?
        var writeError: Error?
        coordinator.coordinate(writingItemAt: recording.fileURL, options: [.forDeleting], error: &coordinationError) { url in
            do {
                try Recording.write(to: url, options: .atomic)
            } catch {
                writeError = error
            }
        }
        
    }
    
    func pullFromiCloud(recording: Recording) {
        
    }
    
    
    
}
