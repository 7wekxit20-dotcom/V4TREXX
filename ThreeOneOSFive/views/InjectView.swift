import SwiftUI
import UIKit

struct InjectView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var store: PatchProjectStore
    @AppStorage("v4rtexx.selected_game") private var selectedGame = "com.dts.freefireth"
    @AppStorage("v4rtexx.selected_package") private var selectedPackagePath = ""
    @State private var isProcessing = false
    @State private var isInjected = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    let onOpenSettings: () -> Void
    let onOpenLogs: () -> Void

    private var gameTitle: String {
        selectedGame == "com.dts.freefiremax" ? "Free Fire MAX" : "Free Fire"
    }

    private var selectedPackageName: String {
        if !selectedPackagePath.isEmpty {
            return URL(fileURLWithPath: selectedPackagePath).lastPathComponent
        }
        if let firstItem = store.items.first {
            return firstItem.packageURL.lastPathComponent
        }
        return "No Package Selected in Library"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // ACTIVE GAME PROFILE HEADER CARD
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ACTIVE GAME PROFILE")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color(white: 0.6))
                                Spacer()
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(white: 0.6))
                            }

                            HStack(spacing: 14) {
                                Group {
                                    if selectedGame == "com.dts.freefiremax" {
                                        if let image = UIImage(named: "FreeFireMaxLogo") ?? UIImage(contentsOfFile: "free fire max.jpg") {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Image(systemName: "bolt.shield.fill")
                                                .foregroundStyle(.white)
                                        }
                                    } else {
                                        if let image = UIImage(named: "FreeFireLogo") ?? UIImage(contentsOfFile: "free fire.jpg") {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Image(systemName: "flame.fill")
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(gameTitle)
                                        .font(.headline.weight(.bold))
                                        .foregroundStyle(.white)
                                    Text(selectedGame)
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(Color(white: 0.6))
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                        // TARGET DETAILS CARD
                        VStack(alignment: .leading, spacing: 14) {
                            Text("TARGET DETAILS")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(white: 0.6))

                            Text("Live container information")
                                .font(.caption)
                                .foregroundStyle(Color(white: 0.6))
                                .padding(.top, -6)

                            // Row 1: Selected Package
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(white: 0.18))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "cube.fill")
                                        .foregroundStyle(.white)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Selected Package")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(selectedPackageName)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(Color(white: 0.7))
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(white: 0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                            // Row 2: License Gate
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(white: 0.18))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "key.fill")
                                        .foregroundStyle(.white)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("License gate")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text("Activated")
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(Color.green)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(white: 0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(16)
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )

                        // AUTO-DETECTED SELECTION DISPLAY
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AUTO-DETECTED PACKAGE")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(white: 0.6))

                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(white: 0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "shield.fill")
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedPackageName)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text("Chosen from Library")
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(Color(white: 0.6))
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .padding(14)
                            .background(Color(white: 0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white, lineWidth: 1.5)
                            )
                        }

                        // INJECT / RESTORE ACTION BUTTONS
                        VStack(spacing: 12) {
                            HStack {
                                Text("ACTION")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color(white: 0.6))
                                Spacer()
                            }
                            Text(isInjected ? "Container modified. You can restore original files anytime." : "Backups are automatically created before replacement")
                                .font(.caption)
                                .foregroundStyle(Color(white: 0.6))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if !isInjected {
                                Button {
                                    performInjection()
                                } label: {
                                    HStack(spacing: 8) {
                                        if isProcessing {
                                            ProgressView()
                                                .tint(.black)
                                        } else {
                                            Image(systemName: "syringe.fill")
                                            Text("Inject \(selectedPackageName)")
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity, minHeight: 52)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: Color.white.opacity(0.25), radius: 10, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                                .disabled(isProcessing)
                            } else {
                                VStack(spacing: 10) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.seal.fill")
                                        Text("Package Injected & Active")
                                    }
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Color.green)

                                    Button {
                                        performRestore()
                                    } label: {
                                        HStack(spacing: 8) {
                                            if isProcessing {
                                                ProgressView()
                                                    .tint(.black)
                                            } else {
                                                Image(systemName: "arrow.triangle.2.circlepath")
                                                Text("Restore Original Files")
                                                    .fontWeight(.bold)
                                            }
                                        }
                                        .font(.headline)
                                        .foregroundStyle(.black)
                                        .frame(maxWidth: .infinity, minHeight: 52)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .shadow(color: Color.white.opacity(0.25), radius: 10, x: 0, y: 4)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isProcessing)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Inject")
            .navigationBarTitleDisplayMode(.inline)
            .alert("V4RTEXX Injector", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func performInjection() {
        guard !selectedPackagePath.isEmpty,
              let targetItem = store.items.first(where: { $0.packageURL.path == selectedPackagePath }) else {
            alertMessage = "No package selected! Please select a .v4rtexx package in the Library tab first."
            showSuccessAlert = true
            return
        }

        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let message = "Successfully injected \(selectedPackageName) into \(gameTitle) container!"
            if let proj = targetItem.project {
                do {
                    _ = try DevicePatchService.apply(project: proj)
                } catch {
                    log("inject error: \(error)")
                }
            }
            DispatchQueue.main.async {
                isProcessing = false
                isInjected = true
                alertMessage = message
                showSuccessAlert = true
            }
        }
    }

    private func performRestore() {
        isProcessing = true
        DispatchQueue.global(qos: .userInitiated).async {
            let message = "Successfully restored original files for \(gameTitle)!"
            if let targetItem = store.items.first(where: { $0.packageURL.path == selectedPackagePath }),
               let proj = targetItem.project {
                do {
                    if let receipt = DevicePatchService.latestReceipt(projectID: proj.id) {
                        try DevicePatchService.restore(receipt: receipt, allowChangedTargets: true)
                    } else {
                        let receipt = try DevicePatchService.apply(project: proj)
                        try DevicePatchService.restore(receipt: receipt, allowChangedTargets: true)
                    }
                } catch {
                    log("restore error: \(error)")
                }
            }
            DispatchQueue.main.async {
                isProcessing = false
                isInjected = false
                alertMessage = message
                showSuccessAlert = true
            }
        }
    }
}
