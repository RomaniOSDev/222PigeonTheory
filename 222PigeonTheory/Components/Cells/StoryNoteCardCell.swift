import SwiftUI

struct StoryNoteCardCell: View {
    let note: StoryNote
    var linkedMomentTitle: String?
    var isExpanded = false
    var onTagTap: ((String) -> Void)?

    var body: some View {
        CardContainer(accent: note.isFavorite || isExpanded) {
            HStack(alignment: .top, spacing: 14) {
                ThumbnailPlaceholderView(style: note.thumbnailStyle, size: 72)
                    .overlay(alignment: .topTrailing) {
                        if note.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption2)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .padding(5)
                                .background(Color("AppAccent"))
                                .clipShape(Circle())
                                .offset(x: 6, y: -6)
                        }
                    }

                VStack(alignment: .leading, spacing: 10) {
                    Text(note.text)
                        .font(.body)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(5)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 8) {
                        ChipView(text: DateFormatting.relativeLabel(for: note.date), icon: "calendar", style: .neutral)
                        if note.isFavorite {
                            ChipView(text: "Favorite", icon: "heart.fill", style: .accent)
                        }
                    }

                    if let linkedMomentTitle {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                                .font(.caption2)
                                .foregroundStyle(Color("AppAccent"))
                            Text(linkedMomentTitle)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .lineLimit(1)
                        }
                    }

                    if let theme = note.linkedTheme {
                        ChipView(text: theme, icon: "tag", style: .primary)
                    }

                    if !note.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(note.tags, id: \.self) { tag in
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
        .scaleEffect(isExpanded ? 1.02 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
    }
}
