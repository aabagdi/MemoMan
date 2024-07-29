//
//  Recording.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/3/23.
//

import Foundation
import SwiftData

@Model final class Recording {
    var id: UUID?
    var name : String?
    var date : Date?
    var samples : [Float]? = nil
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        let now = Date.now
        self.date = now
    }
}
