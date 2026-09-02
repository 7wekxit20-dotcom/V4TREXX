import SwiftUI
import UIKit

@main
struct ThreeOneOSFiveApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var patchDraftCoordinator = PatchDraftCoordinator()
    @StateObject private var fileOperationCoordinator = FileOperationCoordinator()
    @StateObject private var patchStore = PatchProjectStore()
    @StateObject private var repositoryStore = PackageRepositoryStore()
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue
    @AppStorage(KeySystem.storageKey) private var isKeyActivated = false
    @State private var showAttribution = false
    @State private var updateOffer: AppUpdateChecker.Offer?
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init() {
        AntiCrackService.enforceProtection()
        OnboardingStore.markCompleted()
        setupLogCapture()
        log("app: V4RTEXX MANAGER launching — iOS \(AppInfo.osVersion) (\(AppInfo.osBuild)) \(AppInfo.machineName)")
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    private func checkForUpdate() {
        Task {
            guard let offer = await AppUpdateChecker.check() else { return }
            await MainActor.run { updateOffer = offer }
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !isKeyActivated {
                    KeyActivationView {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isKeyActivated = true
                        }
                        appState.detectSupport()
                        checkForUpdate()
                    }
                    .transition(.opacity)
                    .zIndex(2)
                } else {
                    ContentView()
                        .environmentObject(appState)
                        .environmentObject(patchDraftCoordinator)
                        .environmentObject(fileOperationCoordinator)
                        .environmentObject(patchStore)
                        .environmentObject(repositoryStore)
                        .environment(\.appLanguage, language)
                        .environment(\.locale, language.locale)
                        .transition(.opacity)
                }
            }
            .alert(item: $updateOffer) { offer in
                Alert(
                    title: Text(language.text("update.title")),
                    message: Text(language.text("update.message", offer.version)),
                    primaryButton: .default(Text(language.text("update.agree"))) {
                        UIApplication.shared.open(offer.url)
                    },
                    secondaryButton: .cancel(Text(language.text("update.dismiss"))) {
                        AppUpdateChecker.dismiss(version: offer.version)
                    }
                )
            }
            .onAppear {
                if isKeyActivated {
                    KeySystem.reverifySavedLicense { valid in
                        if !valid {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isKeyActivated = false
                            }
                        }
                    }
                    appState.detectSupport()
                    checkForUpdate()
                }
            }
            .onChange(of: scenePhase) { phase in
                guard phase == .active, isKeyActivated else { return }
                KeySystem.reverifySavedLicense { valid in
                    if !valid {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isKeyActivated = false
                        }
                    }
                }
                appState.detectSupport()
            }
            .onOpenURL { url in
                patchDraftCoordinator.presentImport(url)
            }
        }
    }
}

class AppState: ObservableObject {
    @Published var exploitStatus: ExploitStatus = .notStarted
    @Published var unsupportedMessage: String?
    @Published var kernelExploitRunning = false

    private var autoRunAttempted = false

    var isSupported: Bool {
        let osTuple = AppInfo.versionTuple
        return ExploitSupportPolicy.isSupported(
            major: osTuple.major,
            minor: osTuple.minor,
            patch: osTuple.patch,
            build: AppInfo.osBuild
        )
    }

    var kernelExploitApplicable: Bool {
        KernelExploit.isApplicable(
            major: AppInfo.versionTuple.major,
            minor: AppInfo.versionTuple.minor,
            patch: AppInfo.versionTuple.patch,
            build: AppInfo.osBuild
        )
    }

    func detectSupport() {
        if !isSupported {
            unsupportedMessage = "Unsupported iOS Version"
        } else {
            unsupportedMessage = nil
        }
    }
}
