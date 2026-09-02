import SwiftUI
import UIKit
import UniformTypeIdentifiers

private struct PatchFileUTTypes {
    static let v4rtexx = UTType(filenameExtension: "v4rtexx") ?? UTType(importedAs: "com.v4rtexx.patch-package")
    static let allowedTypes: [UTType] = [v4rtexx, .data, .item]
}

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
                Color.black
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 14) {
                    headerSection
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                    actionButtonsSection
                        .padding(.horizontal, 16)

                    if !store.items.isEmpty {
                        searchSection
                            .padding(.horizontal, 16)
                    }

                    contentSection
                }
            }
            .navigationTitle("V4RTEXX Library")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: PatchFileUTTypes.allowedTypes,
                allowsMultipleSelection: false
            ) { result in
                if case .success(let urls) = result, let url = urls.first {
                    let accessing = url.startAccessingSecurityScopedResource()
                    defer {
                        if accessing {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }

                    var readData: Data? = try? Data(contentsOf: url)
                    if readData == nil {
                        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                        try? FileManager.default.removeItem(at: tempURL)
                        if (try? FileManager.default.copyItem(at: url, to: tempURL)) != nil {
                            readData = try? Data(contentsOf: tempURL)
                            try? FileManager.default.removeItem(at: tempURL)
                        }
                    }

                    if let data = readData {
                        _ = store.importPackage(data: data)
                    } else {
                        store.importPackage(at: url)
                    }
                    selectedPackagePath = url.path
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        store.reload()
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                PatchProjectEditorView(
                    existingProject: nil,
                    passwordIsProtected: false,
                    onSave: { project, password in
                        store.create(project: project, password: password)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            store.reload()
                        }
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
        VStack(alignment: .leading, spacing: 4) {
            Text("PACKAGE LIBRARY")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(white: 0.7))

            Text("Import encrypted V4RTEXX packages from your admin dashboard.")
                .font(.caption)
                .foregroundStyle(Color(white: 0.6))
        }
    }

    private var actionButtonsSection: some View {
        HStack(spacing: 10) {
            Button {
                showImporter = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Import .v4rtexx")
                        .fontWeight(.bold)
                }
                .font(.subheadline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.white.opacity(0.2), radius: 6, x: 0, y: 3)
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
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(Color(white: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
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
        VStack(spacing: 14) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(white: 0.12))
                    .frame(width: 60, height: 60)
                Image(systemName: "cube.box.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
            }

            Text("No Packages Imported")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)

            Text("Import a .v4rtexx package file to select it for injection.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(white: 0.6))
                .padding(.horizontal, 20)

            Button {
                showImporter = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Import Package")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(white: 0.15))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var packageListView: some View {
        List {
            ForEach(items) { item in
                let isSelected = selectedPackagePath == item.packageURL.path

                PackageRowCard(
                    item: item,
                    isSelected: isSelected
                )
                .onTapGesture {
                    selectedPackagePath = item.packageURL.path
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        store.delete(item)
                        if selectedPackagePath == item.packageURL.path {
                            selectedPackagePath = ""
                        }
                    } label: {
                        Label("Delete", systemImage: "trash.fill")
                    }
                    .tint(Color.red)

                    Button {
                        exportPackage(url: item.packageURL)
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up.fill")
                    }
                    .tint(Color(white: 0.25))
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func exportPackage(url: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        rootVC.present(activityVC, animated: true)
    }
}

struct PackageRowCard: View {
    let item: PatchLibraryItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isSelected ? Color.white : Color(white: 0.18))
                    .frame(width: 32, height: 32)
                Image(systemName: "shield.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(isSelected ? .black : .white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.packageURL.lastPathComponent)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(.white)
                Text("Protected V4RTEXX Package • Swipe left")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color(white: 0.6))
            }

            Spacer()

            if isSelected {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Selected")
                }
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
            } else {
                Image(systemName: "chevron.left")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(white: 0.5))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isSelected ? Color(white: 0.15) : Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isSelected ? Color.white : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
        )
    }
}
