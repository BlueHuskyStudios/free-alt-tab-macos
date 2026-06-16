// Starting 2026-06-11, Ky forked the original repo to make this one.
// The details of changes to this file (and all other files in this repository), including when the changes were made, can be found in the Git metadata of this repository.
// If you receive a version of this repository that is lacking the Git metadata, you may contact Ky and they will provide that metadata to you free of charge: FreeAltTab@KyNorthstar.me

// This fork removes the trial/Pro purchase funnel entirely.
// On macOS ≥10.15, this is a SwiftUI view (in FreeAltTabTools) with a Pro-mode toggle.
// On macOS <10.15, this is a single static label stating that Pro mode is always on.

import Cocoa
import SwiftUI
import FreeAltTabTools

class UpgradeTab {

    static func initTab() -> NSView {
        if #available(macOS 10.15, *) {
            return ProUpgradeView.nsView(licenseState: Binding {
                LicenseManager.shared.userChosenLicenseState
            } set: {
                LicenseManager.shared.userChosenLicenseState = $0
            })
        }
        else {
            return makeView()
        }
    }

    static func cleanup() {
        // Nothing to tear down anymore now that the whole view is in FreeAltTabTools.
        // We keep the function header as a no-op for minimal footprint changes sicne other files reference this function.
        // That should make future repo-syncs easier
    }

    private static func makeView() -> NSView {
        // macOS ≤10.14 fallback: no interaction, just tell the user that Pro features are unconditionally
        let title = NSTextField(labelWithString: NSLocalizedString("FreeAltTab Pro", comment: ""))
        title.font = NSFont.systemFont(ofSize: 15, weight: .medium)
        title.textColor = .labelColor
        title.alignment = .center

        let subtitle = NSTextField(labelWithString: NSLocalizedString("Pro mode is always on.", comment: ""))
        subtitle.font = NSFont.systemFont(ofSize: 12)
        subtitle.textColor = .secondaryLabelColor
        subtitle.alignment = .center

        let bodyStack = NSStackView(views: [title, subtitle])
        bodyStack.orientation = .vertical
        bodyStack.alignment = .centerX
        bodyStack.spacing = 6
        bodyStack.edgeInsets = NSEdgeInsets(top: 24, left: TableGroupView.padding, bottom: 24, right: TableGroupView.padding)
        bodyStack.widthAnchor.constraint(equalToConstant: SettingsWindow.contentWidth).isActive = true
        return bodyStack
    }

    static func refreshStatus() {
        SettingsWindow.shared?.refreshUpgradeButton()
    }

    static func navigateToUpgradeTab() {
        App.showSettingsWindow()
        SettingsWindow.shared?.showUpgradeView()
    }

    static func openAccountPage() {
        guard let url = URL(string: Endpoints.accountUrl) else { return }
        NSWorkspace.shared.open(url)
    }

    static func showAutoActivating(_ licenseKey: String) {
        navigateToUpgradeTab()
    }

    static func showAutoActivationSuccess() {
        refreshStatus()
    }

    static func showAutoActivationFailed(_ licenseKey: String) {
        navigateToUpgradeTab()
    }
}
