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
   @State private var showErrorAlert = false
   @State private var currentError : Error?
   
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
            .accessibilityLabel("No recordings found")
      }
      else {
         List {
            ForEach(recordings.enumerated(), id: \.element.id) { index, recording in
               VStack(alignment: .leading, spacing: 0) {
                  HStack {
                     Text(recording.name ?? "No title")
                        .padding()
                        .accessibilityLabel("Recording title: \(recording.name ?? "No title")")
                        .accessibilityInputLabels(["select \(index + 1)", "\(index + 1)"])
                     Spacer()
                     Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("MemoManPurple"))
                        .rotationEffect(.degrees(openedGroup == recording.id ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: openedGroup)
                        .accessibilityHint(openedGroup == nil ? "Expand recording" : "Collapse recording")
                        .accessibilityLabel(openedGroup == nil ? "Tap to expand recording \(recording.name ?? "")" : "Tap to collapse recording \(recording.name ?? "")")
                        .accessibilityInputLabels(openedGroup == nil ? ["expand \(index + 1)", "open \(index + 1)", "expand \(recording.name ?? "")", "open \(recording.name ?? "")"] : ["close \(index + 1)", "close \(recording.name ?? "")"])
                  }
                  .contentShape(Rectangle())
                  .onTapGesture {
                     withAnimation {
                        if openedGroup == recording.id {
                           openedGroup = nil
                        } else {
                           openedGroup = recording.id
                        }
                     }
                  }
                  
                  if openedGroup == recording.id {
                     try? PlayerView(recording: recording)
                  }
               }
               .swipeActions(edge: .trailing) {
                  Button(role: .destructive) {
                     deleteRecording(recording)
                  } label: {
                     Label("Delete", systemImage: "trash")
                  }
                  .accessibilityLabel("Delete recording")
                  .accessibilityInputLabels(["delete", "remove", "trash"])
               }
               .swipeActions(edge: .leading) {
                  ShareLink(item: recording.fileURL) {
                     Label("Share", systemImage: "square.and.arrow.up")
                  }
                  .accessibilityLabel("Share recording")
                  .accessibilityInputLabels(["share", "send"])
               }
            }
         }
         .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
         } message: {
            Text(currentError?.localizedDescription ?? "An unknown error occurred.")
         }
      }
   }
   
   private func deleteRecording(_ recording: Recording) {
      let fileURL = recording.fileURL
      modelContext.delete(recording)
      do {
         try FileManager.default.removeItem(at: fileURL)
         try modelContext.save()
      } catch {
         currentError = Errors.FileDeletionError
         showErrorAlert = true
      }
   }
}
