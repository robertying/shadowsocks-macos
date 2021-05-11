import SwiftUI

struct ServerConfigRow: View {
  @EnvironmentObject var config: ServerConfig

  let saveData: () -> Void

  var body: some View {
    HStack {
      Toggle(
        isOn: Binding<Bool>(
          get: { !config.disabled },
          set: {
            config.disabled = !$0
            if !config.address.isEmpty {
              saveData()
            }
          }
        )
      ) {
        EmptyView()
      }.toggleStyle(CheckboxToggleStyle()).help(config.disabled ? "Disabled" : "Enabled")
      if !(config.remark ?? "").isEmpty {
        Text(config.remark!)
      } else if config.address == "" {
        Text("New Config")
      } else {
        Text(
          config.isIpv6
            ? "[\(config.address)]:\(config.port)" : "\(config.address):\(config.port)"
        ).truncationMode(.middle)
      }
    }
  }
}
