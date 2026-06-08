import AudioToolbox
import UIKit

enum HapticManager {
    static func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func playSuccessSound() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playTickSound() {
        AudioServicesPlaySystemSound(1003)
    }

    static func playLightConfirmSound() {
        AudioServicesPlaySystemSound(1110)
    }

    static func playFavoriteSound() {
        AudioServicesPlaySystemSound(1103)
    }

    static func saveFeedback() {
        mediumTap()
        playSuccessSound()
    }
}
