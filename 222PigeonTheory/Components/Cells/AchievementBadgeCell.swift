import SwiftUI

struct AchievementBadgeCell: View {
    let achievement: AchievementDefinition
    let unlocked: Bool

    var body: some View {
        CardContainer(accent: unlocked) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            unlocked
                                ? LinearGradient(
                                    colors: [Color("AppPrimary").opacity(0.5), Color("AppAccent").opacity(0.35)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color("AppBackground"), Color("AppSurface")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 62, height: 62)

                    if unlocked {
                        Circle()
                            .stroke(Color("AppAccent").opacity(0.6), lineWidth: 2)
                            .frame(width: 62, height: 62)
                    }

                    Image(systemName: achievement.iconName)
                        .font(.title2)
                        .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary").opacity(0.45))
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(spacing: 6) {
                    Text(achievement.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(unlocked ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)

                    Text(achievement.description)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.7)
                }

                ChipView(
                    text: unlocked ? "Unlocked" : "Locked",
                    icon: unlocked ? "checkmark.seal.fill" : "lock.fill",
                    style: unlocked ? .accent : .neutral
                )
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 170)
            .opacity(unlocked ? 1 : 0.72)
        }
    }
}
