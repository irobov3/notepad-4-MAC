#if os(iOS)
import SwiftUI

@main
public struct NotepadPadApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            MainView_iPad()
                .preferredColorScheme(nil) // Dynamic system or manual
        }
        .commands {
            SidebarCommands()
            TextEditingCommands()
        }
    }
}
#endif
