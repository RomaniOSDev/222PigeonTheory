import Combine
import Foundation
import SwiftUI

final class FocusSessionViewModel: ObservableObject {
    enum State {
        case idle
        case running
        case paused
        case completed
    }

    @Published var selectedMinutes = 10
    @Published var remainingSeconds = 0
    @Published var state: State = .idle
    @Published var showStoryEditor = false

    let durationOptions = [5, 10, 15]
    private var timerCancellable: AnyCancellable?
    private var totalSeconds = 0

    func start() {
        totalSeconds = selectedMinutes * 60
        remainingSeconds = totalSeconds
        state = .running
        HapticManager.mediumTap()
        HapticManager.playTickSound()
        startTimer()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        timerCancellable?.cancel()
    }

    func resume() {
        guard state == .paused else { return }
        state = .running
        startTimer()
    }

    func cancel() {
        timerCancellable?.cancel()
        state = .idle
        remainingSeconds = 0
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            if state == .paused, remainingSeconds > 0 {
                resume()
            }
        case .background, .inactive:
            if state == .running {
                pause()
            }
        @unknown default:
            break
        }
    }

    private func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            complete()
            return
        }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            complete()
        }
    }

    private func complete() {
        timerCancellable?.cancel()
        state = .completed
        HapticManager.success()
        HapticManager.playSuccessSound()
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1 - Double(remainingSeconds) / Double(totalSeconds)
    }

    var timeLabel: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
