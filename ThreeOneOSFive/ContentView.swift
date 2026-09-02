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
            Color.black
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
            .padding(.bottom, 64)

            // Custom V4RTEXX Bottom Navigation Bar
            customTabBar
        }
        .tint(Color.white)
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
            Color(white: 0.12)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.5), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func tabBarItem(section: AppSection, title: String, systemImage: String) -> some View {
        let isSelected = tabNavigation.selectedTab == section.rawValue

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                tabNavigation.select(section.rawValue)
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.white : Color(white: 0.5))

                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.white : Color(white: 0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                isSelected
                    ? Color(white: 0.25)
                    : Color.clear
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
