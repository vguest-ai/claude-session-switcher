import Foundation
import Darwin

/// Read-only process inspection via sysctl / libproc. No subprocesses.
enum ProcessTree {
    static func isAlive(_ pid: Int32) -> Bool {
        kill(pid, 0) == 0 || errno == EPERM
    }

    static func info(_ pid: Int32) -> kinfo_proc? {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        var kp = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        let rc = sysctl(&mib, UInt32(mib.count), &kp, &size, nil, 0)
        guard rc == 0, size > 0, kp.kp_proc.p_pid == pid else { return nil }
        return kp
    }

    /// Controlling terminal name, e.g. "ttys004".
    static func tty(_ pid: Int32) -> String? {
        guard let kp = info(pid) else { return nil }
        let dev = kp.kp_eproc.e_tdev
        guard dev != -1, let name = devname(dev, S_IFCHR) else { return nil }
        return String(cString: name)
    }

    static func path(_ pid: Int32) -> String? {
        var buf = [CChar](repeating: 0, count: 4 * Int(MAXPATHLEN))
        let n = proc_pidpath(pid, &buf, UInt32(buf.count))
        return n > 0 ? String(cString: buf) : nil
    }

    /// Walks up the parent chain and returns the bundle id of the outermost
    /// .app ancestor - the terminal emulator (or IDE) hosting this process.
    static func owningAppBundleId(_ pid: Int32) -> String? {
        var current = pid
        var found: String?
        var hops = 0
        while current > 1, hops < 32 {
            hops += 1
            if let p = path(current), let range = p.range(of: ".app/") {
                let bundlePath = String(p[..<range.lowerBound]) + ".app"
                if let id = Bundle(path: bundlePath)?.bundleIdentifier { found = id }
            }
            guard let kp = info(current) else { break }
            current = kp.kp_eproc.e_ppid
        }
        return found
    }
}
