import SwiftUI

struct AppBackgroundView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.12), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()

            Canvas { context, size in
                let spacing: CGFloat = 32
                for x in stride(from: 0, through: size.width, by: spacing) {
                    for y in stride(from: 0, through: size.height, by: spacing) {
                        let rect = CGRect(x: x, y: y, width: 2, height: 2)
                        context.fill(Path(ellipseIn: rect), with: .color(Color("AppPrimary").opacity(0.06)))
                    }
                }
            }
            .ignoresSafeArea()

            content()
        }
    }
}
