import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ColorPickerViewModel

    var body: some View {
        VStack(spacing: 0) {
            headerView

            if viewModel.currentColor != nil {
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
        VStack(spacing: 0) {
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
            .padding(.top, 8)
            .padding(.bottom, 2)

            if let color = viewModel.currentColor {
                ColorPreviewView(
                    color: color,
                    copiedFormat: viewModel.copiedFormat,
                    onCopy: { format in
                        viewModel.copyToClipboard(color: color, format: format)
                    }
                )
            }
        }
    }

    private var footerView: some View {
        HStack {
            Button("Settings") {
                AppDelegate.shared?.showSettings()
            }
            .buttonStyle(.borderless)
            .font(.system(size: 12))
            .keyboardShortcut(",", modifiers: .command)

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
    }
}

#Preview {
    ContentView()
        .environmentObject(ColorPickerViewModel())
}
