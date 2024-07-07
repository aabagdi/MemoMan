import Foundation
import Combine

extension PlayerView {
    @MainActor
    class PlayerViewModel: ObservableObject {
        @Published var currentTime: TimeInterval = 0
        var player: Player
        private var cancellables = Set<AnyCancellable>()
        private var seekingSubject = PassthroughSubject<TimeInterval, Never>()
        
        init(player: Player) {
            self.player = player
            self.player.objectWillChange
                .sink { [weak self] in
                    self?.currentTime = self?.player.currentTime ?? 0
                }
                .store(in: &cancellables)
            
            seekingSubject
                .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
                .sink { [weak self] time in
                    self?.player.seek(to: time)
                }
                .store(in: &cancellables)
        }
        
        func play() {
            player.play()
        }
        
        func pause() {
            player.pause()
        }
        
        func stop() {
            player.stop()
        }
        
        func seek(to time: TimeInterval) {
            seekingSubject.send(time)
        }
        
        var duration: TimeInterval {
            player.duration
        }
    }
}
