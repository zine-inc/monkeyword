import MonkeywordCore
import SwiftUI

@main
struct MonkeywordApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(repository: MockRepository())
        }
    }
}
