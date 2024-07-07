//
//  TranscriptionView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/6/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct TranscriptionButtonView : View {
    @State private var showTranscription : Bool = false
    private var transcription : String
    
    init(transcription: String) {
        self.transcription = transcription
    }
    
    var body: some View {
        Button("Recording transcript") {
            showTranscription.toggle()
        }
        .buttonStyle(PurpleButtonStyle())
        .sheet(isPresented: $showTranscription) {
            VStack {
                Text("Transcription")
                    .font(.headline)
                    .padding()
                TextEditor(text: .constant(transcription))
                    .padding(8)
                     .background(
                         RoundedRectangle(cornerRadius: 10)
                             .stroke(Color.gray, lineWidth: 1)
                     )
                     .cornerRadius(10)
                Button("Copy transcript") {
                    copy()
                    showTranscription.toggle()
                }
                .buttonStyle(PurpleButtonStyle())
                Button("Cancel") {
                    showTranscription.toggle()
                }
                .buttonStyle(PurpleButtonStyle())
            }
        }
    }
    
    func copy() {
        UIPasteboard.general.setValue(self.transcription, forPasteboardType: UTType.plainText.identifier)
        return
    }
    
}
