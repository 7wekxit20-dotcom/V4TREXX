import Foundation
import UIKit

struct KeyAuthAppConfig {
    static let name = "V4RTEXX MANAGER"
    static let ownerid = "pg6gDhL4a6"
    static let secret = "1b6ae657e002b641129763f65920347345c9224bfdd1f514e7f8aa262886b03f"
    static let version = "1.0"
    static let apiUrl = "https://keyauth.win/api/1.2/"
}

struct KeyAuthResponse: Codable {
    let success: Bool?
    let message: String?
    let info: KeyAuthUserInfo?
}

struct KeyAuthUserInfo: Codable {
    let username: String?
    let subscription: String?
    let expiry: String?
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
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        // Format: 19 uppercase alphanumeric characters or KeyAuth format
        guard trimmed.count >= 10 else { return false }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        return trimmed.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    static func activate(with key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard validateKey(trimmed) else { return false }
        
        UserDefaults.standard.set(true, forKey: storageKey)
        UserDefaults.standard.set(trimmed, forKey: savedKeyStorageKey)
        let currentUUID = deviceUUID
        
        // Sync activation and device UUID back to KeyAuth / Telegram Bot server
        if let url = URL(string: "http://127.0.0.1:8080/activate") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: String] = [
                "key": trimmed,
                "device_uuid": currentUUID,
                "app_name": KeyAuthAppConfig.name,
                "owner_id": KeyAuthAppConfig.ownerid,
                "secret": KeyAuthAppConfig.secret,
                "version": KeyAuthAppConfig.version
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            URLSession.shared.dataTask(with: request).resume()
        }
        return true
    }

    static func resetActivation() {
        UserDefaults.standard.set(false, forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: savedKeyStorageKey)
    }
}
