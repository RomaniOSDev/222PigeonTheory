import SwiftUI

struct EntryTemplatesPicker: View {
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Templates")
                .font(.headline)
                .foregroundStyle(Color("AppTextPrimary"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(EntryTemplate.allCases) { template in
                        Button {
                            HapticManager.lightTap()
                            onSelect(template.starterText)
                        } label: {
                            Text(template.rawValue)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color("AppSurface"))
                                .clipShape(Capsule())
                                .foregroundStyle(Color("AppTextPrimary"))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
