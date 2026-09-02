import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        AppLogo()

                        VStack(alignment: .leading, spacing: 3) {
                            Text("V4RTEXX MANAGER")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                            Text(language.text("common.version", appVersion))
                                .font(.subheadline)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(red: 18/255, green: 25/255, blue: 38/255))

                // TELEGRAM CHANNEL BUTTON
                Section {
                    Link(destination: URL(string: "https://t.me/v4rtexxofficial")!) {
                        HStack(spacing: 10) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.white)
                            Text("Join My Telegram Channel")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        }
                    }
                }
                .listRowBackground(Color(red: 25/255, green: 45/255, blue: 70/255))

                // DEVICE INFO
                Section("DEVICE INFORMATION") {
                    LabeledContent(language.text("dashboard.hardware_model"), value: AppInfo.displayMachineName)
                    LabeledContent(language.text("settings.ios_version"), value: "\(AppInfo.osVersion) (\(AppInfo.osBuild))")
                }
                .listRowBackground(Color(red: 18/255, green: 25/255, blue: 38/255))

                // SUPPORTED VERIFIED VERSIONS
                Section("VERIFIED COMPATIBILITY") {
                    HStack {
                        Text(language.text("settings.current_version"))
                        Spacer()
                        Text(language.text(appState.isSupported ? "settings.supported" : "settings.unsupported"))
                            .foregroundStyle(appState.isSupported ? Color.green : Color.red)
                    }
                    LabeledContent("iOS 17", value: ExploitSupportPolicy.verifiedIOS17Range)
                    LabeledContent("iOS 18", value: ExploitSupportPolicy.verifiedIOS18Range)
                    LabeledContent("iOS 26", value: ExploitSupportPolicy.verifiedIOS26Range)
                }
                .listRowBackground(Color(red: 18/255, green: 25/255, blue: 38/255))
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 10/255, green: 14/255, blue: 23/255).ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(language.text("common.done")) {
                        dismiss()
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                }
            }
        }
    }

    private var appVersion: String {
        let releaseVersion = Bundle.main.object(forInfoDictionaryKey: "AppReleaseDisplayVersion") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0.0"
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(releaseVersion) (\(buildNumber))"
    }
}
