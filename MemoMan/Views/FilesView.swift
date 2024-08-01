import SwiftUI
import SwiftData

struct FilesView: View {
    @State private var searchString : String = ""
    var body: some View {
        FilesListView(searchString: searchString)
            .searchable(text: $searchString)
            .autocorrectionDisabled()
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
