import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    let switcher = SwitcherController()
    private var hotKey: HotKey?
    private var statusBar: StatusBar?
    private var keyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let comboText = UserDefaults.standard.string(forKey: "hotkey") ?? HotKeyParser.defaultCombo
        let combo = HotKeyParser.parse(comboText) ?? HotKeyParser.parse(HotKeyParser.defaultCombo)!
        hotKey = HotKey(keyCode: combo.keyCode, modifiers: combo.modifiers) { [weak self] in self?.switcher.toggle() }
        statusBar = StatusBar(hotkeyDisplay: combo.display) { [weak self] in self?.switcher.show() }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.switcher.handleCommandKey(event) == true ? nil : event
        }
        AccessibilityAdapter.ensurePermission(prompt: true)
    }
}
