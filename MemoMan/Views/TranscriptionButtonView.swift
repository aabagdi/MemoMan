//
//  TranscriptionButtonView.swift
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
    @State private var showCopyAlert : Bool = false
    @State private var transcription : String
    
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
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(10)
                HStack {
                    Button("Cancel") {
                        showTranscription.toggle()
                    }
                    .buttonStyle(PurpleButtonStyle())
                    Button("Copy transcript") {
                        if self.transcription != "No transcription available. Either it's still loading or no speech was detected." {
                            copy()
                            showTranscription.toggle()
                        } else {
                            showCopyAlert.toggle()
                        }
                    }
                    .buttonStyle(PurpleButtonStyle())
                    .alert("No transcription available to copy!", isPresented: $showCopyAlert) {
                        Button("OK", role: .cancel) { showTranscription.toggle() }
                    }
                }
            }
        }
    }
    
    func copy() {
        UIPasteboard.general.setValue(self.transcription, forPasteboardType: UTType.plainText.identifier)
        return
    }
    
}
