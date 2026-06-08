import SwiftUI

struct ExportSheetView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var exportMoments = true
    @State private var exportNotes = true
    @State private var exportURL: URL?
    @State private var exportFormat: ExportFormat = .txt

    enum ExportFormat: String, CaseIterable, Identifiable {
        case txt = "TXT"
        case pdf = "PDF"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    VStack(spacing: 16) {
                        CardContainer {
                            VStack(alignment: .leading, spacing: 14) {
                                SectionHeaderView(title: "Export Journal", subtitle: "Choose content and format")
                                Toggle("Memory Moments (\(store.memoryMoments.count))", isOn: $exportMoments)
                                    .tint(Color("AppPrimary"))
                                Toggle("Story Notes (\(store.storyNotes.count))", isOn: $exportNotes)
                                    .tint(Color("AppPrimary"))
                                Picker("Format", selection: $exportFormat) {
                                    ForEach(ExportFormat.allCases) { format in
                                        Text(format.rawValue).tag(format)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(16)
                        }

                        PrimaryButton(title: "Prepare Export") {
                            prepareExport()
                        }

                        if let exportURL {
                            ShareLink(item: exportURL) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Export")
                                        .font(.headline)
                                }
                                .foregroundStyle(Color("AppSurface"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color("AppAccent"))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                HapticManager.lightTap()
                            })
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextPrimary"))
                }
            }
        }
    }

    private func prepareExport() {
        HapticManager.mediumTap()
        let moments = exportMoments ? store.memoryMoments : []
        let notes = exportNotes ? store.storyNotes : []
        guard !moments.isEmpty || !notes.isEmpty else {
            HapticManager.warning()
            return
        }
        switch exportFormat {
        case .txt:
            exportURL = ExportManager.makeTXT(moments: moments, notes: notes)
        case .pdf:
            exportURL = ExportManager.makePDF(moments: moments, notes: notes)
        }
        if exportURL != nil {
            HapticManager.saveFeedback()
        }
    }
}
