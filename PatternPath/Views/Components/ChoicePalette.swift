import SwiftUI

struct ChoicePalette: View {
    let choices: [PatternToken]
    var focus: PatternFocus = .color
    var wrongChoiceID: UUID?
    var tokenSize: CGFloat = 84
    var compact: Bool = false
    var onSelect: (PatternToken) -> Void

    var body: some View {
        VStack(spacing: compact ? 8 : 14) {
            Text(focus == .color ? "Tap the color that fits" : "Tap the toy that fits")
                .font(.bodyRounded(compact ? 14 : 17, weight: .semibold))
                .foregroundStyle(AppTheme.inkSoft)
                .tracking(0.2)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: compact ? 10 : 16) {
                    ForEach(choices) { choice in
                        Button {
                            HapticsPlayer.shared.select()
                            onSelect(choice)
                        } label: {
                            TokenView(
                                token: choice,
                                size: tokenSize,
                                isSelected: wrongChoiceID == choice.id
                            )
                            .padding(compact ? 6 : 10)
                            .background {
                                Circle()
                                    .fill(Color.white.opacity(wrongChoiceID == choice.id ? 0.55 : 0.28))
                                    .shadow(color: AppTheme.ink.opacity(0.06), radius: 8, y: 3)
                            }
                        }
                        .buttonStyle(PremiumPressStyle())
                        .accessibilityHint("Places this bead on the path")
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .padding(.horizontal, compact ? 14 : 22)
        .padding(.vertical, compact ? 12 : 20)
        .glassSurface(cornerRadius: compact ? 28 : 36, intense: true)
    }
}
