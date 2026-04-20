import SwiftUI

@main
struct KnockDeskApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        MenuBarExtra("KnockDesk", systemImage: appModel.isListening ? "waveform" : "waveform.slash") {
            ContentView()
                .environmentObject(appModel)
        }
        .menuBarExtraStyle(.window)
    }
}
