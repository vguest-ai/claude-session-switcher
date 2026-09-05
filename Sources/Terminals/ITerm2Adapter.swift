import Foundation

/// iTerm2 exposes each session's tty over AppleScript, so we can select the
/// exact window, tab and split pane.
struct ITerm2Adapter: TerminalAdapter {
    let bundleIds = ["com.googlecode.iterm2"]

    func focus(_ session: Session) -> Bool {
        guard let tty = session.tty else { return false }
        let script = """
        tell application "iTerm2"
            repeat with w in windows
                repeat with t in tabs of w
                    repeat with s in sessions of t
                        if tty of s is "/dev/\(tty)" then
                            select w
                            select t
                            select s
                            activate
                            return true
                        end if
                    end repeat
                end repeat
            end repeat
            return false
        end tell
        """
        return AppleScriptRunner.runBool(script)
    }
}
