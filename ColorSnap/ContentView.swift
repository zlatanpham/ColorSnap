import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ColorPickerViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerView

            Divider()

            if let color = viewModel.currentColor {
                ColorPreviewView(
                    color: color,
                    copiedFormat: viewModel.copiedFormat,
                    onCopy: { format in
                        viewModel.copyToClipboard(color: color, format: format)
                    }
                )

                Divider()
            }

            ColorHistoryView(
                colors: viewModel.colorHistory,
                selectedColor: viewModel.currentColor,
                onSelect: { viewModel.selectColor($0) },
                onDelete: { color in
                    Task { await viewModel.removeColor(color) }
                }
            )

            Divider()

            footerView
        }
        .frame(width: 320, height: 480)
        .task {
            await viewModel.loadHistory()
        }
    }

    private var headerView: some View {
        HStack {
            Text("ColorSnap")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Button(action: {
                Task { await viewModel.pickColor() }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "eyedropper")
                        .font(.system(size: 11))
                    Text("Pick")
                        .font(.system(size: 12, weight: .medium))
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(viewModel.isPicking)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var footerView: some View {
        HStack {
            Button("Settings") {
                if let appDelegate = NSApp.delegate as? AppDelegate {
                    appDelegate.showSettings()
                }
            }
            .buttonStyle(.borderless)
            .font(.system(size: 12))

            Spacer()

            Button("Clear") {
                Task { await viewModel.clearHistory() }
            }
            .buttonStyle(.borderless)
            .font(.system(size: 12))
            .disabled(viewModel.colorHistory.isEmpty)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .font(.system(size: 12))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
