import SwiftUI

struct RepositoryHomeView: View {
    @Environment(\.appLanguage) private var language
    @AppStorage("v4rtexx.selected_game") private var selectedGame = "com.dts.freefireth"

    let onOpenSettings: () -> Void
    let onOpenLogs: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 10/255, green: 14/255, blue: 23/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // V4RTEXX Header Banner
                        VStack(spacing: 12) {
                            AppLogo(size: 64)
                                .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.35), radius: 12, x: 0, y: 6)

                            Text("V4RTEXX MANAGER")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)

                            Text("Select Target Game Profile")
                                .font(.subheadline)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        }
                        .padding(.vertical, 8)

                        // GAME SELECTOR CARD
                        VStack(alignment: .leading, spacing: 14) {
                            Text("TARGET GAME PROFILE")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                            // Free Fire (com.dts.freefireth)
                            Button {
                                selectedGame = "com.dts.freefireth"
                            } label: {
                                HStack(spacing: 14) {
                                    Group {
                                        if let image = UIImage(named: "FreeFireLogo") ?? UIImage(contentsOfFile: "free fire.jpg") {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Image(systemName: "flame.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(selectedGame == "com.dts.freefireth" ? .black : Color(red: 56/255, green: 189/255, blue: 248/255))
                                        }
                                    }
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Free Fire")
                                            .font(.headline.weight(.bold))
                                            .foregroundStyle(.white)
                                        Text("com.dts.freefireth")
                                            .font(.caption.monospaced())
                                            .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                    }

                                    Spacer()

                                    if selectedGame == "com.dts.freefireth" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                    }
                                }
                                .padding(14)
                                .background(
                                    selectedGame == "com.dts.freefireth"
                                        ? Color(red: 30/255, green: 58/255, blue: 90/255)
                                        : Color(red: 15/255, green: 23/255, blue: 42/255)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            selectedGame == "com.dts.freefireth"
                                                ? Color(red: 56/255, green: 189/255, blue: 248/255)
                                                : Color.white.opacity(0.08),
                                            lineWidth: selectedGame == "com.dts.freefireth" ? 1.5 : 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)

                            // Free Fire MAX (com.dts.freefiremax)
                            Button {
                                selectedGame = "com.dts.freefiremax"
                            } label: {
                                HStack(spacing: 14) {
                                    Group {
                                        if let image = UIImage(named: "FreeFireMaxLogo") ?? UIImage(contentsOfFile: "free fire max.jpg") {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Image(systemName: "bolt.shield.fill")
                                                .font(.system(size: 22))
                                                .foregroundStyle(selectedGame == "com.dts.freefiremax" ? .black : Color(red: 56/255, green: 189/255, blue: 248/255))
                                        }
                                    }
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Free Fire MAX")
                                            .font(.headline.weight(.bold))
                                            .foregroundStyle(.white)
                                        Text("com.dts.freefiremax")
                                            .font(.caption.monospaced())
                                            .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                    }

                                    Spacer()

                                    if selectedGame == "com.dts.freefiremax" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                    }
                                }
                                .padding(14)
                                .background(
                                    selectedGame == "com.dts.freefiremax"
                                        ? Color(red: 30/255, green: 58/255, blue: 90/255)
                                        : Color(red: 15/255, green: 23/255, blue: 42/255)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            selectedGame == "com.dts.freefiremax"
                                                ? Color(red: 56/255, green: 189/255, blue: 248/255)
                                                : Color.white.opacity(0.08),
                                            lineWidth: selectedGame == "com.dts.freefiremax" ? 1.5 : 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(18)
                        .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                        // ACTIVE PROFILE STATUS
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ACTIVE PROFILE STATUS")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                            HStack {
                                Text("Selected Game")
                                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                Spacer()
                                Text(selectedGame == "com.dts.freefiremax" ? "Free Fire MAX" : "Free Fire")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                            }
                            .font(.subheadline)

                            Divider().background(Color.white.opacity(0.1))

                            HStack {
                                Text("License Gate")
                                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.shield.fill")
                                    Text("Activated")
                                }
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(Color.green)
                            }
                            .font(.subheadline)
                        }
                        .padding(18)
                        .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
