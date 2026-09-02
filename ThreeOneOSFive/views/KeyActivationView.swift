import SwiftUI
import UIKit

struct KeyActivationView: View {
    @State private var keyText = ""
    @State private var errorMessage: String?
    @State private var isProcessing = false
    let onActivated: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Header Logo & Title
                VStack(spacing: 12) {
                    AppLogo(size: 80)
                        .shadow(color: Color.white.opacity(0.2), radius: 16, x: 0, y: 8)

                    Text("V4RTEXX MANAGER")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("License Activation Required")
                        .font(.subheadline)
                        .foregroundStyle(Color(white: 0.6))
                }

                // Key Input Card (Black & White Theme, Enlarged Input, Icon-Only Paste)
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ENTER YOUR LICENSE KEY")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color(white: 0.6))

                        HStack(spacing: 12) {
                            TextField("License Key", text: $keyText)
                                .font(.system(size: 17, weight: .bold, design: .monospaced))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.characters)
                                .foregroundStyle(.white)
                                .frame(minHeight: 34)
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
                                        .foregroundStyle(Color(white: 0.5))
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
                                    .foregroundStyle(.black)
                                    .frame(width: 42, height: 42)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(14)
                        .background(Color(white: 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(errorMessage != nil ? Color.red : Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                    }

                    // Strict Error Alert
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
                                Text("Activate")
                                    .fontWeight(.bold)
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.white.opacity(0.25), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessing)

                    // Join Channel Button
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
                        .foregroundStyle(Color.white)
                    }
                    .padding(.top, 6)
                }
                .padding(22)
                .background(Color(white: 0.08))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
                .padding(.horizontal, 20)

                Spacer()

                Text("V4RTEXX MANAGER • Verified License")
                    .font(.caption2)
                    .foregroundStyle(Color(white: 0.5))
                    .padding(.bottom, 16)
            }
        }
    }

    private func activateKey() {
        let trimmed = keyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "INVALID KEY"
            return
        }

        isProcessing = true
        errorMessage = nil

        KeySystem.verifyKeyAuth(key: trimmed) { success, errMsg in
            isProcessing = false
            if success {
                onActivated()
            } else {
                errorMessage = errMsg ?? "INVALID KEY"
            }
        }
    }
}
