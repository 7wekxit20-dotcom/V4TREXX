import SwiftUI
import UIKit
import UniformTypeIdentifiers

private struct PatchFileUTTypes {
    static let v4rtexx = UTType(filenameExtension: "v4rtexx") ?? UTType(importedAs: "com.v4rtexx.patch-package")
    static let legacy3105 = UTType(filenameExtension: "3105") ?? .data
    static let allowedTypes: [UTType] = [v4rtexx, legacy3105, .data, .item]
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
                Color(red: 10/255, green: 14/255, blue: 23/255)
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
                        if accessing { url.stopAccessingSecurityScopedResource() }
                    }
                    store.importPackage(at: url)
                    selectedPackagePath = url.path
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))

            Text("Import encrypted V4RTEXX packages from your admin dashboard.")
                .font(.caption)
                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
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
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(
                    LinearGradient(
                        colors: [Color(red: 56/255, green: 189/255, blue: 248/255), Color(red: 14/255, green: 165/255, blue: 233/255)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.3), radius: 6, x: 0, y: 3)
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
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                    .fill(Color(red: 22/255, green: 30/255, blue: 46/255))
                    .frame(width: 60, height: 60)
                Image(systemName: "cube.box.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
            }

            Text("No Packages Imported")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)

            Text("Import a .v4rtexx package file to select it for injection.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
                .padding(.horizontal, 20)

            Button {
                showImporter = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                    Text("Import Package")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 22/255, green: 30/255, blue: 46/255))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.4), lineWidth: 1)
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

                    Button {
                        exportPackage(url: item.packageURL)
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .tint(Color(red: 56/255, green: 189/255, blue: 248/255))
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

// SLEEK COMPACT PACKAGE ROW CARD
struct PackageRowCard: View {
    let item: PatchLibraryItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        isSelected
                            ? Color(red: 56/255, green: 189/255, blue: 248/255)
                            : Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.18)
                    )
                    .frame(width: 32, height: 32)
                Image(systemName: "shield.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(isSelected ? .black : Color(red: 56/255, green: 189/255, blue: 248/255))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.packageURL.lastPathComponent)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .foregroundStyle(.white)
                Text("Protected V4RTEXX Package • Swipe left")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color(red: 148/255, green: 163/255, blue: 184/255))
            }

            Spacer()

            if isSelected {
                HStack(spacing: 3) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Selected")
                }
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
            } else {
                Image(systemName: "chevron.left")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(red: 100/255, green: 116/255, blue: 139/255))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            isSelected
                ? Color(red: 25/255, green: 45/255, blue: 70/255)
                : Color(red: 18/255, green: 25/255, blue: 38/255)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    isSelected
                        ? Color(red: 56/255, green: 189/255, blue: 248/255)
                        : Color.white.opacity(0.06),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
    }
}
