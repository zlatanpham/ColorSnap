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

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            Divider()
            tabContent
        }
        .frame(width: 420, height: 460)
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
            GeneralTabView()
        case .about:
            AboutTabView()
        }
    }
}

// MARK: - General Tab

private struct GeneralTabView: View {
    @StateObject private var launchManager = LaunchAtLoginManager()
    @AppStorage("defaultColorFormat") private var defaultFormat: String = ColorFormat.hex.rawValue

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

private struct AboutTabView: View {
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

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

#Preview {
    SettingsView()
}
