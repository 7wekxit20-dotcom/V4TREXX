import SwiftUI
import UIKit

struct RepositoryHomeView: View {
    @Environment(\.appLanguage) private var language
    @AppStorage("v4rtexx.selected_game") private var selectedGame = "com.dts.freefireth"

    let onOpenSettings: () -> Void
    let onOpenLogs: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // V4RTEXX Header Banner
                        VStack(spacing: 12) {
                            AppLogo(size: 64)
                                .shadow(color: Color.white.opacity(0.25), radius: 12, x: 0, y: 6)

                            Text("V4RTEXX MANAGER")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)

                            Text("Select Target Game Profile")
                                .font(.subheadline)
                                .foregroundStyle(Color(white: 0.6))
                        }
                        .padding(.vertical, 8)

                        // JOIN TELEGRAM CHANNEL BUTTON
                        Button {
                            if let url = URL(string: "https://t.me/v4rtexxofficial") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Join My Telegram Channel")
                                    .font(.headline.weight(.bold))
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.subheadline.weight(.bold))
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.white.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)

                        // GAME SELECTOR CARD
                        VStack(alignment: .leading, spacing: 14) {
                            Text("TARGET GAME PROFILE")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(white: 0.6))

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
                                                .foregroundStyle(selectedGame == "com.dts.freefireth" ? .black : .white)
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
                                            .foregroundStyle(Color(white: 0.6))
                                    }

                                    Spacer()

                                    if selectedGame == "com.dts.freefireth" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(14)
                                .background(
                                    selectedGame == "com.dts.freefireth"
                                        ? Color(white: 0.18)
                                        : Color(white: 0.08)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            selectedGame == "com.dts.freefireth"
                                                ? Color.white
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
                                                .foregroundStyle(selectedGame == "com.dts.freefiremax" ? .black : .white)
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
                                            .foregroundStyle(Color(white: 0.6))
                                    }

                                    Spacer()

                                    if selectedGame == "com.dts.freefiremax" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(14)
                                .background(
                                    selectedGame == "com.dts.freefiremax"
                                        ? Color(white: 0.18)
                                        : Color(white: 0.08)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(
                                            selectedGame == "com.dts.freefiremax"
                                                ? Color.white
                                                : Color.white.opacity(0.08),
                                            lineWidth: selectedGame == "com.dts.freefiremax" ? 1.5 : 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(18)
                        .background(Color(white: 0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onOpenSettings()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}
