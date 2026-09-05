import Foundation

/// One running Claude Code session, as published in ~/.claude/sessions/<pid>.json.
struct Session {
    let pid: Int32
    let sessionId: String
    let name: String
    let cwd: String
    let kind: String
    let status: String          // "idle" or "busy"
    let statusUpdatedAt: Date
    let startedAt: Date
    let tty: String?            // e.g. "ttys004"
    let terminalBundleId: String?

    /// Idle means Claude finished its turn and is waiting for the user.
    var isWaiting: Bool { status == "idle" }

    var terminalName: String {
        guard let id = terminalBundleId else { return "unknown terminal" }
        return TerminalNames.displayName(for: id)
    }
}

enum TerminalNames {
    static let known: [String: String] = [
        "com.googlecode.iterm2": "iTerm2",
        "com.apple.Terminal": "Terminal",
        "net.kovidgoyal.kitty": "kitty",
        "dev.warp.Warp-Stable": "Warp",
        "com.mitchellh.ghostty": "Ghostty",
        "com.github.wez.wezterm": "WezTerm",
        "org.alacritty": "Alacritty",
        "com.microsoft.VSCode": "VS Code",
        "com.todesktop.230313mzl4w4u92": "Cursor",
    ]

    static func displayName(for bundleId: String) -> String {
        known[bundleId] ?? bundleId.split(separator: ".").last.map(String.init) ?? bundleId
    }
}
