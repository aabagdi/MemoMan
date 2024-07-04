//
//  FileNameAlertView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 6/20/24.
//

import Foundation
import SwiftUI

struct FileNameButtonView : View {
    var recording : Recording
    
    @State private var showingAlert = false
    @State private var nameExistsAlert = false
    @State private var emptyNameAlert = false
    @State private var newFilename = ""
    
    var body: some View {
        Button("Change file name") {
            showingAlert.toggle()
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .alert("Enter new file name", isPresented: $showingAlert) {
            TextField("New file name", text: $newFilename)
                .autocorrectionDisabled()
            Button("OK", action: submit)
            Button("Cancel", role: .cancel) { }
        } message: { }
        .alert("Recording with same name already exists!", isPresented: $nameExistsAlert) {
            Button("OK", role: .cancel) { }
        } message: { }
        .alert("Recording name can't be empty!", isPresented: $emptyNameAlert) {
            Button("OK", role: .cancel) { }
        } message: { }
    }
    
    private func submit() {
        if newFilename.isEmpty {
            emptyNameAlert.toggle()
            return
        }
        let oldURL = recording.returnURL
        let newURL = URL.documentsDirectory.appending(path: "\(newFilename).m4a")
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
        } catch {
            print("\(error.localizedDescription)")
            newFilename = ""
            nameExistsAlert.toggle()
            return
        }
        recording.name = newFilename
    }
}
