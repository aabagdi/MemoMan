import SwiftUI
import AVFoundation
import SwiftData

struct PlayerView: View {
    var recording: Recording
    @Binding var openedGroup: UUID?
    @State var isOpened: Bool = false

    @StateObject private var viewModel: PlayerViewModel
    @State private var sliderValue: TimeInterval = 0

    init(openedGroup: Binding<UUID?>, recording: Recording) {
        self.recording = recording
        self._openedGroup = openedGroup
        let player = Player(recording: recording)
        self._viewModel = StateObject(wrappedValue: PlayerViewModel(player: player, recording: recording))
    }

    var body: some View {
        VStack {
            DisclosureGroup(isExpanded: isExpandedBinding()) {
                expandedContent
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
    
    @ViewBuilder
    private var expandedContent: some View {
        VStack {
            waveformSection
            timeLabels
            playPauseButton
            fileNameAndTranscriptionButtons
            creationDateLabel
        }
    }
    
    @ViewBuilder
    private var waveformSection: some View {
        if let samples = recording.samples, !samples.isEmpty {
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
    }
    
    @ViewBuilder
    private var timeLabels: some View {
        HStack {
            Text(timeString(from: viewModel.currentTime))
            Spacer()
            Text(timeString(from: viewModel.duration))
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var playPauseButton: some View {
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
    }
    
    @ViewBuilder
    private var fileNameAndTranscriptionButtons: some View {
        HStack {
            FileNameButtonView(recording: recording)
            TranscriptionButtonView(modelContainer: try! ModelContainer(for: Recording.self), modelID: recording.persistentModelID)
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private var creationDateLabel: some View {
        Text("Created on \(recording.getDateString())")
            .font(.footnote)
            .foregroundStyle(.gray)
            .padding()
    }
    
    @MainActor
    private func resetSlider() {
        sliderValue = 0
        viewModel.seek(to: 0)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval) ?? "00:00"
    }
    
    private func isExpandedBinding() -> Binding<Bool> {
        Binding(
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
        )
    }
}
