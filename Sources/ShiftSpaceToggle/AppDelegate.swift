@preconcurrency import ApplicationServices
import AppKit
import Carbon
import Observation
import ServiceManagement

@MainActor
@Observable
final class AppDelegate: NSObject, NSApplicationDelegate {
    private(set) var accessibilityGranted = AXIsProcessTrusted()
    private(set) var monitoringActive = false
    private(set) var monitoringError: String?
    private(set) var japaneseInputActive = InputSource.currentLanguageIsJapanese
    private(set) var isEnabled = true
    private(set) var launchAtLogin = SMAppService.mainApp.status == .enabled

    @ObservationIgnored private let monitor = KeyboardMonitor()
    @ObservationIgnored private var inputSourceObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        requestAccessibilityPermission()
        refreshPermissionAndMonitoring()
        observeInputSourceChanges()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        refreshPermissionAndMonitoring()
    }

    private func startMonitoring() {
        guard isEnabled, !monitor.isRunning, accessibilityGranted else { return }

        do {
            try monitor.start()
            monitoringActive = monitor.isRunning
            monitoringError = nil
        } catch {
            NSLog("Unable to start keyboard monitoring: %@", error.localizedDescription)
            monitoringActive = false
            monitoringError = error.localizedDescription
        }
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if enabled {
            startMonitoring()
        } else {
            monitor.stop()
            monitoringActive = false
            monitoringError = nil
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Unable to change launch-at-login setting: %@", error.localizedDescription)
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    func refreshPermissionAndMonitoring() {
        accessibilityGranted = AXIsProcessTrusted()
        if !accessibilityGranted {
            monitor.stop()
            monitoringActive = false
        }
        startMonitoring()
    }

    private func observeInputSourceChanges() {
        let notificationName = Notification.Name(
            kTISNotifySelectedKeyboardInputSourceChanged as String
        )
        inputSourceObserver = DistributedNotificationCenter.default().addObserver(
            forName: notificationName,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.japaneseInputActive = InputSource.currentLanguageIsJapanese
            }
        }
    }

    private func requestAccessibilityPermission() {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        _ = AXIsProcessTrustedWithOptions([key: true] as CFDictionary)
    }

    static func openAccessibilitySettings() {
        let url = URL(
            string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        )!
        NSWorkspace.shared.open(url)
    }

    static func restartApplication() {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(
            at: Bundle.main.bundleURL,
            configuration: configuration
        ) { _, error in
            Task { @MainActor in
                if let error {
                    NSLog("Unable to restart application: %@", error.localizedDescription)
                } else {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
    }
}
