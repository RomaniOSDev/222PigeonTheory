import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownContent = ""

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ScrollView {
                    if markdownContent.isEmpty {
                        Text("Privacy policy not found.")
                            .foregroundStyle(Color("AppTextSecondary"))
                            .padding()
                    } else {
                        PolicyMarkdownContent(content: markdownContent)
                            .padding(16)
                    }
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        HapticManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextPrimary"))
                }
            }
            .onAppear {
                loadPolicy()
            }
        }
    }

    private func loadPolicy() {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return
        }
        markdownContent = content
    }
}

private struct PolicyMarkdownContent: View {
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                lineView(line)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var lines: [String] {
        content.components(separatedBy: "\n")
    }

    @ViewBuilder
    private func lineView(_ line: String) -> some View {
        if line.hasPrefix("# ") {
            Text(String(line.dropFirst(2)))
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
        } else if line.hasPrefix("• ") {
            Text(line)
                .font(.body)
                .foregroundStyle(Color("AppTextPrimary"))
        } else if line.contains("support@example.com") {
            supportLine(line)
        } else if line.isEmpty {
            Color.clear.frame(height: 4)
        } else {
            Text(line)
                .font(.body)
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }

    private func supportLine(_ line: String) -> some View {
        let email = "support@example.com"
        let prefix = line.replacingOccurrences(of: email, with: "")

        return Group {
            if let url = URL(string: "mailto:\(email)") {
                HStack(spacing: 0) {
                    Text(prefix)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Link(email, destination: url)
                        .foregroundStyle(Color("AppPrimary"))
                }
                .font(.body)
            } else {
                Text(line)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
        }
    }
}
