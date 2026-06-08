import SwiftUI

struct AchievementBannerView: View {
    let achievement: AchievementDefinition
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -140

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color("AppPrimary").opacity(0.3))
                    .frame(width: 44, height: 44)
                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(Color("AppAccent"))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(achievement.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color("AppSurface"))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color("AppAccent").opacity(0.4), lineWidth: 1)
                }
        }
        .shadow(color: Color("AppPrimary").opacity(0.28), radius: 12, y: 5)
        .padding(.horizontal, 16)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -140
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onDismiss()
                }
            }
        }
    }
}
