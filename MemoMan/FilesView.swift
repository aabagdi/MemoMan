import SwiftUI
import SwiftData

struct FilesView: View {
    @State private var searchString : String = ""
    @State private var openedGroup : UUID? = nil
    @Query var recordings : [Recording]
    @Environment(\.modelContext) var modelContext
    
    var filtered: [Recording] {
        guard searchString.isEmpty == false else { return recordings }
        return recordings.filter { $0.name!.localizedStandardContains(searchString) }
    }
    
    var body: some View {
        if recordings.isEmpty {
            Text("You have no recordings!")
        }
        else {
            VStack {
                List {
                    ForEach(filtered.reversed(), id: \.self) { recording in
                        PlayerView(openedGroup: $openedGroup, recording: recording)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", systemImage: "trash", role: .destructive) {
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
                .searchable(text: $searchString)
            }
        }
    }
}
