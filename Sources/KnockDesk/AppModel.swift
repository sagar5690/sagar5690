import AppKit
import Combine

@MainActor
final class AppModel: ObservableObject {
    @Published var isListening = false
    @Published var selectedAction: KnockAction = .playPause
    @Published var appBundleIdentifier = "com.google.Chrome"
    @Published var statusMessage = "Idle"

    private let detector = KnockDetector()
    private let actionRunner = ActionRunner()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        detector.onKnock = { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                self.statusMessage = "Knock detected at \(Date().formatted(date: .omitted, time: .standard))"
                self.actionRunner.run(self.selectedAction, appBundleIdentifier: self.appBundleIdentifier)
            }
        }

        $isListening
            .dropFirst()
            .sink { [weak self] enabled in
                guard let self else { return }
                if enabled {
                    detector.start()
                    statusMessage = "Listening for knocks…"
                } else {
                    detector.stop()
                    statusMessage = "Detection paused"
                }
            }
            .store(in: &cancellables)
    }
}
