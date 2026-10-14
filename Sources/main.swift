import Cocoa

final class AppContainer {
    static let shared = AppContainer()
    let delegate = AppDelegate()
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
app.delegate = AppContainer.shared.delegate
app.run()
