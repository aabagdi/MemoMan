import Combine
import Foundation

class PlayerViewModel: ObservableObject {
    @Published var currentTime: TimeInterval = 0
    let player: Player
    
    init(player: Player) {
        self.player = player
        self.player.objectWillChange
            .sink { [weak self] in
                self?.currentTime = self?.player.currentTime ?? 0
            }
            .store(in: &cancellables)
    }
    
    func play(soundURL: URL) throws {
        try player.play(soundURL: soundURL)
    }
    
    func pause() {
        player.pause()
    }
    
    func seek(to time: TimeInterval) {
        player.seek(to: time)
        self.currentTime = time
    }
    
    var duration: TimeInterval {
        player.duration
    }
    
    private var cancellables = Set<AnyCancellable>()
}
