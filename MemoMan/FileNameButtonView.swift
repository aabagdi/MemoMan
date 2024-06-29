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
        .padding()
        .alert("Enter new file name", isPresented: $showingAlert) {
            TextField("Enter your name", text: $newFilename)
            Button("OK") {
                recording.name = newFilename
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the new filename:")
        }
    }
}
