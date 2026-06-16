// Starting 2026-06-11, Ky forked the original repo to make this one.
// The details of changes to this file (and all other files in this repository), including when the changes were made, can be found in the Git metadata of this repository.
// If you receive a version of this repository that is lacking the Git metadata, you may contact Ky and they will provide that metadata to you free of charge: FreeAltTab@KyNorthstar.me

import FreeAltTabTools

enum LicenseState: Equatable {
    case trial(daysRemaining: Int)
    case pro
    case proExpired
    case trialExpired

    var isProAvailable: Bool {
        switch self {
        case .trial, .pro: return true
        case .proExpired, .trialExpired: return false
        }
    }

    var debugProfileLabel: String {
        switch self {
        case .trial: return "Trial"
        case .pro: return "Pro"
        case .proExpired, .trialExpired: return "Free"
        }
    }
}



extension LicenseState {
    
    /// Converts the given user-chosen license state into the closest analogous license state
    ///
    /// - Parameter userChosenLicenseState: The license state that the user chose
    init(_ userChosenLicenseState: UserChosenLicenseState) {
        switch userChosenLicenseState {
        case .pro:
            self = .pro
        case .free:
            self = .trialExpired
        }
    }
}



extension UserChosenLicenseState {
    
    /// Converts the given license state into the closest analogous user-chosen license state
    ///
    /// - Parameter licenseState: The license state that the user probably didn't choose
    init(_ licenseState: LicenseState) {
        switch licenseState {
        case .pro,
                .proExpired:
            self = .pro
            
        case .trial(daysRemaining: _),
                .trialExpired:
            self = .free
        }
    }
}
