import Cocoa
import ApplicationServices

/// Generic fallback for terminals without an exact adapter (kitty, Warp,
/// Ghostty, WezTerm, Alacritty, IDE terminals...). Claude Code writes the
/// session name into the terminal title, so we raise the window whose title
/// mentions the session name or its tty. Tabs inside one window cannot be
/// switched this way; only the active tab's title is visible to Accessibility.
struct AccessibilityAdapter {
    @discardableResult
    func focus(_ session: Session) -> Bool {
        guard let bundleId = session.terminalBundleId,
              let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first
        else { return false }

        Self.ensurePermission(prompt: true)
        let needles = [session.name, session.tty].compactMap { $0 }
        let windows = Self.windows(of: app.processIdentifier)

        for window in windows where needles.contains(where: { Self.title(of: window).localizedCaseInsensitiveContains($0) }) {
            AXUIElementPerformAction(window, kAXRaiseAction as CFString)
            AppleScriptRunner.activate(bundleId: bundleId)
            return true
        }
        AppleScriptRunner.activate(bundleId: bundleId)
        return false
    }

    static func windows(of pid: pid_t) -> [AXUIElement] {
        var ref: CFTypeRef?
        AXUIElementCopyAttributeValue(AXUIElementCreateApplication(pid), kAXWindowsAttribute as CFString, &ref)
        return ref as? [AXUIElement] ?? []
    }

    static func title(of window: AXUIElement) -> String {
        var ref: CFTypeRef?
        AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &ref)
        return ref as? String ?? ""
    }

    @discardableResult
    static func ensurePermission(prompt: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        return AXIsProcessTrustedWithOptions([key: prompt] as CFDictionary)
    }
}
