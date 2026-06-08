import SwiftUI

struct MemoryMomentsView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = MemoryMomentsViewModel()
    @State private var showSettings = false

    private var displayedMoments: [MemoryMoment] {
        store.filteredMoments(using: viewModel.filter)
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 14) {
                            if !store.memoryMoments.isEmpty {
                                SearchFilterBar(
                                    filter: $viewModel.filter,
                                    showFilters: $viewModel.showingFilters,
                                    placeholder: "Search moments..."
                                )
                                .padding(.top, 4)

                                SectionHeaderView(
                                    title: "Your Moments",
                                    subtitle: "Tap a card to edit",
                                    trailing: "\(displayedMoments.count) shown"
                                )
                                .padding(.horizontal, 16)
                            }

                            if store.memoryMoments.isEmpty {
                                EmptyStateView(
                                    symbolName: "book.fill",
                                    title: "Capture your moments!",
                                    message: "No memories yet! Tap + below to add your first moment.",
                                    actionTitle: "Add Moment"
                                ) {
                                    viewModel.prepareNew(lastEmoji: store.lastUsedEmoji)
                                    viewModel.showingEditor = true
                                }
                            } else if displayedMoments.isEmpty {
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
                                    ForEach(displayedMoments) { moment in
                                        MomentCardCell(
                                            moment: moment,
                                            isHighlighted: viewModel.highlightedID == moment.id,
                                            onTagTap: { tag in
                                                viewModel.filter.tag = tag
                                            }
                                        )
                                        .contextMenu { momentMenu(moment) }
                                        .onTapGesture {
                                            HapticManager.lightTap()
                                            viewModel.prepareEdit(moment)
                                            viewModel.showingEditor = true
                                        }
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
                                viewModel.prepareNew(lastEmoji: store.lastUsedEmoji)
                                viewModel.showingEditor = true
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 16)
                    }

                    SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheck)
                }
            }
            .navigationTitle("Memory Moments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 2) {
                        toolbarIcon("square.and.arrow.up") { viewModel.showingExport = true }
                        toolbarIcon("gearshape.fill") { showSettings = true }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingEditor) {
                MomentEditorSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingFilters) {
                FilterSheetView(
                    filter: $viewModel.filter,
                    emojiOptions: viewModel.emojiOptions,
                    availableTags: store.allUsedTags,
                    showFavorites: false
                )
            }
            .sheet(isPresented: $viewModel.showingExport) {
                ExportSheetView()
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView(showsCloseButton: true)
                }
            }
        }
    }

    @ViewBuilder
    private func momentMenu(_ moment: MemoryMoment) -> some View {
        Button(moment.isPinned ? "Unpin" : "Pin") { store.toggleMomentPin(moment) }
        Button("Edit") {
            viewModel.prepareEdit(moment)
            viewModel.showingEditor = true
        }
        Button("Duplicate") {
            store.duplicateMemoryMoment(moment)
            HapticManager.saveFeedback()
        }
        Button("Delete", role: .destructive) { store.deleteMemoryMoment(moment) }
    }

    private func toolbarIcon(_ name: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            Image(systemName: name)
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}
