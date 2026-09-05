import Cocoa

/// Owns the popup: search field on top, session list below, keyboard driven.
final class SwitcherController: NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    private let width: CGFloat = 640
    private let searchHeight: CGFloat = 52
    private let maxRows = 8

    private let panel: SwitcherPanel
    private let search = NSTextField()
    private let table = NSTableView()
    private let scroll = NSScrollView()
    private let empty = NSTextField(labelWithString: "No running Claude Code sessions")

    private var all: [Session] = []
    private var shown: [Session] = []
    private var refreshTimer: Timer?

    override init() {
        panel = SwitcherPanel(width: width)
        super.init()
        buildViews()
        NotificationCenter.default.addObserver(self, selector: #selector(hide), name: NSWindow.didResignKeyNotification, object: panel)
    }

    var isVisible: Bool { panel.isVisible }

    func toggle() { isVisible ? hide() : show() }

    func show() {
        reload()
        search.stringValue = ""
        applyFilter()
        panel.makeKeyAndOrderFront(nil)
        panel.makeFirstResponder(search)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.reload() }
    }

    @objc func hide() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        panel.orderOut(nil)
    }

    // MARK: data

    private func reload() {
        all = SessionRegistry.load()
        applyFilter()
    }

    private func applyFilter() {
        let q = search.stringValue.trimmingCharacters(in: .whitespaces)
        shown = q.isEmpty ? all : all.filter {
            $0.name.localizedCaseInsensitiveContains(q) || Formatting.shortPath($0.cwd).localizedCaseInsensitiveContains(q)
        }
        let selected = max(0, min(table.selectedRow, shown.count - 1))
        table.reloadData()
        if !shown.isEmpty { table.selectRowIndexes([selected], byExtendingSelection: false) }
        empty.isHidden = !shown.isEmpty
        resize()
    }

    private func resize() {
        let rows = CGFloat(min(max(shown.count, 1), maxRows))
        panel.place(height: searchHeight + rows * SessionRowView.height + 8)
    }

    private func choose(row: Int) {
        guard shown.indices.contains(row) else { return }
        let session = shown[row]
        hide()
        DispatchQueue.global().async { TerminalFocus.focus(session) }
    }

    private func move(by delta: Int) {
        guard !shown.isEmpty else { return }
        let next = (table.selectedRow + delta + shown.count) % shown.count
        table.selectRowIndexes([next], byExtendingSelection: false)
        table.scrollRowToVisible(next)
    }

    // MARK: views

    private func buildViews() {
        guard let content = panel.contentView else { return }

        search.placeholderString = "Jump to session…"
        search.font = .systemFont(ofSize: 20, weight: .regular)
        search.isBordered = false
        search.drawsBackground = false
        search.focusRingType = .none
        search.delegate = self

        let column = NSTableColumn(identifier: .init("main"))
        table.addTableColumn(column)
        table.headerView = nil
        table.rowHeight = SessionRowView.height
        table.backgroundColor = .clear
        table.selectionHighlightStyle = .regular
        table.style = .inset
        table.intercellSpacing = .zero
        table.dataSource = self
        table.delegate = self
        table.target = self
        table.action = #selector(clicked)

        scroll.documentView = table
        scroll.drawsBackground = false
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true

        empty.textColor = .secondaryLabelColor
        empty.alignment = .center

        let separator = NSBox()
        separator.boxType = .separator

        for v in [search, separator, scroll, empty] {
            v.translatesAutoresizingMaskIntoConstraints = false
            content.addSubview(v)
        }
        NSLayoutConstraint.activate([
            search.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 20),
            search.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -20),
            search.topAnchor.constraint(equalTo: content.topAnchor, constant: 14),
            separator.topAnchor.constraint(equalTo: content.topAnchor, constant: searchHeight),
            separator.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 4),
            scroll.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -4),
            empty.centerXAnchor.constraint(equalTo: scroll.centerXAnchor),
            empty.centerYAnchor.constraint(equalTo: scroll.centerYAnchor),
        ])
    }

    @objc private func clicked() { choose(row: table.clickedRow) }

    // MARK: table

    func numberOfRows(in tableView: NSTableView) -> Int { shown.count }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("row")
        let view = tableView.makeView(withIdentifier: id, owner: nil) as? SessionRowView ?? {
            let v = SessionRowView(frame: .zero)
            v.identifier = id
            return v
        }()
        view.configure(shown[row], index: row)
        return view
    }

    // MARK: keyboard

    func controlTextDidChange(_ notification: Notification) { applyFilter() }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
        switch selector {
        case #selector(NSResponder.moveDown(_:)): move(by: 1)
        case #selector(NSResponder.moveUp(_:)): move(by: -1)
        case #selector(NSResponder.insertNewline(_:)): choose(row: table.selectedRow)
        case #selector(NSResponder.cancelOperation(_:)): hide()
        default: return false
        }
        return true
    }

    /// Command shortcuts while the popup is open: ⌘1…⌘9 pick a row,
    /// ⌘R relaunches the app, ⌘Q quits. Called from the app's key monitor.
    func handleCommandKey(_ event: NSEvent) -> Bool {
        guard isVisible, event.modifierFlags.contains(.command),
              let ch = event.charactersIgnoringModifiers?.lowercased() else { return false }
        if let n = Int(ch), (1...9).contains(n) {
            choose(row: n - 1)
        } else if ch == "r" {
            NSApp.relaunch()
        } else if ch == "q" {
            NSApp.terminate(nil)
        } else {
            return false
        }
        return true
    }
}
