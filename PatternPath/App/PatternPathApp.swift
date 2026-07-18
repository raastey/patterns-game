import SwiftUI

@main
struct PatternPathApp: App {
    init() {
        #if DEBUG
        assert(LevelLogicTests.run(), "Level catalog failed validation")
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .statusBarHidden(true)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
    }
}
