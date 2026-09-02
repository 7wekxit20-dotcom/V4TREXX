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
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection
                        actionButtonsSection
                        if !store.items.isEmpty {
                            searchSection
                        }
                        contentSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
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
        .padding(.horizontal, 2)
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
        VStack(spacing: 14) {
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private var packageListView: some View {
        VStack(spacing: 10) {
            ForEach(items) { item in
                CompactPackageRow(
                    item: item,
                    isSelected: selectedPackagePath == item.packageURL.path,
                    onSelect: {
                        selectedPackagePath = item.packageURL.path
                    },
                    onExport: {
                        exportPackage(url: item.packageURL)
                    },
                    onDelete: {
                        store.delete(item)
                        if selectedPackagePath == item.packageURL.path {
                            selectedPackagePath = ""
                        }
                    }
                )
            }
        }
    }

    private func exportPackage(url: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        rootVC.present(activityVC, animated: true)
    }
}

// COMPACT PACKAGE ROW WITH SWIPE LEFT FOR EXPORT & DELETE
struct CompactPackageRow: View {
    let item: PatchLibraryItem
    let isSelected: Bool
    let onSelect: () -> Void
    let onExport: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showActions = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // SWIPE REVEAL ACTION BUTTONS (PULL TO THE LEFT)
            HStack(spacing: 8) {
                Spacer()

                Button(action: onExport) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(red: 30/255, green: 58/255, blue: 90/255))
                        VStack(spacing: 2) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14, weight: .bold))
                            Text("Export")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Color(red: 56/255, green: 189/255, blue: 248/255))
                    }
                    .frame(width: 58, height: 52)
                }

                Button(action: onDelete) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(red: 70/255, green: 20/255, blue: 25/255))
                        VStack(spacing: 2) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Delete")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Color.red)
                    }
                    .frame(width: 58, height: 52)
                }
            }

            // MAIN COMPACT PACKAGE CARD
            Button(action: onSelect) {
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
                        Text("Protected V4RTEXX Package • Swipe left for options")
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
                            .font(.system(size: 12, weight: .bold))
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
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            isSelected
                                ? Color(red: 56/255, green: 189/255, blue: 248/255)
                                : Color.white.opacity(0.06),
                            lineWidth: isSelected ? 1.5 : 1
                        )
                )
            }
            .buttonStyle(.plain)
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 15, coordinateSpace: .local)
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -130)
                        } else if showActions {
                            offset = min(-130 + value.translation.width, 0)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if value.translation.width < -50 {
                                offset = -130
                                showActions = true
                            } else {
                                offset = 0
                                showActions = false
                            }
                        }
                    }
            )
        }
    }
}
