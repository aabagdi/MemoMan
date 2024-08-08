import SwiftUI
import AVFoundation
import SwiftData

struct PlayerView: View {
    var recording: Recording
    @Binding var openedGroup: UUID?

    @StateObject private var viewModel : PlayerViewModel
    @State private var sliderValue : TimeInterval = 0

    init(openedGroup: Binding<UUID?>, recording: Recording) {
        self.recording = recording
        self._openedGroup = openedGroup
        let player = Player(recording: recording)
        self._viewModel = StateObject(wrappedValue: PlayerViewModel(player: player, recording: recording))
    }

    var body: some View {
        VStack {
            DisclosureGroup(isExpanded: Binding(
                get: { self.openedGroup == self.recording.id },
                set: { newValue in
                    if newValue {
                        self.openedGroup = self.recording.id
                    } else if self.openedGroup == self.recording.id {
                        self.openedGroup = nil
                        viewModel.stop()
                        resetSlider()
                    }
                }
            )) {
                VStack {
                    if !(recording.samples?.isEmpty ?? false) {
                        VStack {
                            Spacer()
                            WaveformView(progress: Binding(
                                get: { sliderValue / viewModel.duration },
                                set: { newValue in
                                    sliderValue = newValue * viewModel.duration
                                    viewModel.seek(to: sliderValue)
                                }
                            ), recording: recording, duration: viewModel.duration, onEditingChanged: { isEditing in
                                if isEditing {
                                    viewModel.pause()
                                } else {
                                    viewModel.play()
                                }
                            }, scaleFactor: 1.0, waveformHeight: 60)
                            .padding()
                        }
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
                    .padding(.top)

                    HStack {
                        FileNameButtonView(recording: recording)
                        TranscriptionButtonView(modelContainer: try! ModelContainer(for: Recording.self), modelID: recording.persistentModelID)
                    }
                    .padding(.top)

                    Text("Created on \(recording.getDateString())")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .padding()
                }
            } label: {
                Text(recording.name ?? "")
                    .padding()
            }
            .onChange(of: openedGroup) {
                if openedGroup != self.recording.id {
                    viewModel.stop()
                    resetSlider()
                }
            }
            .onReceive(viewModel.$currentTime) { newValue in
                sliderValue = newValue
            }
        }
    }
    
    @MainActor
    private func resetSlider() {
        sliderValue = 0
        viewModel.seek(to: 0)
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
