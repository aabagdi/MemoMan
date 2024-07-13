import SwiftUI
import SwiftData

struct FilesView: View {
    @State private var searchString : String = ""
    var body: some View {
        FilesListView(searchString: searchString, modelContainer: try! ModelContainer(for: Recording.self))
            .searchable(text: $searchString)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Recordings")
                            .font(.headline)
                    }
                }
            }
    }
}
