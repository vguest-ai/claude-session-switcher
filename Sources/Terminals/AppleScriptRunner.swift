import Foundation

enum AppleScriptRunner {
    /// Runs a script that returns a boolean. Errors are logged and count as false.
    static func runBool(_ source: String) -> Bool {
        var error: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return false }
        let result = script.executeAndReturnError(&error)
        if let error {
            NSLog("AppleScript failed: %@", error)
            return false
        }
        return result.booleanValue
    }

    static func activate(bundleId: String) {
        _ = runBool("tell application id \"\(bundleId)\" to activate\nreturn true")
    }
}
