import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Enable Knock Detection", isOn: $model.isListening)

            Picker("Action", selection: $model.selectedAction) {
                ForEach(KnockAction.allCases) { action in
                    Text(action.rawValue).tag(action)
                }
            }

            if model.selectedAction == .openApplication {
                TextField("App bundle id (e.g., com.apple.Music)", text: $model.appBundleIdentifier)
                    .textFieldStyle(.roundedBorder)
            }

            Text(model.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text("Privacy: microphone processing happens locally in memory only.")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(14)
        .frame(width: 340)
    }
}
