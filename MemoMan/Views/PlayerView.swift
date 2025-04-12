import SwiftUI
import AVFoundation
import SwiftData

struct PlayerView: View {
  var recording : Recording
  @Binding var openedGroup : UUID?
  
  @StateObject private var viewModel : PlayerViewModel
  @State private var modelContainer : ModelContainer?
  
  @Environment(\.modelContext) var modelContext
  
  init(openedGroup: Binding<UUID?>, recording: Recording) throws {
    self.recording = recording
    self._openedGroup = openedGroup
    let player = LockScreenControlManager.shared.createPlayer(for: recording) ?? Player(recording: recording)
    let defaultViewModel = try PlayerViewModel(player: player, recording: recording)
    self._viewModel = StateObject(wrappedValue: defaultViewModel)
  }
  
  var body: some View {
    if recording.samples == nil {
      HStack {
        Spacer()
        ProgressView("Loading")
        Spacer()
      }
    }
    else {
      VStack {
        DisclosureGroup(isExpanded:
                          Binding(
                            get: { self.openedGroup == self.recording.id },
                            set: { newValue in
                              if newValue {
                                self.openedGroup = self.recording.id
                              } else if self.openedGroup == self.recording.id {
                                self.openedGroup = nil
                                viewModel.stop()
                              }
                            }
                          )
        ) {
          expandedContent
        } label: {
          Text(recording.name ?? "")
            .padding()
        }
        .onChange(of: openedGroup) {
          if openedGroup != self.recording.id {
            viewModel.stop()
          }
        }
      }
      .tint(Color("MemoManPurple"))
    }
  }
  
  @ViewBuilder
  private var expandedContent: some View {
    LazyVStack {
      waveformSection
      timeLabelsAndPlayButton
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
          get: { viewModel.player.currentTime / viewModel.duration },
          set: { newValue in
            viewModel.seek(to: newValue * viewModel.duration)
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
  private var timeLabelsAndPlayButton: some View {
    HStack {
      Text(timeString(from: viewModel.player.currentTime))
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
      Text(timeString(from: viewModel.duration))
    }
    .padding(.horizontal)
  }
  
  @ViewBuilder
  private var fileNameAndTranscriptionButtons: some View {
    HStack {
      FileNameButtonView(recording: recording)
      try? TranscriptionButtonView(modelContext: modelContext, modelID: recording.persistentModelID)
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
  
  private func timeString(from timeInterval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: timeInterval) ?? "00:00:00"
  }
}
