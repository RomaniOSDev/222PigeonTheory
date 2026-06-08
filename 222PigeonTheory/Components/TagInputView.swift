import SwiftUI

struct TagInputView: View {
    @Binding var tags: [String]
    let suggestions: [String]
    @State private var input = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tags")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            HStack(spacing: 8) {
                TextField("Add tag (e.g. travel)", text: $input)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(10)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .onSubmit { addTag() }

                Button("Add") {
                    HapticManager.lightTap()
                    addTag()
                }
                .foregroundStyle(Color("AppAccent"))
                .frame(minWidth: 44, minHeight: 44)
            }

            if !filteredSuggestions.isEmpty && !input.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filteredSuggestions, id: \.self) { suggestion in
                            Button {
                                HapticManager.lightTap()
                                appendTag(suggestion)
                                input = ""
                            } label: {
                                Text("#\(suggestion)")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color("AppPrimary").opacity(0.25))
                                    .clipShape(Capsule())
                                    .foregroundStyle(Color("AppTextPrimary"))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if !tags.isEmpty {
                FlowTagsView(tags: tags) { tag in
                    tags.removeAll { $0 == tag }
                }
            }
        }
    }

    private var filteredSuggestions: [String] {
        let query = normalized(input)
        guard !query.isEmpty else { return [] }
        return suggestions
            .filter { $0.contains(query) && !tags.contains($0) }
            .prefix(6)
            .map { $0 }
    }

    private func addTag() {
        let tag = normalized(input)
        guard !tag.isEmpty else { return }
        appendTag(tag)
        input = ""
    }

    private func appendTag(_ raw: String) {
        let tag = normalized(raw)
        guard !tag.isEmpty, !tags.contains(tag) else { return }
        tags.append(tag)
    }

    private func normalized(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()
    }
}

private struct FlowTagsView: View {
    let tags: [String]
    let onRemove: (String) -> Void

    var body: some View {
        FlexibleTagLayout(tags: tags, onRemove: onRemove)
    }
}

private struct FlexibleTagLayout: View {
    let tags: [String]
    let onRemove: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text("#\(tag)")
                                .font(.caption)
                            Button {
                                HapticManager.lightTap()
                                onRemove(tag)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color("AppAccent").opacity(0.25))
                        .clipShape(Capsule())
                        .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
            }
        }
    }

    private var rows: [[String]] {
        var result: [[String]] = [[]]
        var width: CGFloat = 0
        let limit: CGFloat = 320
        for tag in tags {
            let tagWidth: CGFloat = CGFloat(tag.count * 8 + 50)
            if width + tagWidth > limit, !result.last!.isEmpty {
                result.append([tag])
                width = tagWidth
            } else {
                result[result.count - 1].append(tag)
                width += tagWidth
            }
        }
        return result.filter { !$0.isEmpty }
    }
}
