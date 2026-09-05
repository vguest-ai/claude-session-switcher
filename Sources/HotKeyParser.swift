import Carbon

/// Parses "alt+space", "ctrl+shift+k" etc. into a Carbon key code and modifiers.
enum HotKeyParser {
    struct Combo {
        let keyCode: UInt32
        let modifiers: UInt32
        let display: String
    }

    static let defaultCombo = "alt+space"

    private static let modifierNames: [String: (UInt32, String)] = [
        "cmd": (UInt32(cmdKey), "⌘"), "command": (UInt32(cmdKey), "⌘"),
        "ctrl": (UInt32(controlKey), "⌃"), "control": (UInt32(controlKey), "⌃"),
        "alt": (UInt32(optionKey), "⌥"), "opt": (UInt32(optionKey), "⌥"), "option": (UInt32(optionKey), "⌥"),
        "shift": (UInt32(shiftKey), "⇧"),
    ]

    private static let keyNames: [String: (Int, String)] = [
        "space": (kVK_Space, "Space"), "tab": (kVK_Tab, "⇥"), "return": (kVK_Return, "↩"),
        "enter": (kVK_Return, "↩"), "escape": (kVK_Escape, "⎋"), "esc": (kVK_Escape, "⎋"),
        "`": (kVK_ANSI_Grave, "`"), "-": (kVK_ANSI_Minus, "-"), "=": (kVK_ANSI_Equal, "="),
        "a": (kVK_ANSI_A, "A"), "b": (kVK_ANSI_B, "B"), "c": (kVK_ANSI_C, "C"), "d": (kVK_ANSI_D, "D"),
        "e": (kVK_ANSI_E, "E"), "f": (kVK_ANSI_F, "F"), "g": (kVK_ANSI_G, "G"), "h": (kVK_ANSI_H, "H"),
        "i": (kVK_ANSI_I, "I"), "j": (kVK_ANSI_J, "J"), "k": (kVK_ANSI_K, "K"), "l": (kVK_ANSI_L, "L"),
        "m": (kVK_ANSI_M, "M"), "n": (kVK_ANSI_N, "N"), "o": (kVK_ANSI_O, "O"), "p": (kVK_ANSI_P, "P"),
        "q": (kVK_ANSI_Q, "Q"), "r": (kVK_ANSI_R, "R"), "s": (kVK_ANSI_S, "S"), "t": (kVK_ANSI_T, "T"),
        "u": (kVK_ANSI_U, "U"), "v": (kVK_ANSI_V, "V"), "w": (kVK_ANSI_W, "W"), "x": (kVK_ANSI_X, "X"),
        "y": (kVK_ANSI_Y, "Y"), "z": (kVK_ANSI_Z, "Z"),
        "0": (kVK_ANSI_0, "0"), "1": (kVK_ANSI_1, "1"), "2": (kVK_ANSI_2, "2"), "3": (kVK_ANSI_3, "3"),
        "4": (kVK_ANSI_4, "4"), "5": (kVK_ANSI_5, "5"), "6": (kVK_ANSI_6, "6"), "7": (kVK_ANSI_7, "7"),
        "8": (kVK_ANSI_8, "8"), "9": (kVK_ANSI_9, "9"),
    ]

    static func parse(_ text: String) -> Combo? {
        var modifiers: UInt32 = 0
        var display = ""
        var key: (Int, String)?
        for raw in text.lowercased().split(separator: "+") {
            let token = raw.trimmingCharacters(in: .whitespaces)
            if let mod = modifierNames[token] {
                modifiers |= mod.0
                display += mod.1
            } else if let k = keyNames[token] {
                key = k
            } else {
                return nil
            }
        }
        guard let key, modifiers != 0 else { return nil }
        return Combo(keyCode: UInt32(key.0), modifiers: modifiers, display: display + key.1)
    }
}
