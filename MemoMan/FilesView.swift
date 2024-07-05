import SwiftUI
import SwiftData

struct FilesView: View {
    @State private var searchString : String = ""
    var body: some View {
        FilesListView(sort: SortDescriptor(\Recording.name), searchString: searchString)
            .searchable(text: $searchString)
    }
}
