import Foundation

enum KnockAction: String, CaseIterable, Identifiable {
    case playPause = "Play/Pause"
    case switchApp = "Switch App"
    case sleepMac = "Sleep Mac"
    case openYouTube = "Open YouTube"
    case openApplication = "Open Application"

    var id: String { rawValue }
}
