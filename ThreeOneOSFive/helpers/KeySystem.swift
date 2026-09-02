import Foundation
import UIKit

struct KeyAuthAppConfig {
    static let name = "V4RTEXX MANAGER"
    static let ownerid = "pg6gDhL4a6"
    static let secret = "1b6ae657e002b641129763f65920347345c9224bfdd1f514e7f8aa262886b03f"
    static let version = "1.0"
    static let apiUrl = "https://keyauth.win/api/1.2/"
}

private struct KeyAuthInitResponse: Decodable {
    let success: Bool
    let message: String?
    let sessionid: String?
}

private struct KeyAuthLicenseResponse: Decodable {
    let success: Bool
    let message: String?
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
        if let stored = UserDefaults.standard.string(forKey: deviceUUIDStorageKey), stored.count >= 20 {
            return stored
        }
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let cleanHWID = uuid.replacingOccurrences(of: "-", with: "").uppercased()
        let finalHWID = cleanHWID.count >= 20 ? cleanHWID : (cleanHWID + "V4RTEXX1234567890")
        UserDefaults.standard.set(finalHWID, forKey: deviceUUIDStorageKey)
        return finalHWID
    }

    static func verifyKeyAuth(key: String, completion: @escaping (Bool, String?) -> Void) {
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            completion(false, "INVALID KEY")
            return
        }

        // 1. Initialize KeyAuth session
        var initComponents = URLComponents(string: KeyAuthAppConfig.apiUrl)!
        initComponents.queryItems = [
            URLQueryItem(name: "type", value: "init"),
            URLQueryItem(name: "name", value: KeyAuthAppConfig.name),
            URLQueryItem(name: "ownerid", value: KeyAuthAppConfig.ownerid),
            URLQueryItem(name: "secret", value: KeyAuthAppConfig.secret),
            URLQueryItem(name: "version", value: KeyAuthAppConfig.version)
        ]

        guard let initURL = initComponents.url else {
            completion(false, "INVALID KEY")
            return
        }

        let initTask = URLSession.shared.dataTask(with: initURL) { initData, _, _ in
            guard let initData = initData,
                  let initResponse = try? JSONDecoder().decode(KeyAuthInitResponse.self, from: initData),
                  initResponse.success,
                  let sessionID = initResponse.sessionid else {
                DispatchQueue.main.async {
                    // If network fails offline, allow existing saved key session
                    if isActivated && savedKey == trimmedKey {
                        completion(true, nil)
                    } else {
                        completion(false, "INVALID KEY")
                    }
                }
                return
            }

            // 2. Validate License Key with KeyAuth session
            var licenseComponents = URLComponents(string: KeyAuthAppConfig.apiUrl)!
            licenseComponents.queryItems = [
                URLQueryItem(name: "type", value: "license"),
                URLQueryItem(name: "key", value: trimmedKey),
                URLQueryItem(name: "hwid", value: deviceUUID),
                URLQueryItem(name: "sessionid", value: sessionID),
                URLQueryItem(name: "name", value: KeyAuthAppConfig.name),
                URLQueryItem(name: "ownerid", value: KeyAuthAppConfig.ownerid)
            ]

            guard let licenseURL = licenseComponents.url else {
                DispatchQueue.main.async {
                    if isActivated && savedKey == trimmedKey {
                        completion(true, nil)
                    } else {
                        completion(false, "INVALID KEY")
                    }
                }
                return
            }

            let licenseTask = URLSession.shared.dataTask(with: licenseURL) { licData, _, _ in
                DispatchQueue.main.async {
                    guard let licData = licData,
                          let licResponse = try? JSONDecoder().decode(KeyAuthLicenseResponse.self, from: licData) else {
                        if isActivated && savedKey == trimmedKey {
                            completion(true, nil)
                        } else {
                            completion(false, "INVALID KEY")
                        }
                        return
                    }

                    if licResponse.success {
                        // Key is valid on KeyAuth server! Save state.
                        UserDefaults.standard.set(true, forKey: storageKey)
                        UserDefaults.standard.set(trimmedKey, forKey: savedKeyStorageKey)
                        completion(true, nil)
                    } else {
                        // Key explicitly expired or invalid on KeyAuth server! Auto Log Out.
                        resetActivation()
                        let errMsg = licResponse.message?.uppercased() ?? "INVALID KEY"
                        completion(false, errMsg.contains("KEY") ? errMsg : "INVALID KEY")
                    }
                }
            }
            licenseTask.resume()
        }
        initTask.resume()
    }

    static func reverifySavedLicense(completion: @escaping (Bool) -> Void) {
        guard isActivated, let saved = savedKey, !saved.isEmpty else {
            completion(false)
            return
        }
        verifyKeyAuth(key: saved) { success, _ in
            completion(success)
        }
    }

    static func resetActivation() {
        UserDefaults.standard.set(false, forKey: storageKey)
        UserDefaults.standard.removeObject(forKey: savedKeyStorageKey)
    }
}
