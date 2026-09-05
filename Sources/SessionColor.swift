import Cocoa

/// A stable color per session, derived from its id so it survives renames.
enum SessionColor {
    private static let palette: [NSColor] = [
        NSColor(red: 0.96, green: 0.40, blue: 0.40, alpha: 1),  // coral
        NSColor(red: 0.98, green: 0.62, blue: 0.24, alpha: 1),  // orange
        NSColor(red: 0.95, green: 0.82, blue: 0.25, alpha: 1),  // gold
        NSColor(red: 0.45, green: 0.80, blue: 0.40, alpha: 1),  // green
        NSColor(red: 0.30, green: 0.78, blue: 0.75, alpha: 1),  // teal
        NSColor(red: 0.36, green: 0.62, blue: 0.98, alpha: 1),  // blue
        NSColor(red: 0.58, green: 0.50, blue: 0.98, alpha: 1),  // violet
        NSColor(red: 0.92, green: 0.45, blue: 0.80, alpha: 1),  // pink
        NSColor(red: 0.70, green: 0.55, blue: 0.40, alpha: 1),  // brown
        NSColor(red: 0.55, green: 0.75, blue: 0.95, alpha: 1),  // sky
    ]

    static func color(for session: Session) -> NSColor {
        palette[Int(fnv1a(session.sessionId) % UInt64(palette.count))]
    }

    /// Deterministic across launches, unlike Swift's randomized Hashable.
    private static func fnv1a(_ s: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in s.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }
}
