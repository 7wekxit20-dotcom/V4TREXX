import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct PatchProjectsView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var store: PatchProjectStore
    @State private var showImporter = false
    @State private var searchText = ""
    let onOpenSettings: () -> Void
    let onOpenLogs: () -> Void

    // Default V4RTEXX packages matching Screenshot 1
    private let defaultPackages = [
        ("3D-Weapons.v4rtexx", "13.7 MB"),
        ("magicbullet.v4rtexx", "588 KB"),
        ("aimdrag.v4rtexx", "588 KB"),
        ("aimbody.v4rtexx", "588 KB"),
        ("aimneck.v4rtexx", "588 KB")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 10/255, green: 14/255, blue: 23/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header Description
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PACKAGE LIBRARY")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

                            Text("Import encrypted V4RTEXX packages from your admin dashboard.")
                                .font(.subheadline)
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        }
                        .padding(.horizontal, 4)

                        // Top Action Buttons matching Screenshot 1
                        HStack(spacing: 12) {
                            Button {
                                showImporter = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.down.fill")
                                    Text("Import .v4rtexx")
                                        .fontWeight(.bold)
                                }
                                .font(.subheadline)
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 56/255, green: 189/255, blue: 248/255), Color(red: 14/255, green: 165/255, blue: 233/255)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)

                            HStack(spacing: 8) {
                                Image(systemName: "shield.fill")
                                Text("Protected by V4RTEXX")
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                            .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }

                        // Search Bar
                        AppSearchField(
                            text: $searchText,
                            prompt: "Search packages...",
                            clearLabel: "Clear"
                        )
                        .padding(.horizontal, -AppTheme.pageInset)

                        // Package List Cards matching Screenshot 1
                        VStack(spacing: 12) {
                            ForEach(defaultPackages, id: \.0) { item in
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "shield.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.0)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(.white)
                                        Text("\(item.1) • Protected")
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                                }
                                .padding(16)
                                .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("V4RTEXX Library")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.data],
                allowsMultipleSelection: false
            ) { result in
                // File import handler
            }
        }
    }
}
