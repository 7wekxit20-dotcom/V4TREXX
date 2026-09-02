import Foundation

struct KeySystem {
    static let storageKey = "v4rtexx.key_activated"
    static let savedKeyStorageKey = "v4rtexx.saved_key"

    static var isActivated: Bool {
        UserDefaults.standard.bool(forKey: storageKey)
    }

    static var savedKey: String? {
        UserDefaults.standard.string(forKey: savedKeyStorageKey)
    }

    static func validateKey(_ key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        // Format: 19 uppercase alphanumeric characters (e.g. O13XN1OBC78AGYQ8B1K)
        guard trimmed.count == 19 else { return false }
        let allowed = CharacterSet.alphanumerics
        return trimmed.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    static func activate(with key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard validateKey(trimmed) else { return false }
        UserDefaults.standard.set(true, forKey: storageKey)
        UserDefaults.standard.set(trimmed, forKey: savedKeyStorageKey)
        return true
    }

    static func resetActivation() {
        UserDefaults.standard.set(false, forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: savedKeyStorageKey)
    }
}
