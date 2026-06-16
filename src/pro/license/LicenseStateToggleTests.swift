// Starting 2026-06-11, Ky forked the original repo to make this one.
// The details of changes to this file (and all other files in this repository), including when the changes were made, can be found in the Git metadata of this repository.
// If you receive a version of this repository that is lacking the Git metadata, you may contact Ky and they will provide that metadata to you free of charge: FreeAltTab@KyNorthstar.me

// These tests cover the behaviour this fork added: the user-facing Pro-mode toggle
// (`LicenseManager.licenseState`) and the bridge that maps the user's choice onto the app's
// internal `LicenseState`. They exercise only the public API — no `@testable import` — so they
// pin the contract callers actually depend on (the menubar, the gating checks, the sidebar
// label) rather than internal mechanics.
//
// The single most important thing under test is the meaning of "Free": in this fork, Free is
// "revert to the pre-Pro feature set", which is expressed by mapping `.free` to a state whose
// `isProAvailable` is false. If a future change to the mapping broke that, the gates would
// silently stop re-engaging in Free mode; `testFreeMakesProUnavailable` is the guard against it.

import XCTest

final class LicenseStateToggleTests: XCTestCase {
    var clock: MockClock!
    var keychain: MockKeychain!
    var api: MockLicenseAPI!
    var defaults: UserDefaults!
    var suiteName: String!
    var manager: LicenseManager!

    override func setUp() {
        super.setUp()
        suiteName = "test-license-toggle-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        clock = MockClock(now: Date(timeIntervalSince1970: 1_700_000_000))
        keychain = MockKeychain()
        api = MockLicenseAPI()
        manager = LicenseManager(clock: clock, keychain: keychain, api: api, defaults: defaults)
    }

    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    // MARK: - Default

    /// A fresh install should default to the most-capable state, so the app is fully usable out
    /// of the box without the user having to discover the toggle.
    func testDefaultsToProOnFreshInstall() {
        manager.initialize()
        XCTAssertEqual(manager.state, .pro)
        XCTAssertEqual(manager.licenseState, .pro)
        XCTAssertTrue(manager.isProAvailable)
    }

    // MARK: - Toggle setter drives `state`

    /// Setting the toggle to `.pro` must leave the app in the `.pro` state. This is the "on" half
    /// of the toggle contract.
    func testSettingProYieldsProState() {
        manager.licenseState = .free   // move away from the default first…
        manager.licenseState = .pro    // …so this assertion proves the *transition*, not the default
        XCTAssertEqual(manager.state, .pro)
        XCTAssertEqual(manager.licenseState, .pro)
    }

    /// Setting the toggle to `.free` must leave the app in `.trialExpired` — the chosen
    /// representation of "pre-Pro feature set". This is the "off" half of the toggle contract.
    func testSettingFreeYieldsTrialExpiredState() {
        manager.licenseState = .free
        XCTAssertEqual(manager.state, .trialExpired)
        XCTAssertEqual(manager.licenseState, .free)
    }

    /// The mechanism behind "Free re-engages the gates": in Free mode, Pro features must report as
    /// unavailable. If this flips, every gated feature would silently stay unlocked in Free mode.
    func testFreeMakesProUnavailable() {
        manager.licenseState = .pro
        XCTAssertTrue(manager.isProAvailable, "Pro mode should make Pro features available")

        manager.licenseState = .free
        XCTAssertFalse(manager.isProAvailable, "Free mode should make Pro features unavailable")
    }

    // MARK: - Round-trip / idempotency

    /// Toggling back and forth should always land on the state matching the *current* choice, with
    /// no hysteresis or accumulated drift from repeated transitions.
    func testToggleRoundTripIsStable() {
        for _ in 0..<3 {
            manager.licenseState = .pro
            XCTAssertEqual(manager.state, .pro)
            XCTAssertTrue(manager.isProAvailable)

            manager.licenseState = .free
            XCTAssertEqual(manager.state, .trialExpired)
            XCTAssertFalse(manager.isProAvailable)
        }
    }

    /// Setting the same value twice should be a no-op as far as the resulting state is concerned —
    /// the getter must agree with what was last set regardless of repetition.
    func testSettingSameValueTwiceIsStable() {
        manager.licenseState = .free
        manager.licenseState = .free
        XCTAssertEqual(manager.state, .trialExpired)
        XCTAssertEqual(manager.licenseState, .free)

        manager.licenseState = .pro
        manager.licenseState = .pro
        XCTAssertEqual(manager.state, .pro)
        XCTAssertEqual(manager.licenseState, .pro)
    }

    // MARK: - Persistence of the choice across a relaunch

    /// The user's toggle choice is the source of truth and must survive a relaunch. Rebuilding the
    /// manager against the same backing store should recover the last-set mode rather than
    /// snapping back to the default.
    ///
    /// NOTE: this test encodes an expectation that the chosen mode is *persisted*. If the shim does
    /// not yet persist `userChosenLicenseState`, this is the test that will flag it — see the review
    /// note about durability. If persistence is intentionally out of scope for now, mark this
    /// `XCTSkip` with that reason rather than deleting it, so the gap stays visible.
    func testChoiceSurvivesRelaunch() throws {
        manager.licenseState = .free

        let relaunched = LicenseManager(clock: clock, keychain: keychain, api: api, defaults: defaults)
        relaunched.initialize()

        XCTAssertEqual(relaunched.licenseState, .free, "toggle choice should persist across relaunch")
        XCTAssertEqual(relaunched.state, .trialExpired)
    }
}
