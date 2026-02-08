import KeyboardShortcuts
import SwiftUI

// MARK: - Settings Tab

private enum SettingsTab: String, CaseIterable {
    case general = "General"
    case about = "About"

    var icon: String {
        switch self {
        case .general: return "gear"
        case .about: return "info.circle"
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general
    @ObservedObject var viewModel: ColorPickerViewModel

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            tabContent
        }
        .frame(width: 420, height: 540)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 2) {
            ForEach(SettingsTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.vertical, 6)
    }

    private func tabButton(for tab: SettingsTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .frame(width: 24, height: 24)
                Text(tab.rawValue)
                    .font(.system(size: 10))
            }
            .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedTab == tab ? Color(nsColor: .separatorColor).opacity(0.3) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .general:
            GeneralTabView(viewModel: viewModel)
        case .about:
            AboutTabView()
        }
    }
}

// MARK: - General Tab

private struct GeneralTabView: View {
    @StateObject private var launchManager = LaunchAtLoginManager()
    @AppStorage("defaultColorFormat") private var defaultFormat: String = ColorFormat.hex.rawValue
    @ObservedObject var viewModel: ColorPickerViewModel
    @State private var showClearConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                settingsSection("SYSTEM") {
                    SettingsToggleRow(
                        title: "Launch at Login",
                        description: "Automatically opens ColorSnap when you start your Mac.",
                        isOn: $launchManager.isEnabled
                    )
                }

                sectionDivider()

                settingsSection("SHORTCUT") {
                    VStack(alignment: .leading, spacing: 6) {
                        KeyboardShortcuts.Recorder("Pick Color:", name: .pickColor)
                            .frame(maxWidth: 220, alignment: .leading)
                        Text("Global keyboard shortcut to activate the color picker.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }

                sectionDivider()

                settingsSection("FORMAT") {
                    VStack(alignment: .leading, spacing: 6) {
                        Picker("Default Format", selection: $defaultFormat) {
                            ForEach(ColorFormat.allCases) { format in
                                Text(format.rawValue).tag(format.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 220, alignment: .leading)
                        Text("The format used when copying a picked color.")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }

                if !viewModel.colorHistory.isEmpty {
                    sectionDivider()

                    settingsSection("HISTORY") {
                        VStack(alignment: .leading, spacing: 6) {
                            Button(action: {
                                showClearConfirmation = true
                            }) {
                                Text("Clear History")
                                    .font(.system(size: 13))
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            Text("Remove all saved colors from history.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                sectionDivider()

                Spacer(minLength: 24)

                HStack {
                    Spacer()
                    Button("Quit ColorSnap") {
                        NSApplication.shared.terminate(nil)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 40)
        }
        .alert("Clear History", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                Task { await viewModel.clearHistory() }
            }
        } message: {
            Text("Are you sure you want to remove all \(viewModel.colorHistory.count) saved colors? This cannot be undone.")
        }
    }

    // MARK: - Section Helpers

    private func settingsSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 16)
            content()
        }
    }

    private func sectionDivider() -> some View {
        Divider()
            .padding(.top, 14)
    }
}

// MARK: - Settings Toggle Row

private struct SettingsToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(title, isOn: $isOn)
                .toggleStyle(.checkbox)
                .font(.system(size: 13))
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - About Tab

private enum UpdateCheckState {
    case idle
    case checking
    case upToDate
    case available(version: String, url: URL)
    case error(String)
}

private struct AboutTabView: View {
    @State private var updateState: UpdateCheckState = .idle

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "eyedropper")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("ColorSnap")
                .font(.system(size: 18, weight: .semibold))

            Text("Version \(appVersion)")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Text("A macOS menu bar color picker")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            updateSection

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var updateSection: some View {
        Group {
            switch updateState {
            case .idle:
                Button("Check for Updates") {
                    checkForUpdate()
                }
                .buttonStyle(.bordered)

            case .checking:
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Checking for updates…")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

            case .upToDate:
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("You're up to date!")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

            case let .available(version, url):
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                        Text("Version \(version) is available")
                            .font(.system(size: 12))
                    }
                    Button("Download Update") {
                        NSWorkspace.shared.open(url)
                    }
                    .buttonStyle(.bordered)
                }

            case let .error(message):
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(message)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    Button("Retry") {
                        checkForUpdate()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(height: 50, alignment: .center)
    }

    private func checkForUpdate() {
        updateState = .checking
        Task {
            do {
                let status = try await UpdateService.shared.checkForUpdate()
                switch status {
                case .upToDate:
                    updateState = .upToDate
                case let .available(version, url):
                    updateState = .available(version: version, url: url)
                }
            } catch {
                updateState = .error(error.localizedDescription)
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

#Preview {
    SettingsView(viewModel: ColorPickerViewModel())
}
