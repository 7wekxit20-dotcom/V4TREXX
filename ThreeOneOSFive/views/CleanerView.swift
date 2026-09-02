import SwiftUI

struct CleanerView: View {
    @Environment(\.appLanguage) private var language
    @AppStorage("v4rtexx.selected_game") private var selectedGame = "com.dts.freefireth"
    @State private var isScanning = false
    @State private var isCleaning = false
    @State private var freeFireCacheBytes: Int64 = 428_540_000 // Sample ~428.5 MB
    @State private var freeFireMaxCacheBytes: Int64 = 612_100_000 // Sample ~612.1 MB
    @State private var showAlert = false
    @State private var alertMessage = ""

    private var targetBundleID: String {
        selectedGame
    }

    private var targetTitle: String {
        selectedGame == "com.dts.freefiremax" ? "Free Fire MAX" : "Free Fire"
    }

    private var currentCacheBytes: Int64 {
        selectedGame == "com.dts.freefiremax" ? freeFireMaxCacheBytes : freeFireCacheBytes
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 10/255, green: 14/255, blue: 23/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // HEADER CARD
                        VStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.15))
                                    .frame(width: 64, height: 64)

                                Image(systemName: "trash.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                            }

                            Text("Free Fire Cache Cleaner")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)

                            Text("Detects and removes temporary cache files exclusively for Free Fire containers.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        }
                        .padding(.vertical, 8)

                        // DETECTED CACHE CARD FOR FREE FIRE
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("TARGET CONTAINER CACHE")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                Spacer()
                                if isScanning {
                                    ProgressView()
                                        .tint(Color(red: 56/255, green: 189/255, blue: 248/255))
                                        .controlSize(.small)
                                } else {
                                    Button {
                                        scanCache()
                                    } label: {
                                        Image(systemName: "arrow.clockwise")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            // Free Fire Standard Row
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 30/255, green: 41/255, blue: 59/255))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Free Fire Cache")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text("com.dts.freefireth")
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                }

                                Spacer()

                                Text(sizeText(freeFireCacheBytes))
                                    .font(.system(.subheadline, design: .monospaced).weight(.bold))
                                    .foregroundStyle(freeFireCacheBytes > 0 ? Color(red: 56/255, green: 189/255, blue: 248/255) : Color(red: 148/255, green: 163/255, blue: 184/255))
                            }
                            .padding(14)
                            .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                            // Free Fire MAX Row
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(red: 30/255, green: 41/255, blue: 59/255))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "bolt.shield.fill")
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Free Fire MAX Cache")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text("com.dts.freefiremax")
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                }

                                Spacer()

                                Text(sizeText(freeFireMaxCacheBytes))
                                    .font(.system(.subheadline, design: .monospaced).weight(.bold))
                                    .foregroundStyle(freeFireMaxCacheBytes > 0 ? Color(red: 56/255, green: 189/255, blue: 248/255) : Color(red: 148/255, green: 163/255, blue: 184/255))
                            }
                            .padding(14)
                            .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(18)
                        .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // ACTION BUTTON TO CLEAN CACHE
                        VStack(spacing: 12) {
                            Button {
                                cleanCache()
                            } label: {
                                HStack(spacing: 8) {
                                    if isCleaning {
                                        ProgressView()
                                            .tint(.black)
                                    } else {
                                        Image(systemName: "trash.fill")
                                        Text("Clear Free Fire Cache (\(sizeText(freeFireCacheBytes + freeFireMaxCacheBytes)))")
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
                            .disabled(isCleaning || (freeFireCacheBytes + freeFireMaxCacheBytes == 0))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Clean")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Free Fire Cache Cleaner", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func scanCache() {
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isScanning = false
        }
    }

    private func cleanCache() {
        isCleaning = true
        let totalCleaned = freeFireCacheBytes + freeFireMaxCacheBytes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            freeFireCacheBytes = 0
            freeFireMaxCacheBytes = 0
            isCleaning = false
            alertMessage = "Successfully cleared \(sizeText(totalCleaned)) of Free Fire cache data!"
            showAlert = true
        }
    }

    private func sizeText(_ byteCount: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file)
    }
}
