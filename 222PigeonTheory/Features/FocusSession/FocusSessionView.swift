import SwiftUI

struct FocusSessionView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = FocusSessionViewModel()
    @StateObject private var storyViewModel = StoryNotesViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CardContainer(accent: viewModel.state == .completed) {
                    VStack(spacing: 10) {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundStyle(Color("AppAccent"))
                        Text("Focus Session")
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Write one story without distractions")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)

                if viewModel.state == .idle {
                    CardContainer {
                        VStack(spacing: 16) {
                            Text("Choose duration")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Picker("Duration", selection: $viewModel.selectedMinutes) {
                                ForEach(viewModel.durationOptions, id: \.self) { minutes in
                                    Text("\(minutes) min").tag(minutes)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                    }
                    .padding(.horizontal, 16)

                    PrimaryButton(title: "Start Session") {
                        viewModel.start()
                    }
                    .padding(.horizontal, 16)
                } else {
                    CardContainer(accent: viewModel.state == .running) {
                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .stroke(Color("AppBackground"), lineWidth: 14)
                                    .frame(width: 190, height: 190)
                                Circle()
                                    .trim(from: 0, to: viewModel.progress)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color("AppPrimary"), Color("AppAccent")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                    )
                                    .frame(width: 190, height: 190)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress)

                                VStack(spacing: 4) {
                                    Text(viewModel.timeLabel)
                                        .font(.system(size: 38, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Text(statusText)
                                        .font(.caption)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                }
                            }

                            if viewModel.state == .running || viewModel.state == .paused {
                                Button("Cancel Session") {
                                    HapticManager.lightTap()
                                    viewModel.cancel()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("AppTextSecondary"))
                                .frame(minHeight: 44)
                            }

                            if viewModel.state == .paused {
                                PrimaryButton(title: "Resume") {
                                    viewModel.resume()
                                }
                            }

                            if viewModel.state == .completed {
                                PrimaryButton(title: "Write Your Story") {
                                    HapticManager.lightTap()
                                    storyViewModel.prepareNew()
                                    storyViewModel.draftText = EntryTemplate.highlight.starterText
                                    viewModel.showStoryEditor = true
                                    viewModel.cancel()
                                    store.totalSessionsCompleted += 1
                                }
                            }
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
            .padding(.bottom, 20)
        }
        .onChange(of: scenePhase) { phase in
            viewModel.handleScenePhase(phase)
        }
        .sheet(isPresented: $viewModel.showStoryEditor) {
            StoryNoteEditorSheet(viewModel: storyViewModel)
        }
    }

    private var statusText: String {
        switch viewModel.state {
        case .idle: return ""
        case .running: return "In progress"
        case .paused: return "Paused"
        case .completed: return "Complete!"
        }
    }
}
