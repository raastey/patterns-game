import SwiftUI

struct CoachBanner: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppTheme.accentDeep)
            Text(text)
                .font(.bodyRounded(15, weight: .semibold))
                .foregroundStyle(AppTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AppTheme.accent.opacity(0.35), lineWidth: 1.5)
                }
                .shadow(color: AppTheme.ink.opacity(0.12), radius: 12, y: 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}
