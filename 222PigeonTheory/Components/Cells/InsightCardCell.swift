import SwiftUI

struct InsightCardCell: View {
    let title: String
    let subtitle: String
    let count: Int
    let peakCount: Int
    var isFavored = false
    var isExpanded = false
    var expandable = true
    var detail: String?
    var onFavorite: () -> Void
    var onToggle: () -> Void

    var body: some View {
        CardContainer(accent: isFavored) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    countRing

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    Spacer()

                    if expandable {
                        Button(action: onToggle) {
                            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                                .foregroundStyle(Color("AppAccent"))
                        }
                        .buttonStyle(.plain)
                    }
                }

                GeometryReader { geo in
                    let width = peakCount > 0 ? geo.size.width * CGFloat(count) / CGFloat(peakCount) : 0
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color("AppBackground"))
                            .frame(height: 8)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(width, count > 0 ? 12 : 0), height: 8)
                    }
                }
                .frame(height: 8)

                if isExpanded, let detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                HStack {
                    if isFavored {
                        ChipView(text: "Favored", icon: "star.fill", style: .accent)
                    }
                    Spacer()
                    Button(isFavored ? "Unfavorite" : "Favorite", action: onFavorite)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                        .frame(minHeight: 44)
                }
            }
            .padding(14)
        }
    }

    private var countRing: some View {
        ZStack {
            Circle()
                .stroke(Color("AppBackground"), lineWidth: 4)
                .frame(width: 44, height: 44)
            Circle()
                .trim(from: 0, to: peakCount > 0 ? CGFloat(count) / CGFloat(peakCount) : 0)
                .stroke(Color("AppAccent"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 44, height: 44)
                .rotationEffect(.degrees(-90))
            Text("\(count)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }
}

struct StatBlockCell: View {
    let title: String
    let icon: String
    let items: [String]

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundStyle(Color("AppAccent"))
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                }

                if items.isEmpty {
                    Text("No data yet")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppAccent"))
                                .frame(width: 22, height: 22)
                                .background(Color("AppAccent").opacity(0.15))
                                .clipShape(Circle())
                            Text(item)
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer()
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}
