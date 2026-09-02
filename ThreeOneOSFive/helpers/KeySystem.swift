import Foundation
import UIKit

struct KeyAuthAppConfig {
    static let name = "V4RTEXX MANAGER"
    static let ownerid = "pg6gDhL4a6"
    static let secret = "1b6ae657e002b641129763f65920347345c9224bfdd1f514e7f8aa262886b03f"
    static let version = "1.0"
    static let apiUrl = "https://keyauth.win/api/1.2/"
}

struct KeySystem {
    static let storageKey = "v4rtexx.key_activated"
    static let savedKeyStorageKey = "v4rtexx.saved_key"
    static let deviceUUIDStorageKey = "v4rtexx.device_uuid"

    static var isActivated: Bool {
        UserDefaults.standard.bool(forKey: storageKey)
    }

    static var savedKey: String? {
        UserDefaults.standard.string(forKey: savedKeyStorageKey)
    }

    static var deviceUUID: String {
        if let stored = UserDefaults.standard.string(forKey: deviceUUIDStorageKey) {
            return stored
        }
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        UserDefaults.standard.set(uuid, forKey: deviceUUIDStorageKey)
        return uuid
    }

    static func validateKey(_ key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty
    }

    static func activate(with key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validateKey(trimmed) else { return false }
        
        UserDefaults.standard.set(true, forKey: storageKey)
        UserDefaults.standard.set(trimmed, forKey: savedKeyStorageKey)
        _ = deviceUUID // Ensure device UUID is cached
        return true
    }

    static func resetActivation() {
        UserDefaults.standard.set(false, forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: savedKeyStorageKey)
    }
}
