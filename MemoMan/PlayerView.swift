import SwiftUI
import AVFoundation

struct PlayerView: View {
    @State var soundURL: URL
    @Binding var openedGroup: URL?
    @State private var isOpened: Bool = false

    @StateObject private var viewModel: PlayerViewModel
    @State private var sliderValue: TimeInterval = 0

    init(soundURL: URL, openedGroup: Binding<URL?>) {
        self._soundURL = State(initialValue: soundURL)
        self._openedGroup = openedGroup
        let player = Player(soundURL: soundURL)
        self._viewModel = StateObject(wrappedValue: PlayerViewModel(player: player))
    }

    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { self.openedGroup == self.soundURL },
            set: { newValue in
                if newValue {
                    self.openedGroup = self.soundURL
                } else if self.openedGroup == self.soundURL {
                    self.openedGroup = nil
                    viewModel.stop()
                }
            }
        )) {
            VStack {
                Slider(value: $sliderValue, in: 0...viewModel.duration, onEditingChanged: { editing in
                    if editing {
                        viewModel.pause()
                    } else {
                        viewModel.seek(to: sliderValue)
                        viewModel.play()
                    }
                })
                .padding()
                .onChange(of: viewModel.currentTime) {
                    sliderValue = viewModel.currentTime
                }

                HStack {
                    Text(timeString(from: viewModel.currentTime))
                    Spacer()
                    Text(timeString(from: viewModel.duration))
                }
                .padding(.horizontal)

                HStack {
                    Spacer()
                    Image(systemName: viewModel.player.isPlaying ? "pause.fill" : "play.fill")
                        .onTapGesture {
                            if viewModel.player.isPlaying {
                                viewModel.pause()
                            } else {
                                viewModel.play()
                            }
                        }
                    Spacer()
                }
                Spacer()
                FileNameButtonView(soundURL: soundURL)
            }
        } label: {
            Text(soundURL.lastPathComponent)
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
