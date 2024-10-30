//
//  FilesListView.swift
//  MemoMan
//
//  Created by Aadit Bagdi on 7/5/24.
//

import SwiftUI
import SwiftData

struct FilesListView: View {
    var searchString: String
    @Query private var recordings : [Recording]
    @State private var openedGroup : UUID? = nil
    
    @Environment(\.modelContext) private var modelContext
    
    init(searchString: String) {
        self.searchString = searchString
        _recordings = Query(filter: searchString.isEmpty ? nil : #Predicate<Recording> { recording in
            recording.name?.localizedStandardContains(searchString) ?? false
        }, sort: [SortDescriptor(\Recording.date, order: .reverse)])
    }
    
    var body: some View {
        if recordings.isEmpty {
            Text("No recordings found!")
        }
        else {
            List(recordings) { recording in
                try? PlayerView(openedGroup: $openedGroup, recording: recording)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteRecording(recording)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .disabled(recording.samples == nil)
                    .swipeActions(edge: .leading) {
                        ShareLink(item: recording.fileURL) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                    .disabled(recording.samples == nil)
            }
        }
    }
    
    private func deleteRecording(_ recording: Recording) {
        modelContext.delete(recording)
        do {
            try FileManager.default.removeItem(at: recording.fileURL)
            try modelContext.save()
        } catch {
            print("Error deleting recording: \(error.localizedDescription)")
        }
    }
}
