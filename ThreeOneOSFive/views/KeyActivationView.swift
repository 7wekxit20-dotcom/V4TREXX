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
                    AppLogo(size: 80)
                        .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.35), radius: 16, x: 0, y: 8)

                    Text("V4RTEXX MANAGER")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("License Activation Required")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                }

                // Key Input Card (Enlarged Container & Icon-Only Paste)
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ENTER YOUR LICENSE KEY")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                        HStack(spacing: 12) {
                            TextField("O13XN1OBC78AGYQ8B1K", text: $keyText)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.characters)
                                .foregroundStyle(.white)
                                .frame(minHeight: 32)
                                .onChange(of: keyText) { newValue in
                                    keyText = newValue.uppercased()
                                    errorMessage = nil
                                }

                            if !keyText.isEmpty {
                                Button {
                                    keyText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                                }
                                .buttonStyle(.plain)
                            }

                            // Icon-Only Paste Button
                            Button {
                                if let pasted = UIPasteboard.general.string {
                                    keyText = pasted.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                                }
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                    .frame(width: 42, height: 42)
                                    .background(Color(red: 30/255, green: 41/255, blue: 59/255))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(Color(red: 15/255, green: 23/255, blue: 42/255))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(errorMessage != nil ? Color.red : Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.4), lineWidth: 1.5)
                        )
                    }

                    // Strict "INVALID KEY" Error Alert
                    if let errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                        }
                        .font(.subheadline.weight(.bold))
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
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 56/255, green: 189/255, blue: 248/255), Color(red: 14/255, green: 165/255, blue: 233/255)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.35), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessing)

                    // Join Channel Button (Replaces Get Key)
                    Button {
                        if let url = URL(string: "https://t.me/v4rtexxofficial") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                            Text("Join Channel")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                    }
                    .padding(.top, 6)
                }
                .padding(22)
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
            errorMessage = "INVALID KEY"
            return
        }
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if KeySystem.activate(with: keyText) {
                onActivated()
            } else {
                errorMessage = "INVALID KEY"
                isProcessing = false
            }
        }
    }
}
