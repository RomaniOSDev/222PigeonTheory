import SwiftUI

struct MomentEditorSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @ObservedObject var viewModel: MemoryMomentsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        EntryTemplatesPicker { starter in
                            viewModel.applyTemplate(starter)
                        }

                        Text("Emoji")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(viewModel.emojiOptions, id: \.self) { emoji in
                                Button {
                                    HapticManager.lightTap()
                                    viewModel.draftEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.largeTitle)
                                        .frame(width: 52, height: 52)
                                        .background(
                                            viewModel.draftEmoji == emoji
                                                ? Color("AppPrimary").opacity(0.4)
                                                : Color("AppSurface")
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        TagInputView(
                            tags: $viewModel.draftTags,
                            suggestions: store.allUsedTags
                        )

                        Text("Your Moment")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))

                        TextField("Write something meaningful...", text: $viewModel.draftText, axis: .vertical)
                            .lineLimit(3...8)
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

                        PrimaryButton(title: "Save") {
                            _ = viewModel.save(store: store)
                            if !viewModel.showingEditor {
                                dismiss()
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(viewModel.editingMoment == nil ? "New Moment" : "Edit Moment")
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
}
