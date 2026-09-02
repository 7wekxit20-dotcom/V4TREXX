import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator
    @EnvironmentObject private var patchStore: PatchProjectStore
    @EnvironmentObject private var repositoryStore: PackageRepositoryStore
    @State private var tabNavigation = AppTabNavigationState()
    @State private var showSettings = false
    @State private var showLogs = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 10/255, green: 14/255, blue: 23/255)
                .ignoresSafeArea()

            // Main Tab Content with Smooth Animation Transitions
            ZStack {
                switch AppSection(rawValue: tabNavigation.selectedTab) ?? .home {
                case .home:
                    RepositoryHomeView(
                        onOpenSettings: { showSettings = true },
                        onOpenLogs: { showLogs = true }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                case .inject:
                    InjectView(
                        onOpenSettings: { showSettings = true },
                        onOpenLogs: { showLogs = true }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                case .library:
                    PatchProjectsView(
                        onOpenSettings: { showSettings = true },
                        onOpenLogs: { showLogs = true }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                case .clean:
                    CleanerView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                case .settings:
                    SettingsView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .animation(.easeInOut(duration: 0.22), value: tabNavigation.selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 64) // Leave space for custom bottom bar

            // Custom V4RTEXX Bottom Navigation Bar
            customTabBar
        }
        .tint(Color(red: 56/255, green: 189/255, blue: 248/255))
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showLogs) { LogView() }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabBarItem(section: .home, title: "Home", systemImage: "house.fill")
            tabBarItem(section: .inject, title: "Inject", systemImage: "syringe.fill")
            tabBarItem(section: .library, title: "Library", systemImage: "cube.fill")
            tabBarItem(section: .clean, title: "Clean", systemImage: "trash.fill")
            tabBarItem(section: .settings, title: "Settings", systemImage: "gearshape.fill")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Color(red: 22/255, green: 30/255, blue: 46/255)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func tabBarItem(section: AppSection, title: String, systemImage: String) -> some View {
        let isSelected = tabNavigation.selectedTab == section.rawValue

        return Button {
            withAnimation(.easeInOut(duration: 0.22)) {
                tabNavigation.select(section.rawValue)
            }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(red: 56/255, green: 189/255, blue: 248/255).opacity(0.2))
                            .frame(width: 44, height: 32)
                    }
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? Color(red: 56/255, green: 189/255, blue: 248/255) : Color(red: 148/255, green: 163/255, blue: 184/255))
                }

                Text(title)
                    .font(.caption2.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? Color(red: 56/255, green: 189/255, blue: 248/255) : Color(red: 148/255, green: 163/255, blue: 184/255))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
