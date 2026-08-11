import CoreGraphics
import Testing
@testable import ShiftSpaceToggle

@Test func keyCodesMatchMacOSVirtualKeyCodes() {
    #expect(KeyboardMonitor.spaceKeyCode == CGKeyCode(49))
    #expect(KeyboardMonitor.leftShiftKeyCode == CGKeyCode(56))
    #expect(KeyboardMonitor.jisEisuKeyCode == CGKeyCode(0x66))
    #expect(KeyboardMonitor.jisKanaKeyCode == CGKeyCode(0x68))
}

@Test func leftShiftSpaceTogglesAndSuppressesBothEvents() {
    var state = ShortcutStateMachine()

    #expect(state.handle(
        kind: .keyDown,
        isSpace: true,
        leftShiftIsDown: true,
        hasDisallowedModifiers: false,
        isRepeat: false
    ) == .toggleInputSource)
    #expect(state.handle(
        kind: .keyUp,
        isSpace: true,
        leftShiftIsDown: false,
        hasDisallowedModifiers: false,
        isRepeat: false
    ) == .suppress)
}

@Test func repeatIsSuppressedWithoutToggling() {
    var state = ShortcutStateMachine()

    #expect(state.handle(
        kind: .keyDown,
        isSpace: true,
        leftShiftIsDown: true,
        hasDisallowedModifiers: false,
        isRepeat: true
    ) == .suppress)
}

@Test func extraModifierAllowsEventToPassThrough() {
    var state = ShortcutStateMachine()

    #expect(state.handle(
        kind: .keyDown,
        isSpace: true,
        leftShiftIsDown: true,
        hasDisallowedModifiers: true,
        isRepeat: false
    ) == .passThrough)
}

@Test func unrelatedKeyPassesThrough() {
    var state = ShortcutStateMachine()

    #expect(state.handle(
        kind: .keyDown,
        isSpace: false,
        leftShiftIsDown: true,
        hasDisallowedModifiers: false,
        isRepeat: false
    ) == .passThrough)
}
