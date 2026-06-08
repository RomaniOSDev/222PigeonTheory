import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false
    @State private var showExport = false
    @State private var showReminderDeniedAlert = false
    var showsCloseButton = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        AppBackgroundView {
            ScrollView {
                VStack(spacing: 16) {
                    StatsSummaryCard(
                        itemsAdded: store.itemsAdded,
                        entriesWritten: store.entriesWritten,
                        streakDays: store.streakDays,
                        minutesUsed: store.totalMinutesUsed
                    )

                    SettingsToggleCard(
                        title: "Daily Reminder",
                        subtitle: "Get a gentle nudge to write",
                        isOn: reminderBinding,
                        timeBinding: reminderTimeBinding,
                        showTimePicker: store.reminderEnabled
                    )

                    CardContainer {
                        VStack(spacing: 0) {
                            SettingsRowCell(
                                title: "Rate Us",
                                subtitle: "Enjoying the app? Leave a review",
                                icon: "star.fill"
                            ) { rateApp() }

                            Divider().background(Color("AppTextSecondary").opacity(0.2))

                            SettingsRowCell(
                                title: "Privacy",
                                subtitle: "Read our privacy policy",
                                icon: "lock.shield"
                            ) { openLink(.privacyPolicy) }

                            Divider().background(Color("AppTextSecondary").opacity(0.2))

                            SettingsRowCell(
                                title: "Terms",
                                subtitle: "Terms of use",
                                icon: "doc.text"
                            ) { openLink(.termsOfUse) }
                        }
                    }

                    CardContainer {
                        VStack(spacing: 0) {
                            SettingsRowCell(
                                title: "Export Journal",
                                subtitle: "TXT or PDF backup",
                                icon: "square.and.arrow.up"
                            ) { showExport = true }

                            Divider().background(Color("AppTextSecondary").opacity(0.2))

                            SettingsRowCell(
                                title: "Reset All Data",
                                subtitle: "Permanently erase everything",
                                icon: "trash",
                                tint: .red,
                                showsChevron: false,
                                isDestructive: true
                            ) { showResetAlert = true }
                        }
                    }

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
                .padding(16)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppSurface").opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            if showsCloseButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextPrimary"))
                }
            }
        }
        .sheet(isPresented: $showExport) {
            ExportSheetView()
        }
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { HapticManager.lightTap() }
            Button("Reset", role: .destructive) {
                HapticManager.warning()
                store.resetAllData()
            }
        } message: {
            Text("This will permanently delete all your moments, stories, and progress.")
        }
        .alert("Notifications Disabled", isPresented: $showReminderDeniedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable notifications in Settings to receive daily journaling reminders.")
        }
    }

    private var reminderBinding: Binding<Bool> {
        Binding(
            get: { store.reminderEnabled },
            set: { enabled in
                HapticManager.lightTap()
                if enabled {
                    store.enableReminder { granted in
                        if !granted { showReminderDeniedAlert = true }
                    }
                } else {
                    store.disableReminder()
                }
            }
        )
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = store.reminderHour
                components.minute = store.reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                store.reminderHour = components.hour ?? 20
                store.reminderMinute = components.minute ?? 0
            }
        )
    }

    private func openLink(_ link: AppLinks) {
        guard let url = link.url else { return }
        UIApplication.shared.open(url)
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
