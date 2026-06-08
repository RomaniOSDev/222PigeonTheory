import SwiftUI

struct CardContainer<Content: View>: View {
    var accent: Bool = false
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color("AppSurface"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                accent
                                    ? Color("AppAccent").opacity(0.45)
                                    : Color("AppPrimary").opacity(0.12),
                                lineWidth: accent ? 1.5 : 1
                            )
                    }
                    .shadow(color: Color("AppPrimary").opacity(0.1), radius: accent ? 10 : 6, y: 3)
            }
    }
}

struct ChipView: View {
    let text: String
    var icon: String?
    var style: ChipStyle = .neutral

    enum ChipStyle {
        case neutral, accent, primary, outline
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(background)
        .clipShape(Capsule())
    }

    private var foreground: Color {
        switch style {
        case .neutral: return Color("AppTextSecondary")
        case .accent, .primary: return Color("AppTextPrimary")
        case .outline: return Color("AppAccent")
        }
    }

    @ViewBuilder
    private var background: some View {
        switch style {
        case .neutral:
            Color("AppBackground").opacity(0.7)
        case .accent:
            Color("AppAccent").opacity(0.28)
        case .primary:
            Color("AppPrimary").opacity(0.28)
        case .outline:
            Color.clear.overlay {
                Capsule().stroke(Color("AppAccent").opacity(0.5), lineWidth: 1)
            }
        }
    }
}

struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: Color("AppPrimary").opacity(0.45), radius: 10, y: 5)

                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppSurface"))
            }
        }
        .buttonStyle(.plain)
    }
}

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?
    var trailing: String?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("AppAccent").opacity(0.18))
                    .clipShape(Capsule())
            }
        }
    }
}
