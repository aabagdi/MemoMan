import SwiftUI
import AVFoundation

struct PlayerView: View {
    @State var recording : Recording
    @Binding var openedGroup : URL?

    @StateObject private var viewModel : PlayerViewModel
    @State private var sliderValue : TimeInterval = 0

    init(openedGroup: Binding<URL?>, recording: Recording) {
        self.recording = recording
        self._openedGroup = openedGroup
        let player = Player(recording: recording)
        self._viewModel = StateObject(wrappedValue: PlayerViewModel(player: player))
    }

    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { self.openedGroup == self.recording.url },
            set: { newValue in
                if newValue {
                    self.openedGroup = self.recording.url
                } else if self.openedGroup == self.recording.url {
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
                HStack {
                    ShareLink(item: recording.url!) {
                        Image(systemName: "square.and.arrow.up.circle")
                        .font(.system(size: 30))
                    }
                    FileNameButtonView(recording: recording)
                }
                Text("Created on \(recording.date ?? "")")
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        } label: {
            Text(recording.name ?? "")
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
