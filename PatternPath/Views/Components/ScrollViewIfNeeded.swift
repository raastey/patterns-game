import SwiftUI

struct ScrollViewIfNeeded<Content: View>: View {
    var enabled: Bool
    @ViewBuilder var content: () -> Content

    var body: some View {
        if enabled {
            ScrollView(showsIndicators: false) {
                content()
            }
        } else {
            content()
        }
    }
}
