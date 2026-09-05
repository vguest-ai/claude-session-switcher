import Cocoa

/// One row: session color swatch, name, status dot, cwd + terminal, waiting time.
final class SessionRowView: NSTableCellView {
    static let height: CGFloat = 54

    private let swatch = NSView()
    private let statusDot = NSView()
    private let nameLabel = NSTextField(labelWithString: "")
    private let detailLabel = NSTextField(labelWithString: "")
    private let sideLabel = NSTextField(labelWithString: "")
    private let hintLabel = NSTextField(labelWithString: "")

    override init(frame: NSRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func build() {
        swatch.wantsLayer = true
        swatch.layer?.cornerRadius = 7
        statusDot.wantsLayer = true
        statusDot.layer?.cornerRadius = 5

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.lineBreakMode = .byTruncatingTail
        detailLabel.font = .systemFont(ofSize: 12)
        detailLabel.textColor = .secondaryLabelColor
        detailLabel.lineBreakMode = .byTruncatingMiddle
        sideLabel.font = .systemFont(ofSize: 12, weight: .medium)
        sideLabel.alignment = .right
        hintLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        hintLabel.textColor = .tertiaryLabelColor
        hintLabel.alignment = .right

        for v in [swatch, statusDot, nameLabel, detailLabel, sideLabel, hintLabel] {
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
        }

        NSLayoutConstraint.activate([
            swatch.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            swatch.centerYAnchor.constraint(equalTo: centerYAnchor),
            swatch.widthAnchor.constraint(equalToConstant: 14),
            swatch.heightAnchor.constraint(equalToConstant: 14),

            statusDot.leadingAnchor.constraint(equalTo: swatch.trailingAnchor, constant: 12),
            statusDot.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 10),
            statusDot.heightAnchor.constraint(equalToConstant: 10),

            nameLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 9),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: sideLabel.leadingAnchor, constant: -12),

            detailLabel.leadingAnchor.constraint(equalTo: statusDot.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: hintLabel.leadingAnchor, constant: -12),

            sideLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            sideLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            hintLabel.centerYAnchor.constraint(equalTo: detailLabel.centerYAnchor),
        ])
    }

    func configure(_ s: Session, index: Int) {
        swatch.layer?.backgroundColor = SessionColor.color(for: s).cgColor
        nameLabel.stringValue = s.name

        let cwd = Formatting.shortPath(s.cwd)
        detailLabel.stringValue = "\(cwd)  ·  \(s.terminalName)"
        hintLabel.stringValue = index < 9 ? "⌘\(index + 1)" : ""

        if s.isWaiting {
            statusDot.layer?.backgroundColor = NSColor.systemYellow.cgColor
            sideLabel.stringValue = "waiting \(Formatting.relative(s.statusUpdatedAt))"
            sideLabel.textColor = .systemYellow
        } else {
            statusDot.layer?.backgroundColor = NSColor.systemGreen.cgColor
            sideLabel.stringValue = "working"
            sideLabel.textColor = .systemGreen
        }
    }
}
