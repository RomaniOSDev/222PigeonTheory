import SwiftUI

struct SettingsRowCell: View {
    let title: String
    let subtitle: String?
    let icon: String
    var tint: Color = Color("AppAccent")
    var showsChevron = true
    var isDestructive = false
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        tint: Color = Color("AppAccent"),
        showsChevron: Bool = true,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.tint = tint
        self.showsChevron = showsChevron
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isDestructive ? Color.red.opacity(0.15) : tint.opacity(0.18))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.subheadline)
                        .foregroundStyle(isDestructive ? .red : tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(isDestructive ? .red : Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(1)
                    }
                }

                Spacer()

                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 56)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsToggleCard: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var timeBinding: Binding<Date>?
    var showTimePicker = false

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: $isOn) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .tint(Color("AppPrimary"))

                if showTimePicker, let timeBinding {
                    DatePicker("Reminder Time", selection: timeBinding, displayedComponents: .hourAndMinute)
                        .foregroundStyle(Color("AppTextPrimary"))
                }
            }
            .padding(16)
        }
    }
}
