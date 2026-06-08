import SwiftUI

struct StoryNoteEditorSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @ObservedObject var viewModel: StoryNotesViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        EntryTemplatesPicker { starter in
                            if viewModel.draftText.isEmpty {
                                viewModel.draftText = starter
                            } else {
                                viewModel.draftText += starter
                            }
                        }

                        Text("Cover Style")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.thumbnailStyles, id: \.self) { style in
                                    Button {
                                        HapticManager.lightTap()
                                        viewModel.draftThumbnailStyle = style
                                    } label: {
                                        ThumbnailPlaceholderView(style: style, size: 72)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(
                                                        viewModel.draftThumbnailStyle == style
                                                            ? Color("AppAccent")
                                                            : Color.clear,
                                                        lineWidth: 3
                                                    )
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        TagInputView(
                            tags: $viewModel.draftTags,
                            suggestions: store.allUsedTags
                        )

                        linkSection

                        Text("Your Story")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        TextField("Tell your story...", text: $viewModel.draftText, axis: .vertical)
                            .lineLimit(4...10)
                            .padding(12)
                            .background(Color("AppSurface"))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .modifier(ShakeEffect(animatableData: viewModel.shakeTrigger))

                        if !viewModel.validationMessage.isEmpty {
                            Text(viewModel.validationMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        PrimaryButton(title: "Save Story") {
                            viewModel.save(store: store)
                            if !viewModel.showingEditor {
                                dismiss()
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(viewModel.editingNote == nil ? "New Story" : "Edit Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticManager.lightTap()
                        viewModel.showingEditor = false
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var linkSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Links")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            Picker("Linked Moment", selection: momentBinding) {
                Text("None").tag(Optional<UUID>.none)
                ForEach(store.memoryMoments) { moment in
                    Text("\(moment.emoji) \(moment.text)")
                        .lineLimit(1)
                        .tag(Optional(moment.id))
                }
            }

            Picker("Linked Theme", selection: themeBinding) {
                Text("None").tag("")
                ForEach(AppDataStore.insightThemes, id: \.self) { theme in
                    Text(theme).tag(theme)
                }
            }
        }
    }

    private var momentBinding: Binding<UUID?> {
        Binding(
            get: { viewModel.draftLinkedMomentID },
            set: { viewModel.draftLinkedMomentID = $0 }
        )
    }

    private var themeBinding: Binding<String> {
        Binding(
            get: { viewModel.draftLinkedTheme ?? "" },
            set: { viewModel.draftLinkedTheme = $0.isEmpty ? nil : $0 }
        )
    }
}
