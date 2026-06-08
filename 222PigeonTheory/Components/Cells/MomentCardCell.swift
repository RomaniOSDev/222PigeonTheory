import SwiftUI

struct MomentCardCell: View {
    let moment: MemoryMoment
    var isHighlighted = false
    var onTagTap: ((String) -> Void)?

    var body: some View {
        CardContainer(accent: isHighlighted) {
            HStack(alignment: .top, spacing: 14) {
                emojiBadge

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Text(moment.text)
                            .font(.body)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(4)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if moment.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption)
                                .foregroundStyle(Color("AppAccent"))
                                .padding(6)
                                .background(Color("AppAccent").opacity(0.15))
                                .clipShape(Circle())
                        }
                    }

                    HStack(spacing: 8) {
                        ChipView(text: DateFormatting.relativeLabel(for: moment.timestamp), icon: "clock", style: .neutral)
                        ChipView(text: DateFormatting.detailLabel(for: moment.timestamp), style: .outline)
                    }

                    if !moment.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(moment.tags, id: \.self) { tag in
                                    Button {
                                        HapticManager.lightTap()
                                        onTagTap?(tag)
                                    } label: {
                                        ChipView(text: "#\(tag)", style: .accent)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .padding(14)
        }
    }

    private var emojiBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.35), Color("AppAccent").opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 54, height: 54)

            Circle()
                .stroke(Color("AppAccent").opacity(0.35), lineWidth: 1.5)
                .frame(width: 54, height: 54)

            Text(moment.emoji)
                .font(.system(size: 28))
        }
    }
}
