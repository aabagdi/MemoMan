//
//  FileNameAlertView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 6/20/24.
//

import Foundation
import SwiftUI

struct FileNameButtonView : View {
    @State var recording : Recording
    @State private var showingAlert = false
    @State private var newFilename = ""
    
    var body: some View {
        Button("Change file name") {
            showingAlert.toggle()
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .alert("Enter new file name", isPresented: $showingAlert) {
            TextField("New file name", text: $newFilename)
            Button("OK", action: submit)
            Button("Cancel", role: .cancel) { }
        } message: {
        }
    }
    
    private func submit() {
        let oldURL = URL.documentsDirectory.appending(path: "\(recording.name ?? "").m4a")
        let newURL = URL.documentsDirectory.appending(path: "\(newFilename).m4a")
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
        } catch {
            print("\(error.localizedDescription)")
        }
        if !newFilename.isEmpty {
            recording.name = newFilename
        }
    }
}
