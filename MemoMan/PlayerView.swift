import SwiftUI
import AVFoundation

struct PlayerView: View {
    @State var soundURL: URL
    @State private var isOpened: Bool = false
    
    @StateObject private var viewModel: PlayerViewModel
    
    init(soundURL: URL) {
        self._soundURL = State(initialValue: soundURL)
        let player = Player()
        self._viewModel = StateObject(wrappedValue: PlayerViewModel(player: player))
    }
    
    var body: some View {
        DisclosureGroup(soundURL.lastPathComponent, isExpanded: $isOpened) {
            VStack {
                Slider(value: $viewModel.currentTime, in: 0...viewModel.duration, onEditingChanged: { editing in
                    if !editing {
                        viewModel.seek(to: viewModel.currentTime)
                    }
                })
                .padding()
                
                HStack {
                    Spacer()
                    Image(systemName: viewModel.player.isPlaying ? "stop.fill" : "play.fill")
                        .onTapGesture {
                            switch viewModel.player.isPlaying {
                            case true:
                                viewModel.pause()
                            case false:
                                do {
                                    try viewModel.play(soundURL: soundURL)
                                } catch {
                                    print("Failed to play audio: \(error.localizedDescription)")
                                }
                            }
                        }
                    Spacer()
                }
                Spacer()
                FileNameButtonView(soundURL: soundURL)
            }
        }
    }
    
    func deleteRecording() throws {
        do {
            try FileManager.default.removeItem(at: soundURL)
        } catch {
            throw Errors.FileDeletionError
        }
    }
}
