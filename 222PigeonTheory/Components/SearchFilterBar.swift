import SwiftUI

struct SearchFilterBar: View {
    @Binding var filter: EntryFilter
    @Binding var showFilters: Bool
    let placeholder: String

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color("AppAccent"))
                    TextField(placeholder, text: $filter.searchText)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    if !filter.searchText.isEmpty {
                        Button {
                            HapticManager.lightTap()
                            filter.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color("AppSurface"))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.15), lineWidth: 1)
                }

                Button {
                    HapticManager.lightTap()
                    showFilters = true
                } label: {
                    Image(systemName: filter.isActive ? "slider.horizontal.3" : "slider.horizontal.3")
                        .font(.body.weight(.semibold))
                    .foregroundStyle(filter.isActive ? Color("AppSurface") : Color("AppTextSecondary"))
                    .frame(width: 46, height: 46)
                    .background(filter.isActive ? Color("AppPrimary") : Color("AppSurface"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            if filter.isActive {
                ActiveFilterChips(filter: $filter)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct ActiveFilterChips: View {
    @Binding var filter: EntryFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if filter.favoritesOnly {
                    chip("Favorites") { filter.favoritesOnly = false }
                }
                if let emoji = filter.emoji {
                    chip(emoji) { filter.emoji = nil }
                }
                if let theme = filter.theme {
                    chip(theme) { filter.theme = nil }
                }
                if let tag = filter.tag {
                    chip("#\(tag)") { filter.tag = nil }
                }
                if filter.dateFrom != nil || filter.dateTo != nil {
                    chip("Date range") {
                        filter.dateFrom = nil
                        filter.dateTo = nil
                    }
                }
                Button("Clear all") {
                    HapticManager.lightTap()
                    filter.reset()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
            }
        }
    }

    private func chip(_ text: String, remove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption2.weight(.semibold))
            Button(action: remove) {
                Image(systemName: "xmark")
                    .font(.caption2.bold())
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(Color("AppTextPrimary"))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color("AppAccent").opacity(0.22))
        .clipShape(Capsule())
    }
}

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filter: EntryFilter
    let emojiOptions: [String]
    let availableTags: [String]
    let showFavorites: Bool

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 14) {
                        if showFavorites {
                            CardContainer {
                                Toggle("Favorites Only", isOn: $filter.favoritesOnly)
                                    .tint(Color("AppPrimary"))
                                    .padding(16)
                            }
                        }

                        filterCard(title: "Emoji", icon: "face.smiling") {
                            emojiGrid
                        }

                        filterCard(title: "Theme", icon: "paintpalette") {
                            themeGrid
                        }

                        filterCard(title: "Tag", icon: "number") {
                            tagGrid
                        }

                        CardContainer {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Date Range", systemImage: "calendar")
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                DatePicker("From", selection: dateFromBinding, displayedComponents: .date)
                                DatePicker("To", selection: dateToBinding, displayedComponents: .date)
                            }
                            .padding(16)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        HapticManager.lightTap()
                        filter.reset()
                    }
                    .foregroundStyle(Color("AppTextPrimary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppAccent"))
                }
            }
        }
    }

    private func filterCard<Content: View>(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                content()
            }
            .padding(16)
        }
    }

    private var emojiGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
            filterChip("Any", selected: filter.emoji == nil) { filter.emoji = nil }
            ForEach(emojiOptions, id: \.self) { emoji in
                filterChip(emoji, selected: filter.emoji == emoji) { filter.emoji = emoji }
            }
        }
    }

    private var themeGrid: some View {
        FlowChips(
            items: ["Any"] + AppDataStore.insightThemes,
            selected: filter.theme
        ) { item in
            filter.theme = item == "Any" ? nil : item
        }
    }

    private var tagGrid: some View {
        FlowChips(
            items: ["Any"] + allTags.map { "#\($0)" },
            selected: filter.tag.map { "#\($0)" }
        ) { item in
            filter.tag = item == "Any" ? nil : item.replacingOccurrences(of: "#", with: "")
        }
    }

    private func filterChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selected ? Color("AppPrimary") : Color("AppBackground").opacity(0.6))
                .foregroundStyle(selected ? Color("AppSurface") : Color("AppTextPrimary"))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var allTags: [String] {
        var tags = Set(availableTags)
        if let selected = filter.tag { tags.insert(selected) }
        return tags.sorted()
    }

    private var emojiBinding: Binding<String> {
        Binding(get: { filter.emoji ?? "" }, set: { filter.emoji = $0.isEmpty ? nil : $0 })
    }

    private var themeBinding: Binding<String> {
        Binding(get: { filter.theme ?? "" }, set: { filter.theme = $0.isEmpty ? nil : $0 })
    }

    private var tagBinding: Binding<String> {
        Binding(get: { filter.tag ?? "" }, set: { filter.tag = $0.isEmpty ? nil : $0 })
    }

    private var dateFromBinding: Binding<Date> {
        Binding(get: { filter.dateFrom ?? Date() }, set: { filter.dateFrom = $0 })
    }

    private var dateToBinding: Binding<Date> {
        Binding(get: { filter.dateTo ?? Date() }, set: { filter.dateTo = $0 })
    }
}

private struct FlowChips: View {
    let items: [String]
    let selected: String?
    let onSelect: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
            ForEach(items, id: \.self) { item in
                let isSelected = (item == "Any" && selected == nil) || (item != "Any" && selectedMatches(item))
                Button {
                    HapticManager.lightTap()
                    onSelect(item)
                } label: {
                    Text(item)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? Color("AppPrimary") : Color("AppBackground").opacity(0.6))
                        .foregroundStyle(isSelected ? Color("AppSurface") : Color("AppTextPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func selectedMatches(_ item: String) -> Bool {
        guard let selected else { return false }
        if item.hasPrefix("#") {
            return selected == item.replacingOccurrences(of: "#", with: "")
        }
        return selected == item
    }
}
