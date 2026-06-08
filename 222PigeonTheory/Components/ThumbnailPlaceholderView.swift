import SwiftUI

struct ThumbnailPlaceholderView: View {
    let style: Int
    var size: CGFloat = 64

    private var gradientColors: [Color] {
        let palettes: [[Color]] = [
            [Color("AppPrimary"), Color("AppAccent")],
            [Color("AppAccent"), Color("AppSurface")],
            [Color("AppPrimary"), Color("AppSurface")],
            [Color("AppAccent"), Color("AppPrimary")],
            [Color("AppSurface"), Color("AppAccent")],
            [Color("AppPrimary"), Color("AppBackground")]
        ]
        return palettes[abs(style) % palettes.count]
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(Color("AppTextPrimary").opacity(0.7))
            }
    }
}
