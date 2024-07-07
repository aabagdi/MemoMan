//
//  Recording.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/3/23.
//

import Foundation
import SwiftData

@Model class Recording {
    var id: UUID?
    var name : String?
    var date : String?
    var transcript : String? = nil
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        let now = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        self.date =  dateFormatter.string(from: now)
    }
}
