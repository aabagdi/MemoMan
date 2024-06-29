import SwiftUI
import AVFoundation
import SwiftData

struct FilesView: View {
    @State private var openedGroup: URL? = nil
    @Query var recordings: [Recording]

    var body: some View {
        VStack {
            List {
                ForEach(recordings.reversed(), id: \.self) { recording in
                    PlayerView(openedGroup: $openedGroup, recording: recording)
                }
            }
        }
    }
}
