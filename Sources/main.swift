import Cocoa

/// `ClaudeSwitch --list` prints sessions; `--focus <pid>` jumps to one.
/// Handy for scripting and for testing adapters without the UI.
func runCommandLine(_ args: [String]) -> Bool {
    if args.contains("--list") {
        for s in SessionRegistry.load() {
            let state = s.isWaiting ? "waiting" : "working"
            print("\(s.pid)\t\(state)\t\(s.tty ?? "-")\t\(s.terminalName)\t\(s.name)\t\(Formatting.shortPath(s.cwd))")
        }
        return true
    }
    if let i = args.firstIndex(of: "--focus"), i + 1 < args.count, let pid = Int32(args[i + 1]) {
        guard let s = SessionRegistry.load().first(where: { $0.pid == pid }) else {
            print("no live session with pid \(pid)")
            return true
        }
        print(TerminalFocus.focus(s) ? "focused \(s.name)" : "could not locate window for \(s.name)")
        return true
    }
    return false
}

if runCommandLine(CommandLine.arguments) { exit(0) }

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
