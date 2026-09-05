# Claude Switch

A Spotlight-style switcher for your running [Claude Code](https://claude.com/claude-code) sessions on macOS.

Press a hotkey, see every live session with its name, color and state, pick one, and the terminal tab running it comes to the front.

```
┌──────────────────────────────────────────────────────────────┐
│  Jump to session…                                            │
├──────────────────────────────────────────────────────────────┤
│  ●  ● billing-reconciliation                     waiting 3m  │
│       ~/code/billing  ·  iTerm2                          ⌘1  │
│  ●  ● api-refactor                                  working  │
│       ~/code/api  ·  Terminal                            ⌘2  │
│  ●  ● docs-site                                     working  │
│       ~/code/docs  ·  kitty                              ⌘3  │
└──────────────────────────────────────────────────────────────┘
```

- **Yellow dot** – Claude finished its turn and is waiting for you.
- **Green dot** – Claude is still working.
- **Color swatch** – a stable color per session so you recognise them at a glance.
- Sessions waiting for you are listed first, most recently finished on top.
- Menu bar item shows `waiting / running` counts.

## Install

Requires macOS 13+ and the Xcode Command Line Tools (`xcode-select --install`).

```sh
git clone https://github.com/vguest-ai/claude-session-switcher.git
cd claude-session-switcher
./build.sh
cp -r build/ClaudeSwitch.app /Applications/
open /Applications/ClaudeSwitch.app
```

On first use macOS will ask for two permissions:

1. **Automation** (control iTerm2 / Terminal) – needed to select the exact tab.
2. **Accessibility** – needed for the generic fallback used by other terminals.

To start it at login: System Settings → General → Login Items → add ClaudeSwitch.

## Usage

| Key | Action |
|---|---|
| `⌥ Space` | Open / close the switcher |
| type | Filter by session name or folder |
| `↑` `↓` | Move selection |
| `↩` | Jump to the selected session |
| `⌘1` … `⌘9` | Jump straight to row N |
| `⎋` | Close |

Change the hotkey (any combination of `cmd`, `ctrl`, `alt`, `shift` plus a key):

```sh
defaults write ai.vguest.claude-switch hotkey "ctrl+alt+space"
```

Restart the app after changing it.

### Command line

The binary inside the bundle doubles as a CLI, useful for scripts and for testing:

```sh
/Applications/ClaudeSwitch.app/Contents/MacOS/ClaudeSwitch --list
/Applications/ClaudeSwitch.app/Contents/MacOS/ClaudeSwitch --focus <pid>
```

## How it works

Claude Code writes a small JSON file per running session to `~/.claude/sessions/<pid>.json` containing the session name, working directory and whether it is `idle` or `busy`. The app reads those files, checks the process is still alive, finds its controlling tty and walks the process tree to learn which terminal app hosts it.

Focusing the right tab depends on the terminal:

| Terminal | Method | Precision |
|---|---|---|
| iTerm2 | AppleScript, match by tty | exact window, tab and split pane |
| Terminal.app | AppleScript, match by tty | exact window and tab |
| everything else | Accessibility API, match window title | window only (the active tab's title is all that is visible) |

Claude Code puts the session name in the terminal title, which is what makes the generic fallback work for kitty, Warp, Ghostty, WezTerm, Alacritty, VS Code and others.

## Adding exact support for another terminal

Implement `TerminalAdapter` (see `Sources/Terminals/`) with the terminal's bundle id and a `focus(_:)` that selects the tab owning `session.tty`, then add it to `TerminalFocus.adapters`. Kitty's remote control (`kitty @ focus-window --match pid:<pid>`) and WezTerm's `wezterm cli activate-pane` are natural candidates. Pull requests welcome.

## Screenshots for docs

Launch with `--demo` to fill the popup with generic sessions, so screenshots never show real project names:

```sh
open /Applications/ClaudeSwitch.app --args --demo
```

## Privacy

Everything runs locally. The app only reads `~/.claude/sessions` and talks to the terminal apps on your Mac. Nothing is sent anywhere.

## License

MIT
