import Foundation
import SwiftUI
import AVFoundation

struct FilesView: View {
    @State private var recordings: [URL] = []
    @State private var isPlaying: Bool = false
    @State private var openedGroup: URL? = nil

    var body: some View {
        VStack {
            List {
                ForEach(recordings.reversed(), id: \.self) { recording in
                    VStack {
                        PlayerView(soundURL: recording, openedGroup: $openedGroup)
                    }
                }
            }
        }
        .onAppear {
            self.getRecordings()
        }
    }
    
    func getRecordings() {
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            self.recordings.removeAll()
            for i in result {
                self.recordings.append(i)
            }
            recordings.sort {
                $0.lastPathComponent < $1.lastPathComponent
            }
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
