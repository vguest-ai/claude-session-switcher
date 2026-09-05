import Foundation

/// Reads the session registry Claude Code maintains in ~/.claude/sessions.
/// Each live interactive session writes <pid>.json with its name and status.
enum SessionRegistry {
    /// Set by `--demo`; serves DemoSessions instead of the real registry.
    static var demo = false

    static var directory: URL {
        let base = ProcessInfo.processInfo.environment["CLAUDE_CONFIG_DIR"]
            .map(URL.init(fileURLWithPath:))
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude")
        return base.appendingPathComponent("sessions")
    }

    static func load() -> [Session] {
        if demo { return DemoSessions.list }
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return [] }
        let sessions = files
            .filter { $0.pathExtension == "json" }
            .compactMap(parse)
        return sessions.sorted(by: order)
    }

    private static func parse(_ file: URL) -> Session? {
        guard let data = try? Data(contentsOf: file),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let pidValue = obj["pid"] as? Int else { return nil }
        let pid = Int32(pidValue)
        guard ProcessTree.isAlive(pid) else { return nil }

        func date(_ key: String) -> Date {
            let ms = (obj[key] as? Double) ?? 0
            return Date(timeIntervalSince1970: ms / 1000)
        }

        return Session(
            pid: pid,
            sessionId: obj["sessionId"] as? String ?? file.deletingPathExtension().lastPathComponent,
            name: obj["name"] as? String ?? "session \(pid)",
            cwd: obj["cwd"] as? String ?? "",
            kind: obj["kind"] as? String ?? "interactive",
            status: obj["status"] as? String ?? "idle",
            statusUpdatedAt: date("statusUpdatedAt"),
            startedAt: date("startedAt"),
            tty: ProcessTree.tty(pid),
            terminalBundleId: ProcessTree.owningAppBundleId(pid)
        )
    }

    /// Sessions waiting for the user come first, most recently finished on top.
    private static func order(_ a: Session, _ b: Session) -> Bool {
        if a.isWaiting != b.isWaiting { return a.isWaiting }
        return a.statusUpdatedAt > b.statusUpdatedAt
    }
}
