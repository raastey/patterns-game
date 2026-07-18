import SwiftUI

struct PatternRibbon: View {
    let slots: [PatternSlot]
    var activeBlankIndex: Int?
    var shakeBlankIndex: Int?
    var lastPlacedIndex: Int?
    var tokenSize: CGFloat = 78

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: tokenSize * 0.2) {
                ForEach(Array(slots.enumerated()), id: \.element.id) { index, slot in
                    Group {
                        switch slot {
                        case .filled(let token):
                            TokenView(
                                token: token,
                                size: tokenSize,
                                isPlaced: lastPlacedIndex == index
                            )
                            .transition(.scale.combined(with: .opacity))
                        case .blank:
                            BlankSlotView(
                                size: tokenSize,
                                isActive: activeBlankIndex == index,
                                isShaking: shakeBlankIndex == index
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 22)
        }
        .background {
            ZStack {
                Capsule(style: .continuous)
                    .fill(AppTheme.trayGradient)
                    .overlay {
                        Capsule(style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.28),
                                        Color.clear,
                                        Color.black.opacity(0.12)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.55),
                                        Color.white.opacity(0.12)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    }
                    .shadow(color: AppTheme.trayDeep.opacity(0.35), radius: 22, y: 12)
                    .shadow(color: AppTheme.ink.opacity(0.08), radius: 4, y: 1)

                // Inner groove
                Capsule(style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 3)
                    .padding(7)
                    .blur(radius: 0.5)
            }
            .padding(.horizontal, 6)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Pattern path")
    }
}
