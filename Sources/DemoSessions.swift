import Foundation

/// Generic sessions shown with `--demo`, so screenshots for docs never
/// include anyone's real project names or paths.
enum DemoSessions {
    static let list: [Session] = [
        make("billing-reconciliation", "~/code/billing", idle: 120, id: "demo-1"),
        make("api-refactor", "~/code/api", idle: 900, id: "demo-2"),
        make("onboarding-flow", "~/code/web", idle: 5400, id: "demo-3"),
        make("docs-site", "~/code/docs", idle: nil, id: "demo-4"),
        make("mobile-release", "~/code/mobile", idle: nil, id: "demo-5"),
    ]

    private static func make(_ name: String, _ cwd: String, idle: TimeInterval?, id: String) -> Session {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return Session(
            pid: 0, sessionId: id, name: name,
            cwd: cwd.replacingOccurrences(of: "~", with: home),
            kind: "interactive",
            status: idle == nil ? "busy" : "idle",
            statusUpdatedAt: Date().addingTimeInterval(-(idle ?? 0)),
            startedAt: Date().addingTimeInterval(-7200),
            tty: nil, terminalBundleId: "com.googlecode.iterm2"
        )
    }
}
