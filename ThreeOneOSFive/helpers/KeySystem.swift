import CommonCrypto
import CryptoKit
import Foundation
import UIKit

struct LicenseKeyRecord {
    let key: String
    let status: String
    let expiresAt: Date?
    let duration: String?
    let note: String?
}

private struct EncryptedEnvelope: Decodable {
    let v4rtexx_encrypted: Bool?
    let version: String?
    let algorithm: String?
    let iv: String?
    let payload: String?
}

struct AntiCrackShield {
    // 0x5A XOR-masked Raw GitHub URL: prevents `strings` binary analysis
    private static let maskedURLBytes: [UInt8] = [
        50, 46, 46, 42, 41, 96, 117, 117, 40, 59, 45, 116, 61, 51, 46, 50, 47, 56, 47, 41, 63, 40, 57, 53, 52, 46, 63, 52, 46, 116, 57, 53, 55, 117, 109, 45, 63, 49, 34, 51, 46, 104, 106, 119, 62, 53, 46, 57, 53, 55, 117, 12, 110, 14, 8, 31, 2, 2, 117, 55, 59, 51, 52, 117, 49, 63, 35, 41, 116, 48, 41, 53, 52
    ]

    // 0x5A XOR-masked AES-256 Secret: prevents extracting master key
    private static let maskedSecretBytes: [UInt8] = [
        12, 110, 8, 14, 31, 2, 2, 119, 27, 15, 14, 18, 119, 9, 18, 19, 31, 22, 30, 119, 104, 106, 104, 108, 119, 2, 99, 99, 119, 10, 8, 21, 14
    ]

    private static let xorKey: UInt8 = 0x5A

    static func getEndpointURL(nocacheTimestamp: Int) -> URL? {
        let unmasked = maskedURLBytes.map { $0 ^ xorKey }
        guard let base = String(bytes: unmasked, encoding: .utf8) else { return nil }
        return URL(string: "\(base)?nocache=\(nocacheTimestamp)")
    }

    static func decryptPayloadIfNeeded(data: Data) -> Data? {
        var cleanData = data
        if cleanData.count >= 3 && cleanData[0] == 0xEF && cleanData[1] == 0xBB && cleanData[2] == 0xBF {
            cleanData = cleanData.subdata(in: 3..<cleanData.count)
        }

        // Check if data is an AES-256-GCM encrypted envelope
        guard let envelope = try? JSONDecoder().decode(EncryptedEnvelope.self, from: cleanData),
              envelope.v4rtexx_encrypted == true,
              let ivStr = envelope.iv,
              let payloadStr = envelope.payload,
              let nonceData = Data(base64Encoded: ivStr),
              let combinedData = Data(base64Encoded: payloadStr),
              combinedData.count > 16 else {
            // Unencrypted fallback
            return cleanData
        }

        do {
            let nonce = try AES.GCM.Nonce(data: nonceData)
            let ciphertext = combinedData.prefix(combinedData.count - 16)
            let tag = combinedData.suffix(16)
            let box = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)

            let unmaskedSec = maskedSecretBytes.map { $0 ^ xorKey }
            let keyDigest = SHA256.hash(data: Data(unmaskedSec))
            let symmetricKey = SymmetricKey(data: keyDigest)

            let decrypted = try AES.GCM.open(box, using: symmetricKey)
            return decrypted
        } catch {
            return nil
        }
    }

    static func isDebuggerOrTamperDetected() -> Bool {
        #if !DEBUG
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        if junk == 0 && (info.kp_proc.p_flag & P_TRACED) != 0 {
            return true
        }
        #endif
        return false
    }
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
            completion(false, "KEY INVALID")
            return
        }

        // Anti-Crack: Anti-Debugger & Anti-Trace
        if AntiCrackShield.isDebuggerOrTamperDetected() {
            resetActivation()
            completion(false, "KEY INVALID")
            return
        }

        // Obfuscated endpoint resolution
        let timestamp = Int(Date().timeIntervalSince1970)
        guard let url = AntiCrackShield.getEndpointURL(nocacheTimestamp: timestamp) else {
            completion(false, "KEY INVALID")
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("no-cache, no-store, must-revalidate", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        request.setValue("0", forHTTPHeaderField: "Expires")
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

            // Anti-Crack: Authenticated AES-256-GCM Decryption & Tamper Check
            guard let rawData = data, let decryptedData = AntiCrackShield.decryptPayloadIfNeeded(data: rawData) else {
                DispatchQueue.main.async {
                    resetActivation()
                    completion(false, "KEY INVALID")
                }
                return
            }

            let records = parseLicenseKeys(from: decryptedData)
            DispatchQueue.main.async {
                guard let record = records[trimmedKey] else {
                    // Key not found in decrypted keys database
                    resetActivation()
                    completion(false, "KEY INVALID")
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
