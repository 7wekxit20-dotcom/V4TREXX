import Foundation
import UIKit

struct GitHubAuthAppConfig {
    static let rawKeysURL = "https://raw.githubusercontent.com/7wekxit20-dotcom/V4TREXX/main/keys.json"
    static let fallbackKeysURL = "https://raw.githubusercontent.com/7wekxit20-dotcom/V4TREXX/main/keys_db.json"
}

struct LicenseKeyRecord {
    let key: String
    let status: String
    let expiresAt: Date?
    let duration: String?
    let note: String?
}

struct KeySystem {
    static let storageKey = "v4rtexx.key_activated"
    static let savedKeyStorageKey = "v4rtexx.saved_key"
    static let deviceUUIDStorageKey = "v4rtexx.device_uuid"
    static let keyExpiresAtStorageKey = "v4rtexx.key_expires_at"

    static var isActivated: Bool {
        UserDefaults.standard.bool(forKey: storageKey)
    }

    static var savedKey: String? {
        UserDefaults.standard.string(forKey: savedKeyStorageKey)
    }

    static var deviceUUID: String {
        if let stored = UserDefaults.standard.string(forKey: deviceUUIDStorageKey), stored.count >= 20 {
            return stored
        }
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let cleanHWID = uuid.replacingOccurrences(of: "-", with: "").uppercased()
        let finalHWID = cleanHWID.count >= 20 ? cleanHWID : (cleanHWID + "V4RTEXX1234567890")
        UserDefaults.standard.set(finalHWID, forKey: deviceUUIDStorageKey)
        return finalHWID
    }

    static func verifyKey(key: String, completion: @escaping (Bool, String?) -> Void) {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmedKey.isEmpty else {
            completion(false, "INVALID KEY")
            return
        }

        // Add nocache timestamp query parameter to bypass CDN/caching
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let url = URL(string: "\(GitHubAuthAppConfig.rawKeysURL)?nocache=\(timestamp)") else {
            completion(false, "INVALID KEY")
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    // If offline or network error, allow existing active valid session
                    if isActivated, let saved = savedKey, saved.uppercased() == trimmedKey {
                        if let localExp = UserDefaults.standard.object(forKey: keyExpiresAtStorageKey) as? Date {
                            if Date() > localExp {
                                resetActivation()
                                completion(false, "KEY EXPIRED")
                                return
                            }
                        }
                        completion(true, nil)
                    } else {
                        completion(false, "NETWORK ERROR: \(error.localizedDescription)")
                    }
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    if isActivated, let saved = savedKey, saved.uppercased() == trimmedKey {
                        completion(true, nil)
                    } else {
                        completion(false, "INVALID KEY")
                    }
                }
                return
            }

            let records = parseLicenseKeys(from: data)
            DispatchQueue.main.async {
                guard let record = records[trimmedKey] else {
                    // Key not found in GitHub keys.json
                    resetActivation()
                    completion(false, "INVALID KEY")
                    return
                }

                // Check status
                if record.status.lowercased() != "active" {
                    resetActivation()
                    let msg = record.status.lowercased() == "expired" ? "KEY EXPIRED" : "KEY REVOKED"
                    completion(false, msg)
                    return
                }

                // Check expiration
                if let expiry = record.expiresAt {
                    if Date() > expiry {
                        resetActivation()
                        completion(false, "KEY EXPIRED")
                        return
                    }
                    UserDefaults.standard.set(expiry, forKey: keyExpiresAtStorageKey)
                } else {
                    UserDefaults.standard.removeObject(forKey: keyExpiresAtStorageKey)
                }

                // Key is valid! Save activation
                UserDefaults.standard.set(true, forKey: storageKey)
                UserDefaults.standard.set(trimmedKey, forKey: savedKeyStorageKey)
                completion(true, nil)
            }
        }
        task.resume()
    }

    /// Backward compatibility alias for views that previously called verifyKeyAuth
    static func verifyKeyAuth(key: String, completion: @escaping (Bool, String?) -> Void) {
        verifyKey(key: key, completion: completion)
    }

    static func reverifySavedLicense(completion: @escaping (Bool) -> Void) {
        guard isActivated, let saved = savedKey, !saved.isEmpty else {
            completion(false)
            return
        }
        verifyKey(key: saved) { success, _ in
            completion(success)
        }
    }

    static func resetActivation() {
        UserDefaults.standard.set(false, forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: savedKeyStorageKey)
        UserDefaults.standard.removeObject(forKey: keyExpiresAtStorageKey)
    }

    private static func parseLicenseKeys(from data: Data) -> [String: LicenseKeyRecord] {
        var cleanData = data
        if cleanData.count >= 3 && cleanData[0] == 0xEF && cleanData[1] == 0xBB && cleanData[2] == 0xBF {
            cleanData = cleanData.subdata(in: 3..<cleanData.count)
        }
        var result: [String: LicenseKeyRecord] = [:]

        // Helper for ISO8601 parsing
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let standardIso = ISO8601DateFormatter()

        let parseDate: (Any?) -> Date? = { val in
            if let str = val as? String {
                return isoFormatter.date(from: str) ?? standardIso.date(from: str)
            } else if let num = val as? Double {
                return Date(timeIntervalSince1970: num)
            }
            return nil
        }

        // Format 1: Dictionary (top-level or nested under "keys")
        if let jsonObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
            let dict = (jsonObject["keys"] as? [String: Any]) ?? jsonObject
            for (k, val) in dict {
                let upperKey = k.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                guard upperKey != "UPDATED_AT" && upperKey != "VERSION" else { continue }

                if let info = val as? [String: Any] {
                    let status = (info["status"] as? String)?.lowercased() ?? "active"
                    let duration = info["duration"] as? String
                    let expDate = parseDate(info["expires_at"])
                    let note = info["note"] as? String
                    result[upperKey] = LicenseKeyRecord(key: upperKey, status: status, expiresAt: expDate, duration: duration, note: note)
                } else if let str = val as? String {
                    result[upperKey] = LicenseKeyRecord(key: upperKey, status: str.lowercased(), expiresAt: nil, duration: "Lifetime", note: nil)
                }
            }
        }

        // Format 2: Array of objects or strings
        if result.isEmpty, let jsonArray = (try? JSONSerialization.jsonObject(with: data)) as? [Any] {
            for item in jsonArray {
                if let dict = item as? [String: Any], let key = dict["key"] as? String {
                    let upperKey = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                    let status = (dict["status"] as? String)?.lowercased() ?? "active"
                    let duration = dict["duration"] as? String
                    let expDate = parseDate(dict["expires_at"])
                    let note = dict["note"] as? String
                    result[upperKey] = LicenseKeyRecord(key: upperKey, status: status, expiresAt: expDate, duration: duration, note: note)
                } else if let keyStr = item as? String {
                    let upperKey = keyStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                    result[upperKey] = LicenseKeyRecord(key: upperKey, status: "active", expiresAt: nil, duration: "Lifetime", note: nil)
                }
            }
        }

        return result
    }
}
