import Cocoa

/// Menu bar item showing how many sessions are waiting for you.
final class StatusBar {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var timer: Timer?

    init(hotkeyDisplay: String, onShow: @escaping () -> Void) {
        let menu = NSMenu()
        let show = NSMenuItem(title: "Show sessions  \(hotkeyDisplay)", action: #selector(NSApplication.showSwitcher), keyEquivalent: "")
        menu.addItem(show)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Relaunch", action: #selector(NSApplication.relaunch), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in self?.refresh() }
    }

    private func refresh() {
        let sessions = SessionRegistry.load()
        let waiting = sessions.filter(\.isWaiting).count
        guard let button = item.button else { return }
        let text = NSMutableAttributedString()
        let dotColor: NSColor = waiting > 0 ? .systemYellow : (sessions.isEmpty ? .tertiaryLabelColor : .systemGreen)
        text.append(NSAttributedString(string: "●", attributes: [.foregroundColor: dotColor, .font: NSFont.systemFont(ofSize: 11)]))
        if !sessions.isEmpty {
            text.append(NSAttributedString(string: " \(waiting)/\(sessions.count)", attributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)]))
        }
        button.attributedTitle = text
        button.toolTip = "\(waiting) waiting · \(sessions.count) running"
    }
}

extension NSApplication {
    @objc func showSwitcher() {
        (delegate as? AppDelegate)?.switcher.show()
    }

    /// Quits and reopens this same bundle, picking up a new build or hotkey.
    @objc func relaunch() {
        let reopen = Process()
        reopen.executableURL = URL(fileURLWithPath: "/bin/sh")
        reopen.arguments = ["-c", "sleep 0.5; open \"\(Bundle.main.bundlePath)\""]
        try? reopen.run()
        terminate(nil)
    }
}
