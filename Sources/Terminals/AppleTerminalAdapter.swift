import Foundation

/// Terminal.app exposes each tab's tty over AppleScript.
struct AppleTerminalAdapter: TerminalAdapter {
    let bundleIds = ["com.apple.Terminal"]

    func focus(_ session: Session) -> Bool {
        guard let tty = session.tty else { return false }
        let script = """
        tell application "Terminal"
            repeat with w in windows
                repeat with t in tabs of w
                    if tty of t is "/dev/\(tty)" then
                        set selected tab of w to t
                        set index of w to 1
                        set frontmost of w to true
                        activate
                        return true
                    end if
                end repeat
            end repeat
            return false
        end tell
        """
        return AppleScriptRunner.runBool(script)
    }
}
