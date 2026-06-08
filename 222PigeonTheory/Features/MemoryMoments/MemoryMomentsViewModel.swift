import Combine
import Foundation

final class MemoryMomentsViewModel: ObservableObject {
    @Published var showingEditor = false
    @Published var showingFilters = false
    @Published var showingExport = false
    @Published var editingMoment: MemoryMoment?
    @Published var draftText = ""
    @Published var draftEmoji = "✨"
    @Published var draftTags: [String] = []
    @Published var filter = EntryFilter()
    @Published var validationMessage = ""
    @Published var shakeTrigger: CGFloat = 0
    @Published var highlightedID: UUID?
    @Published var showSuccessCheck = false

    let emojiOptions = ["✨", "🌿", "✈️", "🍕", "🎨", "👨‍👩‍👧", "📷", "☕", "🌸", "💬"]

    func prepareNew(lastEmoji: String) {
        editingMoment = nil
        draftText = ""
        draftEmoji = lastEmoji
        draftTags = []
        validationMessage = ""
    }

    func prepareEdit(_ moment: MemoryMoment) {
        editingMoment = moment
        draftText = moment.text
        draftEmoji = moment.emoji
        draftTags = moment.tags
        validationMessage = ""
    }

    func applyTemplate(_ starter: String) {
        if draftText.isEmpty {
            draftText = starter
        } else {
            draftText += starter
        }
    }

    func save(store: AppDataStore) -> UUID? {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            validationMessage = "Please enter a moment description."
            shakeTrigger += 1
            HapticManager.warning()
            return nil
        }

        let normalizedTags = draftTags.map { store.normalizedTag($0) }.filter { !$0.isEmpty }

        if var existing = editingMoment {
            existing.text = trimmed
            existing.emoji = draftEmoji
            existing.tags = normalizedTags
            store.updateMemoryMoment(existing)
            showingEditor = false
            return existing.id
        } else {
            let moment = MemoryMoment(text: trimmed, emoji: draftEmoji, tags: normalizedTags)
            store.addMemoryMoment(moment)
            HapticManager.mediumTap()
            HapticManager.playSuccessSound()
            showSuccessCheck = true
            highlightedID = moment.id
            showingEditor = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.highlightedID = nil
            }
            return moment.id
        }
    }
}
