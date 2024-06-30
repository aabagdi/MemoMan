import SwiftUI
import AVFoundation
import SwiftData

struct FilesView: View {
    @State private var openedGroup: UUID? = nil
    @Query var recordings: [Recording]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        if recordings.isEmpty {
            Text("You have no recordings!")
        }
        else {
            VStack {
                List {
                    ForEach(recordings.reversed(), id: \.self) { recording in
                        PlayerView(openedGroup: $openedGroup, recording: recording)
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    modelContext.delete(recording)
                                    do {
                                        try FileManager.default.removeItem(at: recording.returnURL())
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
                    }
                }
            }
        }
    }
}
