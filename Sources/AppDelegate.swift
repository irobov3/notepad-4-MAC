import Cocoa

public class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var mainVC: MainViewController!

    public func applicationDidFinishLaunching(_ notification: Notification) {
        ProcessInfo.processInfo.disableAutomaticTermination("User interactive text editor")
        NSApp.setActivationPolicy(.regular)

        mainVC = MainViewController()

        let windowSize = NSSize(width: 960, height: 640)
        let screenRect = NSScreen.main?.visibleFrame ?? NSRect(x: 100, y: 100, width: 960, height: 640)
        let windowRect = NSRect(
            x: screenRect.midX - windowSize.width / 2,
            y: screenRect.midY - windowSize.height / 2,
            width: windowSize.width,
            height: windowSize.height
        )

        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.isRestorable = false
        window.title = "Notepad++ for Mac"
        window.contentViewController = mainVC
        window.contentView?.wantsLayer = true
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.setIsVisible(true)

        // Set app icon dynamically
        if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
           let iconImg = NSImage(contentsOfFile: iconPath) {
            NSApp.applicationIconImage = iconImg
        } else if let iconPng = Bundle.main.path(forResource: "AppIcon", ofType: "png"),
                  let iconImg = NSImage(contentsOfFile: iconPng) {
            NSApp.applicationIconImage = iconImg
        }

        setupMainMenu()
        NSApp.activate(ignoringOtherApps: true)
    }

    public func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return false
    }

    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()

        // 1. Application Menu
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Notepad++ for Mac", action: #selector(showAbout), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit Notepad++ for Mac", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // 2. File Menu
        let fileMenuItem = NSMenuItem()
        let fileMenu = NSMenu(title: "File")
        fileMenu.addItem(withTitle: "New", action: #selector(handleNew), keyEquivalent: "n")
        fileMenu.addItem(withTitle: "Open...", action: #selector(handleOpen), keyEquivalent: "o")
        fileMenu.addItem(withTitle: "Save", action: #selector(handleSave), keyEquivalent: "s")
        fileMenu.addItem(withTitle: "Save All", action: #selector(handleSaveAll), keyEquivalent: "S")
        fileMenu.addItem(withTitle: "Close", action: #selector(handleCloseTab), keyEquivalent: "w")
        fileMenuItem.submenu = fileMenu
        mainMenu.addItem(fileMenuItem)

        // 3. Edit Menu
        let editMenuItem = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: #selector(UndoManager.undo), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Redo", action: #selector(UndoManager.redo), keyEquivalent: "Z")
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu
        mainMenu.addItem(editMenuItem)

        // 4. Search Menu
        let searchMenuItem = NSMenuItem()
        let searchMenu = NSMenu(title: "Search")
        searchMenu.addItem(withTitle: "Find...", action: #selector(handleFind), keyEquivalent: "f")
        searchMenu.addItem(withTitle: "Replace...", action: #selector(handleFind), keyEquivalent: "h")
        searchMenuItem.submenu = searchMenu
        mainMenu.addItem(searchMenuItem)

        // 5. View Menu
        let viewMenuItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Zoom In", action: #selector(handleZoomIn), keyEquivalent: "+")
        viewMenu.addItem(withTitle: "Zoom Out", action: #selector(handleZoomOut), keyEquivalent: "-")
        viewMenuItem.submenu = viewMenu
        mainMenu.addItem(viewMenuItem)

        // 6. Language Menu (Classic Notepad++ languages list)
        let langMenuItem = NSMenuItem()
        let langMenu = NSMenu(title: "Language")
        for lang in SyntaxLanguage.allCases {
            let item = NSMenuItem(title: lang.rawValue, action: #selector(selectLanguage(_:)), keyEquivalent: "")
            item.representedObject = lang
            langMenu.addItem(item)
        }
        langMenuItem.submenu = langMenu
        mainMenu.addItem(langMenuItem)

        NSApp.mainMenu = mainMenu
    }

    @objc private func handleNew() { mainVC.createNewDocument() }
    @objc private func handleOpen() { mainVC.openDocument() }
    @objc private func handleSave() { mainVC.saveActiveDocument() }
    @objc private func handleSaveAll() { mainVC.saveAllDocuments() }
    @objc private func handleCloseTab() { mainVC.closeDocument(at: mainVC.activeIndex) }
    @objc private func handleFind() { mainVC.toggleFindBar() }
    @objc private func handleZoomIn() { _ = mainVC.view }
    @objc private func handleZoomOut() { _ = mainVC.view }

    @objc private func selectLanguage(_ sender: NSMenuItem) {
        guard let lang = sender.representedObject as? SyntaxLanguage,
              !mainVC.documents.isEmpty, mainVC.activeIndex < mainVC.documents.count else { return }
        mainVC.documents[mainVC.activeIndex].language = lang
        mainVC.selectTab(at: mainVC.activeIndex)
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Notepad++ for Mac"
        alert.informativeText = "Version 1.0.0 (Apple Silicon)\n\nInspired by Notepad++ and developed by iRoBo.\n\nA native, high-performance macOS text editor featuring Scintilla-style syntax highlighting, tab management, line ruler gutter, and classic Notepad++ status telemetry."
        alert.alertStyle = .informational
        if let icon = NSApp.applicationIconImage {
            alert.icon = icon
        } else if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
                  let iconImg = NSImage(contentsOfFile: iconPath) {
            alert.icon = iconImg
        } else if let iconPng = Bundle.main.path(forResource: "AppIcon", ofType: "png"),
                  let iconImg = NSImage(contentsOfFile: iconPng) {
            alert.icon = iconImg
        }
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
