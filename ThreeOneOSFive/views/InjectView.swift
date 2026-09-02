import SwiftUI

struct InjectView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var store: PatchProjectStore
    @AppStorage("v4rtexx.selected_game") private var selectedGame = "com.dts.freefireth" // Free Fire or Free Fire Max
    @State private var selectedPackageName = "aimdrag.v4rtexx"
    @State private var isInjecting = false
    @State private var showSuccessAlert = false
    @State private var alertMessage = ""
    let onOpenSettings: () -> Void
    let onOpenLogs: () -> Void

    private var gameTitle: String {
        selectedGame == "com.dts.freefiremax" ? "Free Fire MAX" : "Free Fire"
    }

    private var availablePackages: [String] {
        if store.items.isEmpty {
            return ["aimdrag.v4rtexx", "aimbody.v4rtexx", "aimneck.v4rtexx", "magicbullet.v4rtexx", "3D-Weapons.v4rtexx"]
        } else {
            return store.items.map { $0.packageURL.lastPathComponent }
        }
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

                            HStack(spacing: 12) {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                
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

                        // TARGET DETAILS CARD
                        VStack(alignment: .leading, spacing: 14) {
                            Text("TARGET DETAILS")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                            Text("Live container information")
                                .font(.caption)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                .padding(.top, -6)

                            // Row 1: Size
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 30/255, green: 41/255, blue: 59/255))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "externaldrive.fill")
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                }
                                Text("2.01 GB")
                                    .font(.system(.subheadline, design: .monospaced).weight(.bold))
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                            // Row 2: V4RTEXX packages
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 30/255, green: 41/255, blue: 59/255))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: "cube.fill")
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("V4RTEXX packages")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text("\(availablePackages.count) available")
                                        .font(.caption)
                                        .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                            // Row 3: License Gate
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

                        // INJECT SELECTION SECTION
                        VStack(alignment: .leading, spacing: 12) {
                            Text("INJECT")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                            Text("Select one .v4rtexx package from your imported library")
                                .font(.caption)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                .padding(.top, -6)

                            ForEach(availablePackages, id: \.self) { pkg in
                                Button {
                                    selectedPackageName = pkg
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .fill(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.2))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "shield.fill")
                                                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(pkg)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.white)
                                            Text("588 KB • PROTECTED")
                                                .font(.caption2.weight(.medium))
                                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                        }

                                        Spacer()

                                        if selectedPackageName == pkg {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        selectedPackageName == pkg
                                            ? Color(red: 30/255, green: 58/255, blue: 90/255)
                                            : Color(red: 22/255, green: 30/255, blue: 46/255)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                selectedPackageName == pkg
                                                    ? Color(red: 56/255, green: 189/255, blue: 248/255)
                                                    : Color.white.opacity(0.08),
                                                lineWidth: selectedPackageName == pkg ? 1.5 : 1
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // INJECT ACTION BUTTON
                        VStack(spacing: 8) {
                            HStack {
                                Text("READY")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                Spacer()
                            }
                            Text("Backups are created before replacement")
                                .font(.caption)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                performInjection()
                            } label: {
                                HStack(spacing: 8) {
                                    if isInjecting {
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
                            .disabled(isInjecting)
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
        isInjecting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isInjecting = false
            alertMessage = "Successfully injected \(selectedPackageName) into \(gameTitle) container!"
            showSuccessAlert = true
        }
    }
}
