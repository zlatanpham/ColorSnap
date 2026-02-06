import SwiftUI

struct SettingsView: View {
    @StateObject private var launchManager = LaunchAtLoginManager()

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
        .frame(width: 400, height: 200)
    }

    private var generalTab: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchManager.isEnabled)
                .toggleStyle(.switch)

            // Add more settings here as needed
        }
        .formStyle(.grouped)
        .padding()
    }

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Image(systemName: "app.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("MacAppTemplate")
                .font(.headline)

            Text("Version \(appVersion)")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("A macOS menu bar app template")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Link("View on GitHub", destination: URL(string: "https://github.com")!)
                .font(.caption)
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
