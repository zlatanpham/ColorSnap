import AppKit
import SwiftUI

@MainActor
class ColorPickerViewModel: ObservableObject {
    @Published var currentColor: PickedColor?
    @Published var colorHistory: [PickedColor] = []
    @Published var isPicking = false
    @Published var copiedFormat: ColorFormat?
    @AppStorage("defaultColorFormat") var selectedFormat: String = ColorFormat.hex.rawValue

    private let pickerService = ColorPickerService.shared
    private let storageService = ColorStorageService.shared

    var defaultFormat: ColorFormat {
        ColorFormat(rawValue: selectedFormat) ?? .hex
    }

    func loadHistory() async {
        colorHistory = await storageService.loadColors()
        if currentColor == nil, let first = colorHistory.first {
            currentColor = first
        }
    }

    func pickColor() async {
        isPicking = true
        guard let nsColor = await pickerService.pickColor() else {
            isPicking = false
            return
        }
        let picked = PickedColor(nsColor: nsColor)
        currentColor = picked
        copyToClipboard(color: picked, format: defaultFormat)
        await storageService.saveColor(picked)
        colorHistory = await storageService.loadColors()
        isPicking = false
    }

    func selectColor(_ color: PickedColor) {
        currentColor = color
    }

    func copyToClipboard(color: PickedColor, format: ColorFormat) {
        let formatted = color.formatted(format)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(formatted, forType: .string)

        copiedFormat = format
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if copiedFormat == format {
                copiedFormat = nil
            }
        }
    }

    func removeColor(_ color: PickedColor) async {
        await storageService.removeColor(id: color.id)
        colorHistory = await storageService.loadColors()
        if currentColor?.id == color.id {
            currentColor = colorHistory.first
        }
    }

    func clearHistory() async {
        await storageService.clearAll()
        colorHistory = []
        currentColor = nil
    }
}
