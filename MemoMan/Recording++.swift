//
//  Recording+URL.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 6/30/24.
//

import Foundation

extension Recording {
    var fileURL : URL {
        switch UserDefaults.standard.bool(forKey: "iCloudEnabled") {
            case false:
                return URL.documentsDirectory.appendingPathComponent("\(self.name ?? "").m4a")
            case true:
                let containerIdentifier = "iCloud.com.aabagdi.MemoMan"
                guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier) else {
                    print("Can't get UbiquityContainer url, saving file locally")
                    return URL.documentsDirectory.appendingPathComponent("\(self.name ?? "").m4a")
                }
                return containerURL.appendingPathComponent("Documents").appendingPathComponent("\(self.name ?? "").m4a")
        }
    }
}
