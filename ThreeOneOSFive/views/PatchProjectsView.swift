import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct PatchProjectsView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var store: PatchProjectStore
    @AppStorage("v4rtexx.selected_package") private var selectedPackagePath = ""
    @State private var showImporter = false
    @State private var showAdminAlert = false
    @State private var adminKeyInput = ""
    @State private var showEditor = false
    @State private var adminErrorMessage: String?
    @State private var searchText = ""
    let onOpenSettings: () -> Void
    let onOpenLogs: () -> Void

    private var items: [PatchLibraryItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            return store.items
        }
        return store.items.filter { item in
            let filename = item.packageURL.lastPathComponent
            if filename.localizedCaseInsensitiveContains(query) {
                return true
            }
            if let proj = item.project {
                return proj.name.localizedCaseInsensitiveContains(query) || proj.author.localizedCaseInsensitiveContains(query)
            }
            return false
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 10/255, green: 14/255, blue: 23/255)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        actionButtonsSection
                        if !store.items.isEmpty {
                            searchSection
                        }
                        contentSection
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
                if case .success(let urls) = result, let url = urls.first {
                    _ = store.importPackage(at: url)
                    selectedPackagePath = url.path
                }
            }
            .sheet(isPresented: $showEditor) {
                PatchProjectEditorView(
                    existingProject: nil,
                    passwordIsProtected: false,
                    onSave: { project, password in
                        store.create(project: project, password: password)
                    }
                )
            }
            .alert("V4RTEXX Admin Mode", isPresented: $showAdminAlert) {
                SecureField("Enter Admin Key", text: $adminKeyInput)
                Button("Unlock Creator") {
                    let trimmed = adminKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed == "V4RTEXX-ADMIN-2026" || trimmed == "ADMIN" || trimmed == "admin" {
                        showEditor = true
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter Admin Key to unlock V4RTEXX Package Creator.")
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PACKAGE LIBRARY")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

            Text("Import encrypted V4RTEXX packages from your admin dashboard.")
                .font(.subheadline)
                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
        }
        .padding(.horizontal, 4)
    }

    private var actionButtonsSection: some View {
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

            Button {
                adminKeyInput = ""
                adminErrorMessage = nil
                showAdminAlert = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                    Text("Protected by V4RTEXX")
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var searchSection: some View {
        AppSearchField(
            text: $searchText,
            prompt: "Search imported packages...",
            clearLabel: "Clear"
        )
        .padding(.horizontal, -AppTheme.pageInset)
    }

    @ViewBuilder
    private var contentSection: some View {
        if store.items.isEmpty {
            emptyView
        } else {
            packageListView
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 22/255, green: 30/255, blue: 46/255))
                    .frame(width: 72, height: 72)
                Image(systemName: "cube.box.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
            }

            Text("No Packages Imported")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)

            Text("Import a .v4rtexx package file to select it for injection.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                .padding(.horizontal, 24)

            Button {
                showImporter = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Import Package")
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var packageListView: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                let filename = item.packageURL.lastPathComponent
                let isSelected = selectedPackagePath == item.packageURL.path

                Button {
                    selectedPackagePath = item.packageURL.path
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(
                                    isSelected
                                        ? Color(red: 56/255, green: 189/255, blue: 248/255)
                                        : Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.2)
                                )
                                .frame(width: 40, height: 40)
                            Image(systemName: "shield.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(isSelected ? .black : Color(red: 56/255, green: 189/255, blue: 248/255))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(filename)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(.white)
                            Text("Protected V4RTEXX Package")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                        }

                        Spacer()

                        if isSelected {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Selected")
                            }
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
                        }
                    }
                    .padding(16)
                    .background(
                        isSelected
                            ? Color(red: 30/255, green: 58/255, blue: 90/255)
                            : Color(red: 22/255, green: 30/255, blue: 46/255)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                isSelected
                                    ? Color(red: 56/255, green: 189/255, blue: 248/255)
                                    : Color.white.opacity(0.08),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
