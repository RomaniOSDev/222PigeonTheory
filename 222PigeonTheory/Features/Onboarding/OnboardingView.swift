import SwiftUI

private struct OnboardingPageData: Identifiable {
    let id: Int
    let headline: String
    let description: String
    let imageName: String
    let icon: String
    let chips: [String]
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0

    private let pages: [OnboardingPageData] = [
        OnboardingPageData(
            id: 0,
            headline: "Welcome",
            description: "Organize your media collection effortlessly.",
            imageName: "HomeHero",
            icon: "sparkles",
            chips: ["Moments", "Stories", "Insights"]
        ),
        OnboardingPageData(
            id: 1,
            headline: "Add Notes",
            description: "Capture detailed notes with each photo.",
            imageName: "WidgetMoments",
            icon: "note.text",
            chips: ["Emoji", "Tags", "Search"]
        ),
        OnboardingPageData(
            id: 2,
            headline: "Start Your Journey",
            description: "Begin organizing your media now.",
            imageName: "WidgetJournal",
            icon: "book.pages",
            chips: ["Journal", "Focus", "Export"]
        )
    ]

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                progressHeader
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        onboardingPage(page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                pageIndicator
                    .padding(.bottom, 20)

                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
    }

    private var progressHeader: some View {
        HStack(spacing: 6) {
            ForEach(pages) { page in
                Capsule()
                    .fill(
                        page.id <= currentPage
                            ? LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color("AppTextSecondary").opacity(0.25), Color("AppTextSecondary").opacity(0.25)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .frame(height: 4)
                    .animation(.easeInOut(duration: 0.3), value: currentPage)
            }
        }
    }

    private func onboardingPage(_ page: OnboardingPageData) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                OnboardingHeroCard(
                    imageName: page.imageName,
                    icon: page.icon,
                    isActive: currentPage == page.id
                )
                .padding(.horizontal, 20)
                .padding(.top, 16)

                CardContainer(accent: true) {
                    VStack(spacing: 16) {
                        Text(page.headline)
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.center)

                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 8) {
                            ForEach(page.chips, id: \.self) { chip in
                                ChipView(text: chip, style: .accent)
                            }
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .modifier(OnboardingAppearModifier(isActive: currentPage == page.id))

                featurePreview(for: page.id)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
    }

    @ViewBuilder
    private func featurePreview(for pageId: Int) -> some View {
        switch pageId {
        case 0:
            HStack(spacing: 10) {
                miniPreview(icon: "square.stack.3d.up.fill", title: "Catalog", value: "Organize")
                miniPreview(icon: "chart.bar.fill", title: "Insights", value: "Discover")
            }
        case 1:
            HStack(spacing: 10) {
                miniPreview(icon: "face.smiling", title: "Emoji", value: "Express")
                miniPreview(icon: "number", title: "Tags", value: "Sort")
            }
        default:
            HStack(spacing: 10) {
                miniPreview(icon: "brain.head.profile", title: "Focus", value: "Write")
                miniPreview(icon: "square.and.arrow.up", title: "Export", value: "Share")
            }
        }
    }

    private func miniPreview(icon: String, title: String, value: String) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                Capsule()
                    .fill(page.id == currentPage ? Color("AppPrimary") : Color("AppTextSecondary").opacity(0.3))
                    .frame(width: page.id == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: currentPage == pages.count - 1 ? "Get Started" : "Next") {
                advancePage()
            }

            if currentPage < pages.count - 1 {
                Button("Skip") {
                    HapticManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = pages.count - 1
                    }
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
                .frame(minHeight: 44)
            }
        }
    }

    private func advancePage() {
        if currentPage < pages.count - 1 {
            HapticManager.lightTap()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            HapticManager.mediumTap()
            HapticManager.playSuccessSound()
            store.completeOnboarding()
        }
    }
}

private struct OnboardingHeroCard: View {
    let imageName: String
    let icon: String
    let isActive: Bool

    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()

            LinearGradient(
                colors: [Color.black.opacity(0.5), Color.clear, Color.black.opacity(0.2)],
                startPoint: .bottom,
                endPoint: .top
            )

            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color("AppPrimary").opacity(0.85))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.body.bold())
                        .foregroundStyle(Color("AppSurface"))
                }
                .shadow(color: Color("AppPrimary").opacity(0.4), radius: 6, y: 3)
            }
            .padding(16)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color("AppAccent").opacity(0.4), lineWidth: 1)
        }
        .shadow(color: Color("AppPrimary").opacity(0.22), radius: 14, y: 6)
        .scaleEffect(appeared && isActive ? 1 : 0.92)
        .opacity(appeared && isActive ? 1 : 0.5)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                appeared = true
            }
        }
        .onChange(of: isActive) { active in
            if active {
                appeared = false
                withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                    appeared = true
                }
            }
        }
    }
}

private struct OnboardingAppearModifier: ViewModifier {
    let isActive: Bool
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .offset(y: appeared && isActive ? 0 : 18)
            .opacity(appeared && isActive ? 1 : 0.4)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    appeared = true
                }
            }
            .onChange(of: isActive) { active in
                if active {
                    appeared = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        appeared = true
                    }
                }
            }
    }
}
