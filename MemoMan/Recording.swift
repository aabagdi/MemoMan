//
//  Recording.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/3/23.
//

import Foundation
import SwiftData

@Model class Recording {
    var id : UUID?
    var name : String?
    var url : URL?
    var date : String?
    
    init(name: String, url: URL) {
        self.id = UUID()
        self.name = name
        self.url = url
        let now = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        self.date =  dateFormatter.string(from: now)
    }
}
