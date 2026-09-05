import Foundation

/// Brings the terminal window/tab hosting a session to the front.
///
/// Add exact support for a new terminal by implementing this protocol and
/// registering it in `TerminalFocus.adapters`. Anything without an adapter
/// falls back to `AccessibilityAdapter`, which matches on window title.
protocol TerminalAdapter {
    /// Bundle ids this adapter handles.
    var bundleIds: [String] { get }
    /// Returns true when the session's window was found and raised.
    func focus(_ session: Session) -> Bool
}

enum TerminalFocus {
    static let adapters: [TerminalAdapter] = [
        ITerm2Adapter(),
        AppleTerminalAdapter(),
    ]

    @discardableResult
    static func focus(_ session: Session) -> Bool {
        if let id = session.terminalBundleId,
           let adapter = adapters.first(where: { $0.bundleIds.contains(id) }),
           adapter.focus(session) {
            return true
        }
        return AccessibilityAdapter().focus(session)
    }
}
