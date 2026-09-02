import SwiftUI
import UIKit

struct KeyActivationView: View {
    @State private var keyText = ""
    @State private var errorMessage: String?
    @State private var isProcessing = false
    let onActivated: () -> Void

    var body: some View {
        ZStack {
            Color(red: 10/255, green: 14/255, blue: 23/255)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Header Logo & Title
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color(red: 56/255, green: 189/255, blue: 248/255), Color(red: 14/255, green: 165/255, blue: 233/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                            .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.35), radius: 16, x: 0, y: 8)

                        Image(systemName: "key.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Text("V4RTEXX MANAGER")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("License Activation Required")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                }

                // Key Input Card
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ENTER YOUR LICENSE KEY")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                        HStack(spacing: 8) {
                            TextField("O13XN1OBC78AGYQ8B1K", text: $keyText)
                                .font(.system(.body, design: .monospaced).weight(.semibold))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.characters)
                                .foregroundStyle(.white)
                                .onChange(of: keyText) { newValue in
                                    keyText = newValue.uppercased()
                                    errorMessage = nil
                                }

                            if !keyText.isEmpty {
                                Button {
                                    keyText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                                }
                                .buttonStyle(.plain)
                            }

                            Button {
                                if let pasted = UIPasteboard.general.string {
                                    keyText = pasted.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("Paste")
                                }
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(red: 30/255, green: 41/255, blue: 59/255))
                                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(14)
                        .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(errorMessage != nil ? Color.red.opacity(0.8) : Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.3), lineWidth: 1)
                        )
                    }

                    if let errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Activate Button
                    Button {
                        activateKey()
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Image(systemName: "checkmark.shield.fill")
                                Text("Activate V4RTEXX")
                                    .fontWeight(.bold)
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 56/255, green: 189/255, blue: 248/255), Color(red: 14/255, green: 165/255, blue: 233/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessing)

                    // Get Key Telegram Link
                    Button {
                        if let url = URL(string: "https://t.me/V4RTEXX_BOT") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                            Text("Get Key from Telegram Bot")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                    }
                    .padding(.top, 8)
                }
                .padding(20)
                .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                Spacer()

                Text("V4RTEXX MANAGER v2.0 • Security Encrypted")
                    .font(.caption2)
                    .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                    .padding(.bottom, 16)
            }
        }
    }

    private func activateKey() {
        guard !keyText.isEmpty else {
            errorMessage = "Please enter a valid license key"
            return
        }
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if KeySystem.activate(with: keyText) {
                onActivated()
            } else {
                errorMessage = "Invalid key format. Example: O13XN1OBC78AGYQ8B1K"
                isProcessing = false
            }
        }
    }
}
