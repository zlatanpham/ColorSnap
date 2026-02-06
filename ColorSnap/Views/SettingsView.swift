import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @StateObject private var launchManager = LaunchAtLoginManager()
    @AppStorage("defaultColorFormat") private var defaultFormat: String = ColorFormat.hex.rawValue

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 400, height: 250)
    }

    private var generalTab: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchManager.isEnabled)
                .toggleStyle(.switch)

            KeyboardShortcuts.Recorder("Pick Color Shortcut:", name: .pickColor)

            Picker("Default Format", selection: $defaultFormat) {
                ForEach(ColorFormat.allCases) { format in
                    Text(format.rawValue).tag(format.rawValue)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "eyedropper")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("ColorSnap")
                .font(.headline)

            Text("Version \(appVersion)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("A macOS menu bar color picker")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

#Preview {
    SettingsView()
}
