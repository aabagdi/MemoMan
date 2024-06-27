import SwiftUI
import AVFoundation
import SwiftData

struct FilesView: View {
    //@State private var recordings: [URL] = []
    @State private var openedGroup: URL? = nil
    @Query var recordings: [Recording]

    var body: some View {
        VStack {
            List {
                ForEach(recordings.reversed(), id: \.self) { recording in
                    PlayerView(soundURL: recording.url!, openedGroup: $openedGroup)
                }
            }
        }
        /*.onAppear {
            self.getRecordings()
        }*/
    }
    
    /*func getRecordings() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            self.recordings = result.sorted { $0.lastPathComponent < $1.lastPathComponent }
        } catch {
            print(error.localizedDescription)
        }
    }*/
}
