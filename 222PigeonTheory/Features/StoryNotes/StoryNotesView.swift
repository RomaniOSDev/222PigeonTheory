import SwiftUI

struct StoryNotesView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = StoryNotesViewModel()

    private var displayedNotes: [StoryNote] {
        store.filteredNotes(using: viewModel.filter)
    }

    var body: some View {
        AppBackgroundView {
            ZStack {
                ScrollView {
                    VStack(spacing: 14) {
                        if !store.storyNotes.isEmpty {
                            SearchFilterBar(
                                filter: $viewModel.filter,
                                showFilters: $viewModel.showingFilters,
                                placeholder: "Search stories..."
                            )
                            .padding(.top, 4)

                            SectionHeaderView(
                                title: "Story Notes",
                                subtitle: "Swipe cards for quick actions",
                                trailing: "\(displayedNotes.count) shown"
                            )
                            .padding(.horizontal, 16)
                        }

                        if store.storyNotes.isEmpty {
                            EmptyStateView(
                                symbolName: "book.closed",
                                title: "Start journaling your moments",
                                message: "No stories yet! Tap the '+' button below to start journaling your moments.",
                                actionTitle: "Write Story"
                            ) {
                                viewModel.prepareNew()
                                viewModel.showingEditor = true
                            }
                        } else if displayedNotes.isEmpty {
                            EmptyStateView(
                                symbolName: "magnifyingglass",
                                title: "No Results",
                                message: "Try adjusting your search or filters.",
                                actionTitle: "Clear Filters"
                            ) {
                                viewModel.filter.reset()
                            }
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(displayedNotes) { note in
                                    StoryNoteCardCell(
                                        note: note,
                                        linkedMomentTitle: note.linkedMomentID.flatMap { store.momentTitle(for: $0) },
                                        isExpanded: viewModel.expandedNoteID == note.id,
                                        onTagTap: { tag in
                                            viewModel.filter.tag = tag
                                        }
                                    )
                                    .onTapGesture {
                                        HapticManager.lightTap()
                                        viewModel.prepareEdit(note)
                                        viewModel.showingEditor = true
                                    }
                                    .contextMenu { noteMenu(note) }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 90)
                        }
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        FloatingActionButton {
                            HapticManager.lightTap()
                            viewModel.prepareNew()
                            viewModel.showingEditor = true
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 16)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticManager.lightTap()
                    viewModel.showingExport = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .frame(minWidth: 44, minHeight: 44)
            }
        }
        .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .sheet(isPresented: $viewModel.showingEditor) {
            StoryNoteEditorSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingFilters) {
            FilterSheetView(
                filter: $viewModel.filter,
                emojiOptions: [],
                availableTags: store.allUsedTags,
                showFavorites: true
            )
        }
        .sheet(isPresented: $viewModel.showingExport) {
            ExportSheetView()
        }
    }

    @ViewBuilder
    private func noteMenu(_ note: StoryNote) -> some View {
        Button(note.isPinned ? "Unpin" : "Pin") { store.toggleNotePin(note) }
        Button(note.isFavorite ? "Unfavorite" : "Favorite") { store.toggleStoryNoteFavorite(note) }
        Button("Edit") {
            viewModel.prepareEdit(note)
            viewModel.showingEditor = true
        }
        Button("Delete", role: .destructive) { store.deleteStoryNote(note) }
    }
}
