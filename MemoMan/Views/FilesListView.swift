//
//  FilesListView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/5/24.
//

import SwiftUI
import SwiftData

struct FilesListView: View {
    var searchString : String
    @Query var recordings : [Recording]
    @State private var openedGroup : UUID? = nil
    @StateObject private var recognizer : SpeechRecognizer
    @Environment(\.modelContext) var modelContext
    
    init(searchString: String, modelContainer: ModelContainer) {
        self._recognizer = StateObject(wrappedValue: SpeechRecognizer(modelContainer: modelContainer))
        self.searchString = searchString
        _recordings = Query(filter: #Predicate {
            if searchString.isEmpty {
                return true
            }
            else {
                return $0.name?.localizedStandardContains(searchString) ?? false
            }
            
        })
    }
    
    var body: some View {
        if recordings.isEmpty {
            Text("No recordings found!")
        }
        else {
            VStack {
                List {
                    ForEach(recordings.reversed(), id: \.self) { recording in
                        PlayerView(openedGroup: $openedGroup, recording: recording)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    print("deleting recording")
                                    modelContext.delete(recording)
                                    do {
                                        try FileManager.default.removeItem(at: recording.fileURL)
                                    } catch {
                                        print("Error removing item URL")
                                    }
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print("Model Context not saving correctly")
                                    }
                                }
                            }
                            .swipeActions(edge: .leading) {
                                ShareLink(item: recording.fileURL) {
                                    VStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share")
                                    }
                                }
                            }
                    }
                }
            }
            .task {
                for recording in recordings {
                    
                    await recognizer.transcribe(recordingID: recording.persistentModelID)
                }
            }
        }
    }
}
