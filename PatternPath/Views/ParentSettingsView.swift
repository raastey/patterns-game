import SwiftUI

struct ParentSettingsView: View {
    @Environment(ProgressStore.self) private var progress
    @Environment(AppSettings.self) private var settings

    let onClose: () -> Void

    @State private var confirmReset = false

    var body: some View {
        ZStack {
            SkyBackground(theme: .colorGarage)

            AdaptiveReader { layout in
                VStack(spacing: 0) {
                    header(layout)
                        .padding(.horizontal, layout.horizontalPadding)
                        .padding(.top, layout.isShortLandscape ? 8 : 14)
                        .padding(.bottom, 12)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionCard(title: "For grown-ups") {
                                Text("Pattern Path teaches one thing at a time: either color or toy, never both. Progress stays on this device. No accounts, no ads, no tracking.")
                                    .font(.bodyRounded(15, weight: .medium))
                                    .foregroundStyle(AppTheme.inkSoft)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            sectionCard(title: "Sound & feel") {
                                Toggle(isOn: soundOnBinding) {
                                    Label(
                                        "Sound",
                                        systemImage: SoundPlayer.shared.isMuted
                                            ? "speaker.slash.fill"
                                            : "speaker.wave.2.fill"
                                    )
                                }
                                .tint(AppTheme.accent)

                                Toggle(isOn: hapticsBinding) {
                                    Label("Haptics", systemImage: "waveform")
                                }
                                .tint(AppTheme.accent)
                            }

                            sectionCard(title: "Progress") {
                                Text("\(progress.clearedLevelCount) levels parked · \(progress.totalStars) stars · \(progress.unlockedStickers.count) stickers")
                                    .font(.bodyRounded(15, weight: .semibold))
                                    .foregroundStyle(AppTheme.ink)

                                Button(role: .destructive) {
                                    confirmReset = true
                                } label: {
                                    Label("Reset all progress", systemImage: "trash")
                                        .font(.bodyRounded(16, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                }
                                .buttonStyle(.bordered)
                            }

                            sectionCard(title: "About") {
                                Text(settings.appVersionText)
                                    .font(.bodyRounded(14, weight: .medium))
                                    .foregroundStyle(AppTheme.inkFaint)
                                Text("Ages 5+ · Level 1 autism-friendly design")
                                    .font(.bodyRounded(14, weight: .medium))
                                    .foregroundStyle(AppTheme.inkFaint)
                            }
                        }
                        .padding(.horizontal, layout.horizontalPadding)
                        .padding(.bottom, 36)
                    }
                }
            }
        }
        .confirmationDialog(
            "Reset all progress?",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                progress.resetAll()
                settings.coachCompleted = false
                HapticsPlayer.shared.wrong()
                onClose()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears stars, stickers, and unlocked levels on this device.")
        }
    }

    private var soundOnBinding: Binding<Bool> {
        Binding(
            get: { !SoundPlayer.shared.isMuted },
            set: { SoundPlayer.shared.isMuted = !$0 }
        )
    }

    private var hapticsBinding: Binding<Bool> {
        Binding(
            get: { HapticsPlayer.shared.isEnabled },
            set: { HapticsPlayer.shared.isEnabled = $0 }
        )
    }

    private func header(_ layout: AdaptiveLayout) -> some View {
        HStack {
            ToolbarChip(title: "Done", systemImage: "xmark", action: onClose)
            Spacer()
            Text("Grown-ups")
                .font(.display(layout.isShortLandscape ? 22 : 28, weight: .bold))
                .foregroundStyle(AppTheme.ink)
            Spacer()
            Color.clear.frame(width: 72, height: 1)
        }
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.display(18, weight: .bold))
                .foregroundStyle(AppTheme.ink)
            content()
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassSurface(cornerRadius: 22, intense: false)
    }
}
