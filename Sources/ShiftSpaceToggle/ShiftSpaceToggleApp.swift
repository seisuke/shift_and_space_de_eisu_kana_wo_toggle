import AppKit
import SwiftUI

@main
struct ShiftSpaceToggleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuContent(appDelegate: appDelegate)
        } label: {
            StatusLabel(appDelegate: appDelegate)
        }
        .menuBarExtraStyle(.menu)
    }
}

private struct StatusLabel: View {
    let appDelegate: AppDelegate

    var body: some View {
        Image(nsImage: appDelegate.japaneseInputActive
            ? StatusIcon.kana
            : StatusIcon.eisu)
        .resizable()
        .interpolation(.high)
        .frame(width: 22, height: 22)
        .offset(y: 2)
    }
}

private enum StatusIcon {
    static let kana = loadImage(named: "StatusKana")
    static let eisu = loadImage(named: "StatusEisu")

    private static func loadImage(named name: String) -> NSImage {
        guard let url = Bundle.main.url(forResource: name, withExtension: "png"),
              let image = NSImage(contentsOf: url) else {
            assertionFailure("Missing status icon: \(name).png")
            return NSImage(size: NSSize(width: 22, height: 22))
        }
        image.size = NSSize(width: 22, height: 22)
        image.isTemplate = true
        return image
    }
}

private struct MenuContent: View {
    let appDelegate: AppDelegate

    var body: some View {
        Toggle(
            "有効",
            isOn: Binding(
                get: { appDelegate.isEnabled },
                set: { appDelegate.setEnabled($0) }
            )
        )

        Toggle(
            "ログイン時に起動",
            isOn: Binding(
                get: { appDelegate.launchAtLogin },
                set: { appDelegate.setLaunchAtLogin($0) }
            )
        )

        Divider()

        if appDelegate.accessibilityGranted {
            Label("アクセシビリティ許可済み", systemImage: "checkmark.circle")
        } else {
            Label("アクセシビリティ権限が必要", systemImage: "exclamationmark.triangle")
        }

        if appDelegate.monitoringActive {
            Label("キー監視動作中", systemImage: "keyboard.badge.eye")
        } else if appDelegate.isEnabled {
            Label("キー監視停止中", systemImage: "exclamationmark.triangle")
        }

        if let error = appDelegate.monitoringError {
            Text(error)
        }

        Button("アクセシビリティ設定を開く") {
            AppDelegate.openAccessibilitySettings()
        }

        Button("アプリを再起動") {
            AppDelegate.restartApplication()
        }

        Divider()

        Button("終了") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
