import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Main content
            ItemListView(viewModel: viewModel)

            Divider()

            // Footer
            footerView
        }
        .frame(width: 350, height: 500)
        .task {
            await viewModel.loadItems()
        }
    }

    private var headerView: some View {
        HStack {
            Text("MacAppTemplate")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Button(action: {
                Task {
                    await viewModel.loadItems()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12))
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var footerView: some View {
        HStack {
            Button("Settings...") {
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.showSettings()
                }
            }
            .buttonStyle(.borderless)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
