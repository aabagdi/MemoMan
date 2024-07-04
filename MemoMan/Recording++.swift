//
//  Recording+URL.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 6/30/24.
//

import Foundation

extension Recording {
    func returnURL() -> URL {
        return URL.documentsDirectory.appendingPathComponent("\(self.name ?? "").m4a")
    }
}
