import Carbon
@preconcurrency import CoreGraphics
import Foundation

@MainActor
final class KeyboardMonitor {
    static let spaceKeyCode = CGKeyCode(kVK_Space)
    static let leftShiftKeyCode = CGKeyCode(kVK_Shift)
    static let jisEisuKeyCode = CGKeyCode(kVK_JIS_Eisu)
    static let jisKanaKeyCode = CGKeyCode(kVK_JIS_Kana)

    private let eventMarker: Int64 = 0x546F676953706163
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var leftShiftIsDown = false
    private var shortcutState = ShortcutStateMachine()

    var isRunning: Bool {
        guard let eventTap else { return false }
        return CFMachPortIsValid(eventTap) && CGEvent.tapIsEnabled(tap: eventTap)
    }

    func start() throws {
        if eventTap != nil {
            guard !isRunning else { return }
            stop()
        }

        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
            | CGEventMask(1 << CGEventType.keyUp.rawValue)
            | CGEventMask(1 << CGEventType.flagsChanged.rawValue)

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else { return Unmanaged.passUnretained(event) }
            let monitor = Unmanaged<KeyboardMonitor>
                .fromOpaque(userInfo)
                .takeUnretainedValue()
            return MainActor.assumeIsolated {
                monitor.handle(type: type, event: event)
            }
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            throw MonitorError.eventTapUnavailable
        }

        guard let source = CFMachPortCreateRunLoopSource(nil, tap, 0) else {
            CFMachPortInvalidate(tap)
            throw MonitorError.runLoopSourceUnavailable
        }

        eventTap = tap
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func stop() {
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        if let eventTap {
            CFMachPortInvalidate(eventTap)
        }
        runLoopSource = nil
        eventTap = nil
        leftShiftIsDown = false
        shortcutState = ShortcutStateMachine()
    }

    private func handle(
        type: CGEventType,
        event: CGEvent
    ) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap { CGEvent.tapEnable(tap: eventTap, enable: true) }
            return Unmanaged.passUnretained(event)
        }

        if event.getIntegerValueField(.eventSourceUserData) == eventMarker {
            return Unmanaged.passUnretained(event)
        }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

        if type == .flagsChanged, keyCode == Self.leftShiftKeyCode {
            leftShiftIsDown = event.flags.contains(.maskShift)
            return Unmanaged.passUnretained(event)
        }

        let leftShiftIsCurrentlyDown = leftShiftIsDown || CGEventSource.keyState(
            .combinedSessionState,
            key: Self.leftShiftKeyCode
        )

        let disallowedModifiers: CGEventFlags = [
            .maskCommand,
            .maskControl,
            .maskAlternate,
            .maskSecondaryFn
        ]
        let decision = shortcutState.handle(
            kind: KeyboardEventKind(type),
            isSpace: keyCode == Self.spaceKeyCode,
            leftShiftIsDown: leftShiftIsCurrentlyDown,
            hasDisallowedModifiers: !event.flags.intersection(disallowedModifiers).isEmpty,
            isRepeat: event.getIntegerValueField(.keyboardEventAutorepeat) != 0
        )

        switch decision {
        case .passThrough:
            return Unmanaged.passUnretained(event)
        case .suppress:
            return nil
        case .toggleInputSource:
            toggleInputSource()
            return nil
        }
    }

    private func toggleInputSource() {
        postKey(InputSource.currentLanguageIsJapanese
            ? Self.jisEisuKeyCode
            : Self.jisKanaKeyCode)
    }

    private func postKey(_ keyCode: CGKeyCode) {
        for isDown in [true, false] {
            guard let event = CGEvent(
                keyboardEventSource: nil,
                virtualKey: keyCode,
                keyDown: isDown
            ) else { continue }

            event.flags = []
            event.setIntegerValueField(.eventSourceUserData, value: eventMarker)
            event.post(tap: .cgSessionEventTap)
        }
    }

    enum MonitorError: LocalizedError {
        case eventTapUnavailable
        case runLoopSourceUnavailable

        var errorDescription: String? {
            switch self {
            case .eventTapUnavailable:
                "イベント監視を開始できません。アクセシビリティ権限を確認してください。"
            case .runLoopSourceUnavailable:
                "イベント監視用のRunLoopを作成できません。"
            }
        }
    }
}
