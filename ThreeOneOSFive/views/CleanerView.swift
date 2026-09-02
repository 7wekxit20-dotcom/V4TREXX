import SwiftUI

struct CleanerView: View {
    @Environment(\.appLanguage) private var language
    @AppStorage("v4rtexx.selected_game") private var selectedGame = "com.dts.freefireth"
    @State private var isScanning = false
    @State private var isCleaning = false
    @State private var freeFireCacheBytes: Int64 = 0
    @State private var freeFireMaxCacheBytes: Int64 = 0
    @State private var freeFirePath = ""
    @State private var freeFireMaxPath = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var hasScanned = false

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

                            Text("Scans and cleans Library/Caches & tmp for Free Fire containers.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        }
                        .padding(.vertical, 8)

                        // DETECTED CACHE CARD FOR FREE FIRE
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("REAL CONTAINER CACHE DETECTED")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                Spacer()
                                if isScanning {
                                    ProgressView()
                                        .tint(Color(red: 56/255, green: 189/255, blue: 248/255))
                                        .controlSize(.small)
                                } else {
                                    Button {
                                        scanRealContainerCaches()
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Rescan")
                                        }
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            // Free Fire Standard Row
                            HStack(spacing: 14) {
                                Group {
                                    if let image = UIImage(named: "FreeFireLogo") ?? UIImage(contentsOfFile: "free fire.jpg") {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image(systemName: "flame.fill")
                                            .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                    }
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

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
                                Group {
                                    if let image = UIImage(named: "FreeFireMaxLogo") ?? UIImage(contentsOfFile: "free fire max.jpg") {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image(systemName: "bolt.shield.fill")
                                            .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                    }
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

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
                                cleanRealCaches()
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
                            .disabled(isCleaning)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Clean")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !hasScanned {
                    hasScanned = true
                    scanRealContainerCaches()
                }
            }
            .alert("Free Fire Cache Cleaner", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func scanRealContainerCaches() {
        isScanning = true
        DispatchQueue.global(qos: .userInitiated).async {
            var ffBytes: Int64 = 0
            var ffMaxBytes: Int64 = 0

            if let pathFF = ContainerStore.resolveAppContainerPath(bundleID: "com.dts.freefireth") {
                let url = URL(fileURLWithPath: pathFF, isDirectory: true)
                if let usage = try? LimitedCleanerService.scan(containerURL: url, rootValidator: { _ in true }) {
                    ffBytes = usage.totalBytes
                }
            }

            if let pathMax = ContainerStore.resolveAppContainerPath(bundleID: "com.dts.freefiremax") {
                let url = URL(fileURLWithPath: pathMax, isDirectory: true)
                if let usage = try? LimitedCleanerService.scan(containerURL: url, rootValidator: { _ in true }) {
                    ffMaxBytes = usage.totalBytes
                }
            }

            DispatchQueue.main.async {
                self.freeFireCacheBytes = ffBytes
                self.freeFireMaxCacheBytes = ffMaxBytes
                self.isScanning = false
            }
        }
    }

    private func cleanRealCaches() {
        isCleaning = true
        let totalCleaned = freeFireCacheBytes + freeFireMaxCacheBytes
        DispatchQueue.global(qos: .userInitiated).async {
            if let pathFF = ContainerStore.resolveAppContainerPath(bundleID: "com.dts.freefireth") {
                let url = URL(fileURLWithPath: pathFF, isDirectory: true)
                _ = try? LimitedCleanerService.clean(containerURL: url, rootValidator: { _ in true })
            }
            if let pathMax = ContainerStore.resolveAppContainerPath(bundleID: "com.dts.freefiremax") {
                let url = URL(fileURLWithPath: pathMax, isDirectory: true)
                _ = try? LimitedCleanerService.clean(containerURL: url, rootValidator: { _ in true })
            }

            DispatchQueue.main.async {
                self.freeFireCacheBytes = 0
                self.freeFireMaxCacheBytes = 0
                self.isCleaning = false
                self.alertMessage = "Successfully cleared \(self.sizeText(totalCleaned)) of Free Fire cache data!"
                self.showAlert = true
            }
        }
    }

    private func sizeText(_ byteCount: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: byteCount, countStyle: .file)
    }
}
