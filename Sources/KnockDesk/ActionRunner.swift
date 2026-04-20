import AppKit
import Foundation

final class ActionRunner {
    func run(_ action: KnockAction, appBundleIdentifier: String) {
        switch action {
        case .playPause:
            sendMediaPlayPause()
        case .switchApp:
            sendCmdTab()
        case .sleepMac:
            runAppleScript("tell application \"System Events\" to sleep")
        case .openYouTube:
            openYouTube()
        case .openApplication:
            openApp(bundleIdentifier: appBundleIdentifier)
        }
    }

    private func sendMediaPlayPause() {
        // NX_KEYTYPE_PLAY = 16 on macOS
        let keyCode: Int32 = 16
        postSystemDefinedMediaKey(keyCode: keyCode, keyDown: true)
        postSystemDefinedMediaKey(keyCode: keyCode, keyDown: false)
    }

    private func sendCmdTab() {
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: true)
        let tabDown = CGEvent(keyboardEventSource: source, virtualKey: 0x30, keyDown: true)
        let tabUp = CGEvent(keyboardEventSource: source, virtualKey: 0x30, keyDown: false)
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: 0x37, keyDown: false)

        cmdDown?.flags = .maskCommand
        tabDown?.flags = .maskCommand
        tabUp?.flags = .maskCommand

        cmdDown?.post(tap: .cghidEventTap)
        tabDown?.post(tap: .cghidEventTap)
        tabUp?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }

    private func postSystemDefinedMediaKey(keyCode: Int32, keyDown: Bool) {
        let flags: NSEvent.ModifierFlags = keyDown ? .init(rawValue: 0xA00) : .init(rawValue: 0xB00)
        let data1 = Int((keyCode << 16) | ((keyDown ? 0xA : 0xB) << 8))
        guard let event = NSEvent.otherEvent(
            with: .systemDefined,
            location: .zero,
            modifierFlags: flags,
            timestamp: 0,
            windowNumber: 0,
            context: nil,
            subtype: 8,
            data1: data1,
            data2: -1
        ) else { return }

        event.cgEvent?.post(tap: .cghidEventTap)
    }

    private func runAppleScript(_ script: String) {
        var errorDict: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&errorDict)
        if let errorDict {
            print("AppleScript error: \(errorDict)")
        }
    }

    private func openYouTube() {
        let chromeID = "com.google.Chrome"
        let url = URL(string: "https://www.youtube.com")!

        if NSWorkspace.shared.urlForApplication(withBundleIdentifier: chromeID) != nil {
            let config = NSWorkspace.OpenConfiguration()
            if let chromeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: chromeID) {
                NSWorkspace.shared.open([url], withApplicationAt: chromeURL, configuration: config)
            } else {
                NSWorkspace.shared.open(url)
            }
        } else {
            NSWorkspace.shared.open(url)
        }
    }

    private func openApp(bundleIdentifier: String) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            print("App not found for bundle id: \(bundleIdentifier)")
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: appURL, configuration: config)
    }
}
