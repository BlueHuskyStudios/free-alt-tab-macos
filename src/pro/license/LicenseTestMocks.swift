// Starting 2026-06-11, Ky forked the original repo to make this one.
// The details of changes to this file (and all other files in this repository), including when the changes were made, can be found in the Git metadata of this repository.
// If you receive a version of this repository that is lacking the Git metadata, you may contact Ky and they will provide that metadata to you free of charge: FreeAltTab@KyNorthstar.me

// Shared test doubles for the licensing layer. These were originally defined inside
// `LicenseManagerTests.swift`; they were extracted here so that the mocks remain available to the
// test target independently of any single test file's membership. (`LicenseManagerTests.swift`
// exercises the now-bypassed upstream trial logic and has been removed from the test target in
// this fork; pulling the mocks out keeps them usable by the toggle/bridge tests that remain.)
//
// They are faithful copies of the upstream definitions — `MockClock`, `MockKeychain`, and
// `MockLicenseAPI` conform to the same `Clock`, `Keychain`, and `LicenseAPI` protocols the real
// `LicenseManager` depends on, so tests can construct a manager with fully in-memory collaborators.

import Foundation

final class MockClock: Clock {
    var now: Date
    init(now: Date) { self.now = now }
    func advance(by interval: TimeInterval) { now = now.addingTimeInterval(interval) }
    func advance(days: Int) { now = now.addingTimeInterval(Double(days) * 86400) }
}

final class MockKeychain: Keychain {
    private var store: [String: String] = [:]
    var setValueStatus: (String) -> OSStatus = { _ in errSecSuccess }
    var removeStatus: (String) -> OSStatus = { _ in errSecSuccess }

    func value(account: String) -> String? { store[account] }

    @discardableResult
    func setValue(_ value: String, account: String) -> OSStatus {
        let status = setValueStatus(account)
        if status == errSecSuccess { store[account] = value }
        return status
    }

    @discardableResult
    func remove(account: String) -> OSStatus {
        let status = removeStatus(account)
        if status == errSecSuccess { store.removeValue(forKey: account) }
        return status
    }
}

final class MockLicenseAPI: LicenseAPI {
    var activateResult: Result<ActivateResult, Error> = .failure(LicenseAPIError.noData)
    var validateResult: Result<ValidateResult, Error> = .failure(LicenseAPIError.noData)
    var deactivateResult: Result<Void, Error> = .failure(LicenseAPIError.noData)

    var activateCalls: [String] = []
    var validateCalls: [(String, String)] = []
    var deactivateCalls: [(String, String)] = []

    func activate(_ licenseKey: String, completion: @escaping (Result<ActivateResult, Error>) -> Void) {
        activateCalls.append(licenseKey)
        let r = activateResult
        DispatchQueue.main.async { completion(r) }
    }

    func validate(_ licenseKey: String, instanceId: String, completion: @escaping (Result<ValidateResult, Error>) -> Void) {
        validateCalls.append((licenseKey, instanceId))
        let r = validateResult
        DispatchQueue.main.async { completion(r) }
    }

    func deactivate(_ licenseKey: String, instanceId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        deactivateCalls.append((licenseKey, instanceId))
        let r = deactivateResult
        DispatchQueue.main.async { completion(r) }
    }
}
