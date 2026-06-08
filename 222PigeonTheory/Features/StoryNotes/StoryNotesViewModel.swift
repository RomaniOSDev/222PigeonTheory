import Combine
import Foundation

final class StoryNotesViewModel: ObservableObject {
    @Published var showingEditor = false
    @Published var showingFilters = false
    @Published var showingExport = false
    @Published var editingNote: StoryNote?
    @Published var draftText = ""
    @Published var draftThumbnailStyle = 0
    @Published var draftTags: [String] = []
    @Published var draftLinkedMomentID: UUID?
    @Published var draftLinkedTheme: String?
    @Published var filter = EntryFilter()
    @Published var validationMessage = ""
    @Published var shakeTrigger: CGFloat = 0
    @Published var expandedNoteID: UUID?

    let thumbnailStyles = Array(0..<6)

    func prepareNew(template: String? = nil) {
        editingNote = nil
        draftText = template ?? ""
        draftThumbnailStyle = Int.random(in: 0..<6)
        draftTags = []
        draftLinkedMomentID = nil
        draftLinkedTheme = nil
        validationMessage = ""
    }

    func prepareEdit(_ note: StoryNote) {
        editingNote = note
        draftText = note.text
        draftThumbnailStyle = note.thumbnailStyle
        draftTags = note.tags
        draftLinkedMomentID = note.linkedMomentID
        draftLinkedTheme = note.linkedTheme
        validationMessage = ""
    }

    func save(store: AppDataStore) {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            validationMessage = "Please write your story."
            shakeTrigger += 1
            HapticManager.warning()
            return
        }

        let normalizedTags = draftTags.map { store.normalizedTag($0) }.filter { !$0.isEmpty }

        if var existing = editingNote {
            existing.text = trimmed
            existing.thumbnailStyle = draftThumbnailStyle
            existing.tags = normalizedTags
            existing.linkedMomentID = draftLinkedMomentID
            existing.linkedTheme = draftLinkedTheme
            store.updateStoryNote(existing)
        } else {
            let note = StoryNote(
                text: trimmed,
                thumbnailStyle: draftThumbnailStyle,
                tags: normalizedTags,
                linkedMomentID: draftLinkedMomentID,
                linkedTheme: draftLinkedTheme
            )
            store.addStoryNote(note)
            HapticManager.lightTap()
            HapticManager.playLightConfirmSound()
            expandedNoteID = note.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.expandedNoteID = nil
            }
        }
        showingEditor = false
    }
}
