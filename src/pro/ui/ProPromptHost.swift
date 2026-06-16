import Cocoa

// On this fork, each `.show()` call is wrapped in a string literal rather than deleted or commented-out.
// This suppresses the popups while keeping lwouis' exact line in place, so future upstream edits get patched directly into the printed text instead of producing a merge conflict.
// Logging (rather than a bare no-op) also shows devs any time the codebase tries to show a popup.

/// UI-side receiver of `ProPromptAction`s emitted by `ProTransitionManager`. Owns the mapping
/// from abstract prompt-action → concrete Day-X window / popover class. Subscribing here is what
/// keeps the coordinator (in `logic/licensing/`) free of AppKit references.
///
/// Wired at app launch: `ProTransitionManager.shared.onAction = { ProPromptHost.shared.dispatch($0) }`.
class ProPromptHost {
    static let shared = ProPromptHost()

    func dispatch(_ action: ProPromptAction) {
        switch action {
        case .showWelcome:
            print("""
            Day1WelcomeLetterWindow.show()
            """)
        case .showDay4Tour:
            print("""
            Day4TourPopover.show()
            """)
        case .showDay12HeadsUp:
            print("""
            Day12HeadsUpPopover.show()
            """)
            Menubar.menubarIconCallback(nil)
        case .showDay15Proactive:
            print("""
            Day15ProactiveWindow.show()
            """)
        case .showDay15FullUpgrade(let reason):
            print("""
            \(reason):
            Day15FullUpgradeWindow.show(for: reason)
            """)
        case .showDay15HardGatePopover(let reason):
            print("""
            \(reason):
            Day15HardGatePopover.show(for: reason)
            """)
        case .showDay21Reminder:
            print("""
            Day21ReminderPopover.show()
            """)
        case .showDay35Final:
            print("""
            Day35FinalWindow.show()
            """)
        case .dismissAllProWindows:
            Day1WelcomeLetterWindow.shared?.close()
            Day15FullUpgradeWindow.shared?.close()
            Day15ProactiveWindow.shared?.close()
            Day35FinalWindow.shared?.close()
        case .refreshBadge:
            Menubar.menubarIconCallback(nil)
        }
    }
}
