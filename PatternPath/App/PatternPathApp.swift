import SwiftUI

@main
struct PatternPathApp: App {
    init() {
        #if DEBUG
        assert(LevelLogicTests.run(), "Level catalog failed validation")
        assert(GameSessionTests.run(), "Game session tests failed")
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
