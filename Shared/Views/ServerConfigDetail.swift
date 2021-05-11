import SwiftUI

func ?? <T>(lhs: Binding<T?>, rhs: T) -> Binding<T> {
  Binding(
    get: { lhs.wrappedValue ?? rhs },
    set: { lhs.wrappedValue = $0 }
  )
}

private struct Label: View {
  var text: String
  var minWidth: CGFloat?

  var body: some View {
    Text(text).frame(minWidth: minWidth, alignment: .leading)
  }
}

struct ServerConfigDetail: View {
  @EnvironmentObject var config: ServerConfig
  @State private var showPassword = false

  let saveData: () -> Void

  private let labelWidth: CGFloat = 100.0

  private func save() {
    if !config.address.isEmpty {
      saveData()
    }
  }

  var body: some View {
    GeometryReader { gp in
      VStack {
        HStack {
          Label(text: "Remark", minWidth: labelWidth)
          TextField("", text: $config.remark ?? "").disableAutocorrection(true)
        }
        HStack {
          Label(text: "Server *", minWidth: labelWidth)
          TextField("IP / domain", text: $config.address).disableAutocorrection(true)
        }
        HStack {
          Label(text: "Port *", minWidth: labelWidth)
          TextField("1 - 65535", value: $config.port, formatter: NumberFormatter())
            .disableAutocorrection(true)
        }
        Picker(selection: $config.method, label: Label(text: "Method *", minWidth: labelWidth)) {
          Text("aes-256-gcm").tag(Method.aes_256_gcm)
          Text("aes-128-gcm").tag(Method.aes_128_gcm)
          Text("chacha20-ietf-poly1305").tag(Method.chacha20_ietf_poly1305)
          Text("plain").tag(Method.plain)
          Text("none").tag(Method.none)
        }
        HStack {
          Label(text: "Password *", minWidth: labelWidth)
          if showPassword {
            TextField("", text: $config.password).disableAutocorrection(true)
          } else {
            SecureField("", text: $config.password)
          }
          Button(
            action: {
              self.showPassword.toggle()
            },
            label: {
              Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
            })
        }
        Picker(selection: $config.plugin, label: Label(text: "Plugin", minWidth: labelWidth)) {
          Text("v2ray-plugin").tag(Plugin.v2ray_plugin)
          Text("none").tag(Plugin.none)
        }
        HStack {
          Label(text: "Plugin Options", minWidth: labelWidth)
          TextField("", text: $config.pluginOpts ?? "").disableAutocorrection(true)
        }
      }.textFieldStyle(RoundedBorderTextFieldStyle()).padding().frame(width: 350, height: 200)
        .position(x: gp.size.width / 2, y: gp.size.height / 2)
    }.contentShape(Rectangle()).onTapGesture {
      save()
    }
    .onDisappear {
      save()
    }
  }
}
