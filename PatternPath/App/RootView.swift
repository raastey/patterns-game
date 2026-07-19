import SwiftUI

enum AppRoute: Equatable {
    case home
    case levels
    case stickers
    case settings
    case play(Int)
}

struct RootView: View {
    @State private var progress = ProgressStore()
    @State private var settings = AppSettings()
    @State private var route: AppRoute = .home

    var body: some View {
        ZStack {
            switch route {
            case .home:
                HomeView(
                    onPlay: { navigate(to: .play(progress.highestUnlocked)) },
                    onLevels: { navigate(to: .levels) },
                    onStickers: { navigate(to: .stickers) },
                    onSettings: { navigate(to: .settings) }
                )
                .transition(pageTransition)

            case .levels:
                LevelMapView(
                    onSelect: { id in navigate(to: .play(id)) },
                    onBack: { navigate(to: .home) }
                )
                .transition(pageTransition)

            case .stickers:
                StickerCollectionView(onClose: { navigate(to: .home) })
                    .transition(pageTransition)

            case .settings:
                ParentSettingsView(onClose: { navigate(to: .home) })
                    .transition(pageTransition)

            case .play(let id):
                if let level = LevelCatalog.level(id: id) {
                    PlayView(
                        level: level,
                        onExit: { navigate(to: .levels) },
                        onNextLevel: { nextID in navigate(to: .play(nextID)) },
                        onMap: { navigate(to: .levels) }
                    )
                    .id(id)
                    .transition(pageTransition)
                } else {
                    LevelMapView(
                        onSelect: { id in navigate(to: .play(id)) },
                        onBack: { navigate(to: .home) }
                    )
                    .transition(pageTransition)
                }
            }
        }
        .environment(progress)
        .environment(settings)
        .preferredColorScheme(.light)
    }

    private var pageTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.985)).combined(with: .offset(y: 8)),
            removal: .opacity.combined(with: .scale(scale: 1.01))
        )
    }

    private func navigate(to newRoute: AppRoute) {
        HapticsPlayer.shared.prepare()
        withAnimation(Motion.softSpring) {
            route = newRoute
        }
    }
}
