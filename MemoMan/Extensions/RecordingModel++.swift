//
//  Recording+URL.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 6/30/24.
//

import Foundation

extension Recording {
  var fileURL : URL {
    return URL.documentsDirectory.appendingPathComponent("\(self.name ?? "").m4a")
  }
  
  func getDateString() -> String {
    guard let date = self.date else { return  "" }
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
  }
}
