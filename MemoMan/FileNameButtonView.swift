//
//  FileNameAlertView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 6/20/24.
//

import Foundation
import SwiftUI

struct FileNameButtonView : View {
    @State var soundURL : URL
    @State private var showingAlert = false
    @State private var newFilename = ""
    
    var body: some View {
        Button("Change file name") {
            showingAlert.toggle()
        }
        .padding()
        .alert("Enter new file name", isPresented: $showingAlert) {
            TextField("Enter your name", text: $newFilename)
            Button("OK", action: submit)
        } message: {
            Text("Enter the new filename:")
        }
    }
    
    func submit() {
        let oldURL = soundURL
        var newURL = soundURL.deletingLastPathComponent()
        newURL = newURL.appendingPathComponent("\(newFilename).m4a")
        soundURL = newURL
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
        } catch {
            print("File rename error")
        }
    }
}
