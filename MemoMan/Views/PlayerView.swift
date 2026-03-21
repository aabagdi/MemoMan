import SwiftUI
import AVFoundation
import SwiftData

struct PlayerView: View {
   var recording : Recording
   
   @StateObject private var viewModel : PlayerViewModel
   
   @Environment(\.modelContext) var modelContext
   
   init(recording: Recording) throws {
      self.recording = recording
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
      } else {
         expandedContent
            .onDisappear {
               viewModel.stop()
            }
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
            .accessibilityLabel("Current time, \(timeString(from: viewModel.player.currentTime))")
         Spacer()
         Image(systemName: viewModel.player.isPlaying ? "pause.fill" : "play.fill")
            .accessibilityLabel(viewModel.player.isPlaying ? "Pause" : "Play")
            .accessibilityInputLabels(viewModel.player.isPlaying ? ["pause", "stop"] : ["play", "resume"])
            .accessibilityAddTraits(.isButton)
            .onTapGesture {
               if viewModel.player.isPlaying {
                  viewModel.pause()
               } else {
                  viewModel.play()
               }
            }
         Spacer()
         Text(timeString(from: viewModel.duration))
            .accessibilityLabel("Duration, \(timeString(from: viewModel.duration))")
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
         .accessibilityLabel("Created on \(recording.getDateString())")
   }
   
   private func timeString(from timeInterval: TimeInterval) -> String {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.hour, .minute, .second]
      formatter.zeroFormattingBehavior = .pad
      return formatter.string(from: timeInterval) ?? "00:00:00"
   }
}
