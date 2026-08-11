import CoreGraphics

nonisolated enum KeyboardEventKind: Equatable, Sendable {
    case keyDown
    case keyUp
    case other

    init(_ type: CGEventType) {
        switch type {
        case .keyDown: self = .keyDown
        case .keyUp: self = .keyUp
        default: self = .other
        }
    }
}

nonisolated enum ShortcutDecision: Equatable, Sendable {
    case passThrough
    case suppress
    case toggleInputSource
}

nonisolated struct ShortcutStateMachine: Sendable {
    private var swallowingSpace = false

    mutating func handle(
        kind: KeyboardEventKind,
        isSpace: Bool,
        leftShiftIsDown: Bool,
        hasDisallowedModifiers: Bool,
        isRepeat: Bool
    ) -> ShortcutDecision {
        guard isSpace else { return .passThrough }

        if kind == .keyDown, leftShiftIsDown, !hasDisallowedModifiers {
            swallowingSpace = true
            return isRepeat ? .suppress : .toggleInputSource
        }

        if kind == .keyUp, swallowingSpace {
            swallowingSpace = false
            return .suppress
        }

        return .passThrough
    }
}
