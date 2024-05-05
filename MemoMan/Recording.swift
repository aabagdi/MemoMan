//
//  Recording.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 11/3/23.
//

import Foundation
import SwiftData

@Model class Recording {
    var name : String?
    var date : Date?
    var url : URL?
    
    init(name: String, url: URL) {
        self.name = name
        self.date = .now
        self.url = url
    }
}
