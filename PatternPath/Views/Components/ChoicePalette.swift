import SwiftUI

struct ChoicePalette: View {
    let choices: [PatternToken]
    var focus: PatternFocus = .color
    var wrongChoiceID: UUID?
    var tokenSize: CGFloat = 84
    var onSelect: (PatternToken) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(focus == .color ? "Tap the color that fits" : "Tap the shape that fits")
                .font(.bodyRounded(17, weight: .semibold))
                .foregroundStyle(AppTheme.inkSoft)
                .tracking(0.2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
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
                            .padding(10)
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
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .frame(maxWidth: 720)
        .glassSurface(cornerRadius: 36, intense: true)
    }
}
