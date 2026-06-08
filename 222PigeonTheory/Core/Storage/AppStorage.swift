import Combine
import Foundation

final class AppDataStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let journalStreakDays = "journalStreakDays"
        static let lastActivityDate = "lastActivityDate"
        static let lastJournalActivityDate = "lastJournalActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let memoryMoments = "memoryMoments"
        static let lastUsedEmoji = "lastUsedEmoji"
        static let entryCount = "entryCount"
        static let storyNotes = "storyNotes"
        static let lastViewedNoteDate = "lastViewedNoteDate"
        static let favoredThemes = "favoredThemes"
        static let lastAnalysisDate = "lastAnalysisDate"
        static let photoCountsPerTheme = "photoCountsPerTheme"
        static let sessionStartDate = "sessionStartDate"
        static let reminderEnabled = "reminderEnabled"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var journalStreakDays: Int {
        didSet { defaults.set(journalStreakDays, forKey: Keys.journalStreakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet { defaults.set(lastActivityDate, forKey: Keys.lastActivityDate) }
    }

    @Published var lastJournalActivityDate: Date? {
        didSet { defaults.set(lastJournalActivityDate, forKey: Keys.lastJournalActivityDate) }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, forKey: Keys.achievementsUnlocked) }
    }

    @Published var memoryMoments: [MemoryMoment] {
        didSet { saveArray(memoryMoments, forKey: Keys.memoryMoments) }
    }

    @Published var lastUsedEmoji: String {
        didSet { defaults.set(lastUsedEmoji, forKey: Keys.lastUsedEmoji) }
    }

    @Published var entryCount: Int {
        didSet { defaults.set(entryCount, forKey: Keys.entryCount) }
    }

    @Published var storyNotes: [StoryNote] {
        didSet { saveArray(storyNotes, forKey: Keys.storyNotes) }
    }

    @Published var lastViewedNoteDate: Date? {
        didSet { defaults.set(lastViewedNoteDate, forKey: Keys.lastViewedNoteDate) }
    }

    @Published var favoredThemes: [String] {
        didSet { defaults.set(favoredThemes, forKey: Keys.favoredThemes) }
    }

    @Published var lastAnalysisDate: Date? {
        didSet { defaults.set(lastAnalysisDate, forKey: Keys.lastAnalysisDate) }
    }

    @Published var photoCountsPerTheme: [String: Int] {
        didSet { saveDictionary(photoCountsPerTheme, forKey: Keys.photoCountsPerTheme) }
    }

    @Published var newlyUnlockedAchievement: AchievementDefinition?

    @Published var reminderEnabled: Bool {
        didSet {
            defaults.set(reminderEnabled, forKey: Keys.reminderEnabled)
            updateReminderSchedule()
        }
    }

    @Published var reminderHour: Int {
        didSet {
            defaults.set(reminderHour, forKey: Keys.reminderHour)
            updateReminderSchedule()
        }
    }

    @Published var reminderMinute: Int {
        didSet {
            defaults.set(reminderMinute, forKey: Keys.reminderMinute)
            updateReminderSchedule()
        }
    }

    private var sessionStartDate: Date?
    private var achievementQueue: [AchievementDefinition] = []
    private var isShowingAchievementBanner = false

    var itemsAdded: Int {
        memoryMoments.count + storyNotes.count
    }

    var entriesWritten: Int {
        storyNotes.count
    }

    var favouritesCount: Int {
        storyNotes.filter(\.isFavorite).count + favoredThemes.count
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        journalStreakDays = defaults.integer(forKey: Keys.journalStreakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        lastJournalActivityDate = defaults.object(forKey: Keys.lastJournalActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(forKey: Keys.achievementsUnlocked, from: defaults)
        memoryMoments = Self.loadArray(forKey: Keys.memoryMoments, from: defaults)
        lastUsedEmoji = defaults.string(forKey: Keys.lastUsedEmoji) ?? "✨"
        entryCount = defaults.integer(forKey: Keys.entryCount)
        storyNotes = Self.loadArray(forKey: Keys.storyNotes, from: defaults)
        lastViewedNoteDate = defaults.object(forKey: Keys.lastViewedNoteDate) as? Date
        favoredThemes = defaults.stringArray(forKey: Keys.favoredThemes) ?? []
        lastAnalysisDate = defaults.object(forKey: Keys.lastAnalysisDate) as? Date
        photoCountsPerTheme = Self.loadDictionary(forKey: Keys.photoCountsPerTheme, from: defaults)
        reminderEnabled = defaults.bool(forKey: Keys.reminderEnabled)
        reminderHour = defaults.object(forKey: Keys.reminderHour) as? Int ?? 20
        reminderMinute = defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0
        sessionStartDate = Date()

        NotificationCenter.default.addObserver(
            forName: .dataReset,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reloadFromDefaults()
        }

        if reminderEnabled {
            NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
        }
    }

    func beginSession() {
        sessionStartDate = Date()
    }

    func endSessionIfNeeded() {
        guard let start = sessionStartDate else { return }
        let minutes = max(1, Int(Date().timeIntervalSince(start) / 60))
        totalMinutesUsed += minutes
        totalSessionsCompleted += 1
        sessionStartDate = Date()
    }

    func recordActivity() {
        updateStreak(
            lastDate: lastActivityDate,
            currentStreak: streakDays,
            setLastDate: { self.lastActivityDate = $0 },
            setStreak: { self.streakDays = $0 }
        )
        checkAchievements()
    }

    func recordJournalActivity() {
        updateStreak(
            lastDate: lastJournalActivityDate,
            currentStreak: journalStreakDays,
            setLastDate: { self.lastJournalActivityDate = $0 },
            setStreak: { self.journalStreakDays = $0 }
        )
        recordActivity()
    }

    func addMemoryMoment(_ moment: MemoryMoment) {
        memoryMoments.insert(moment, at: 0)
        entryCount += 1
        lastUsedEmoji = moment.emoji
        recordActivity()
    }

    func updateMemoryMoment(_ moment: MemoryMoment) {
        guard let index = memoryMoments.firstIndex(where: { $0.id == moment.id }) else { return }
        memoryMoments[index] = moment
        lastUsedEmoji = moment.emoji
        recordActivity()
    }

    func deleteMemoryMoment(_ moment: MemoryMoment) {
        memoryMoments.removeAll { $0.id == moment.id }
    }

    func duplicateMemoryMoment(_ moment: MemoryMoment) {
        let copy = MemoryMoment(
            text: moment.text,
            emoji: moment.emoji,
            tags: moment.tags
        )
        memoryMoments.insert(copy, at: 0)
        entryCount += 1
        recordActivity()
    }

    func addStoryNote(_ note: StoryNote) {
        storyNotes.insert(note, at: 0)
        lastViewedNoteDate = note.date
        recordJournalActivity()
    }

    func updateStoryNote(_ note: StoryNote) {
        guard let index = storyNotes.firstIndex(where: { $0.id == note.id }) else { return }
        storyNotes[index] = note
        recordJournalActivity()
    }

    func deleteStoryNote(_ note: StoryNote) {
        storyNotes.removeAll { $0.id == note.id }
    }

    func toggleStoryNoteFavorite(_ note: StoryNote) {
        guard let index = storyNotes.firstIndex(where: { $0.id == note.id }) else { return }
        storyNotes[index].isFavorite.toggle()
        checkAchievements()
    }

    func toggleThemeFavorite(_ theme: String) {
        if favoredThemes.contains(theme) {
            favoredThemes.removeAll { $0 == theme }
        } else {
            favoredThemes.append(theme)
            HapticManager.lightTap()
            HapticManager.playFavoriteSound()
        }
        checkAchievements()
    }

    func runAnalysis() {
        var counts: [String: Int] = [:]
        for note in storyNotes {
            let theme = themeForNote(note)
            counts[theme, default: 0] += 1
            for tag in note.tags {
                counts[tag.capitalized, default: 0] += 1
            }
        }
        for moment in memoryMoments {
            let theme = themeForEmoji(moment.emoji)
            counts[theme, default: 0] += 1
            for tag in moment.tags {
                counts[tag.capitalized, default: 0] += 1
            }
        }
        photoCountsPerTheme = counts
        lastAnalysisDate = Date()
        recordActivity()
    }

    func enableReminder(completion: @escaping (Bool) -> Void) {
        NotificationManager.requestAuthorization { granted in
            if granted {
                self.reminderEnabled = true
                completion(true)
            } else {
                self.reminderEnabled = false
                completion(false)
            }
        }
    }

    func disableReminder() {
        reminderEnabled = false
    }

    private func updateReminderSchedule() {
        if reminderEnabled {
            NotificationManager.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
        } else {
            NotificationManager.cancelReminder()
        }
    }

    func insights() -> [MediaInsight] {
        photoCountsPerTheme
            .sorted { $0.value > $1.value }
            .map { theme, count in
                MediaInsight(
                    id: theme,
                    title: theme,
                    theme: theme,
                    count: count
                )
            }
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordActivity()
    }

    func resetAllData() {
        let keys = [
            Keys.hasSeenOnboarding,
            Keys.totalSessionsCompleted,
            Keys.totalMinutesUsed,
            Keys.streakDays,
            Keys.journalStreakDays,
            Keys.lastActivityDate,
            Keys.lastJournalActivityDate,
            Keys.achievementsUnlocked,
            Keys.memoryMoments,
            Keys.lastUsedEmoji,
            Keys.entryCount,
            Keys.storyNotes,
            Keys.lastViewedNoteDate,
            Keys.favoredThemes,
            Keys.lastAnalysisDate,
            Keys.photoCountsPerTheme,
            Keys.sessionStartDate,
            Keys.reminderEnabled,
            Keys.reminderHour,
            Keys.reminderMinute
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
        NotificationManager.cancelReminder()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func dismissAchievementBanner() {
        isShowingAchievementBanner = false
        newlyUnlockedAchievement = nil
        showNextAchievementIfNeeded()
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        journalStreakDays = defaults.integer(forKey: Keys.journalStreakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        lastJournalActivityDate = defaults.object(forKey: Keys.lastJournalActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(forKey: Keys.achievementsUnlocked, from: defaults)
        memoryMoments = Self.loadArray(forKey: Keys.memoryMoments, from: defaults)
        lastUsedEmoji = defaults.string(forKey: Keys.lastUsedEmoji) ?? "✨"
        entryCount = defaults.integer(forKey: Keys.entryCount)
        storyNotes = Self.loadArray(forKey: Keys.storyNotes, from: defaults)
        lastViewedNoteDate = defaults.object(forKey: Keys.lastViewedNoteDate) as? Date
        favoredThemes = defaults.stringArray(forKey: Keys.favoredThemes) ?? []
        lastAnalysisDate = defaults.object(forKey: Keys.lastAnalysisDate) as? Date
        photoCountsPerTheme = Self.loadDictionary(forKey: Keys.photoCountsPerTheme, from: defaults)
        reminderEnabled = defaults.bool(forKey: Keys.reminderEnabled)
        reminderHour = defaults.object(forKey: Keys.reminderHour) as? Int ?? 20
        reminderMinute = defaults.object(forKey: Keys.reminderMinute) as? Int ?? 0
        achievementQueue = []
        isShowingAchievementBanner = false
        newlyUnlockedAchievement = nil
        sessionStartDate = Date()
    }

    private func updateStreak(
        lastDate: Date?,
        currentStreak: Int,
        setLastDate: (Date) -> Void,
        setStreak: (Int) -> Void
    ) {
        let today = Calendar.current.startOfDay(for: Date())
        if let last = lastDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 0 {
                return
            } else if diff == 1 {
                setStreak(currentStreak + 1)
            } else {
                setStreak(1)
            }
        } else {
            setStreak(1)
        }
        setLastDate(today)
    }

    private func checkAchievements() {
        let conditions: [(String, Bool)] = [
            ("first_note", itemsAdded >= 1),
            ("journal_kickoff", entriesWritten >= 1),
            ("photo_collector", itemsAdded >= 10),
            ("dedicated_diarist", entriesWritten >= 50),
            ("favorite_fan", favouritesCount >= 5),
            ("consistent_tracker", streakDays >= 15),
            ("memories_curator", itemsAdded >= 25),
            ("journal_enthusiast", journalStreakDays >= 7)
        ]

        for (id, met) in conditions where met && achievementsUnlocked[id] == nil {
            achievementsUnlocked[id] = Date()
            if let achievement = AchievementCatalog.all.first(where: { $0.id == id }) {
                enqueueAchievement(achievement)
            }
        }
    }

    private func enqueueAchievement(_ achievement: AchievementDefinition) {
        achievementQueue.append(achievement)
        showNextAchievementIfNeeded()
    }

    private func showNextAchievementIfNeeded() {
        guard !isShowingAchievementBanner, let next = achievementQueue.first else { return }
        achievementQueue.removeFirst()
        isShowingAchievementBanner = true
        HapticManager.success()
        newlyUnlockedAchievement = next
    }

    private func saveArray<T: Codable>(_ value: [T], forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func saveDictionary(_ value: [String: Date], forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func saveDictionary(_ value: [String: Int], forKey key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func loadArray<T: Codable>(forKey key: String, from defaults: UserDefaults) -> [T] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func loadDictionary(forKey key: String, from defaults: UserDefaults) -> [String: Date] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private static func loadDictionary(forKey key: String, from defaults: UserDefaults) -> [String: Int] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded
    }
}
