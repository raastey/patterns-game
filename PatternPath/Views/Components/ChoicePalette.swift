import SwiftUI

struct ChoicePalette: View {
    let choices: [PatternToken]
    var focus: PatternFocus = .color
    var wrongChoiceID: UUID?
    var tokenSize: CGFloat = 84
    var compact: Bool = false
    var onSelect: (PatternToken) -> Void

    var body: some View {
        VStack(spacing: compact ? 8 : 12) {
            Text(focus == .color ? "Tap the color that fits" : "Tap the toy that fits")
                .font(.bodyRounded(compact ? 15 : 18, weight: .bold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            ViewThatFits(in: .horizontal) {
                choiceRow(spacing: compact ? 12 : 18)
                ScrollView(.horizontal, showsIndicators: false) {
                    choiceRow(spacing: compact ? 10 : 14)
                        .padding(.horizontal, 4)
                }
            }
        }
        .padding(.horizontal, compact ? 14 : 20)
        .padding(.top, compact ? 12 : 16)
        .padding(.bottom, compact ? 12 : 18)
        .frame(maxWidth: .infinity)
        .background { shelfBackground }
    }

    private func choiceRow(spacing: CGFloat) -> some View {
        HStack(spacing: spacing) {
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
                    .padding(compact ? 4 : 6)
                    .background {
                        RoundedRectangle(cornerRadius: tokenSize * 0.28, style: .continuous)
                            .fill(Color.white)
                            .shadow(
                                color: AppTheme.ink.opacity(wrongChoiceID == choice.id ? 0.18 : 0.10),
                                radius: wrongChoiceID == choice.id ? 12 : 8,
                                y: 4
                            )
                    }
                }
                .buttonStyle(PremiumPressStyle())
                .accessibilityHint("Places this toy on the garage board")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var shelfBackground: some View {
        let radius: CGFloat = compact ? 22 : 28
        return RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [AppTheme.shelfTop, Color.white, AppTheme.shelfEdge.opacity(0.35)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .top) {
                Capsule()
                    .fill(AppTheme.shelfEdge.opacity(0.55))
                    .frame(width: 56, height: 5)
                    .padding(.top, 8)
            }
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(AppTheme.shelfEdge.opacity(0.45), lineWidth: 2)
            }
            .shadow(color: Color.black.opacity(0.18), radius: 16, y: -4)
    }
}
