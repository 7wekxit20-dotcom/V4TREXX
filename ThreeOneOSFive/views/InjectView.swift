import SwiftUI

struct InjectView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var store: PatchProjectStore
    @AppStorage("v4rtexx.selected_game") private var selectedGame = "com.dts.freefireth" // Free Fire or Free Fire Max
    @AppStorage("v4rtexx.selected_package") private var selectedPackagePath = ""
    @AppStorage("v4rtexx.is_injected") private var isInjected = false
    @State private var isProcessing = false
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
                Color(red: 10/255, green: 14/255, blue: 23/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // ACTIVE GAME PROFILE HEADER CARD
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ACTIVE GAME PROFILE")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                Spacer()
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
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
                                                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                        }
                                    } else {
                                        if let image = UIImage(named: "FreeFireLogo") ?? UIImage(contentsOfFile: "free fire.jpg") {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Image(systemName: "flame.fill")
                                                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
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
                                        .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // TARGET DETAILS CARD (Storage Removed per Request)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("TARGET DETAILS")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                            Text("Live container information")
                                .font(.caption)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                .padding(.top, -6)

                            // Row 1: V4RTEXX packages
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 30/255, green: 41/255, blue: 59/255))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "cube.fill")
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Selected Package")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(selectedPackageName)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                            // Row 2: License Gate
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 30/255, green: 41/255, blue: 59/255))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "key.fill")
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
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
                            .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(16)
                        .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // AUTO-DETECTED SELECTION DISPLAY
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AUTO-DETECTED PACKAGE")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "shield.fill")
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedPackageName)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text("Chosen from Library")
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                }

                                Spacer()

                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                            }
                            .padding(14)
                            .background(Color(red: 30/255, green: 58/255, blue: 90/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color(red: 56/255, green: 189/255, blue: 248/255), lineWidth: 1.5)
                            )
                        }

                        // INJECT / RESTORE ACTION BUTTONS
                        VStack(spacing: 12) {
                            HStack {
                                Text("ACTION")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                Spacer()
                            }
                            Text(isInjected ? "Container modified. You can restore original files anytime." : "Backups are automatically created before replacement")
                                .font(.caption)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
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
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 56/255, green: 189/255, blue: 248/255), Color(red: 14/255, green: 165/255, blue: 233/255)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.35), radius: 12, x: 0, y: 6)
                                }
                                .buttonStyle(.plain)
                                .disabled(isProcessing)
                            } else {
                                // NEW BUTTON APPEARS WHEN INJECTED: RESTORE ORIGINAL
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
                                                    .tint(.white)
                                            } else {
                                                Image(systemName: "arrow.triangle.2.circlepath")
                                                Text("Restore Original Files")
                                                    .fontWeight(.bold)
                                            }
                                        }
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity, minHeight: 52)
                                        .background(Color(red: 220/255, green: 38/255, blue: 38/255))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .shadow(color: Color.red.opacity(0.35), radius: 12, x: 0, y: 6)
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(isProcessing)
                                }
                            }
                        }
                        .padding(.top, 8)
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
                    let receipt = try DevicePatchService.apply(project: proj)
                    try DevicePatchService.restore(receipt: receipt, allowChangedTargets: true)
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
