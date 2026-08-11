import Carbon
import Foundation

enum InputSource {
    static var currentLanguageIsJapanese: Bool {
        guard let source = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
              let rawLanguages = TISGetInputSourceProperty(
                  source,
                  kTISPropertyInputSourceLanguages
              ) else {
            return false
        }

        let languages = Unmanaged<CFArray>
            .fromOpaque(rawLanguages)
            .takeUnretainedValue() as NSArray

        return languages.contains { value in
            (value as? String)?.hasPrefix("ja") == true
        }
    }
}
