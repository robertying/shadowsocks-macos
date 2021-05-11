import LaunchAtLogin
import SwiftUI

struct AdvancedSettingsView: View {
  @EnvironmentObject var configData: ConfigData

  private let portTextFieldWidth: CGFloat = 60.0

  var socks5Config: Binding<LocalConfig> {
    set(newConfig) {
      if let index = configData.config.localConfigs.firstIndex(where: { $0.proto == .socks }) {
        configData.config.localConfigs[index] = newConfig.wrappedValue
      } else {
        configData.config.localConfigs.append(
          LocalConfig(proto: .socks, localAddress: "127.0.0.1", localPort: 1080))
      }
    }
    get {
      if let index = configData.config.localConfigs.firstIndex(where: { $0.proto == .socks }) {
        return $configData.config.localConfigs[index]
      } else {
        configData.config.localConfigs.append(
          LocalConfig(proto: .socks, localAddress: "127.0.0.1", localPort: 1080))
        return $configData.config.localConfigs[configData.config.localConfigs.count - 1]
      }
    }
  }

  var httpConfig: Binding<LocalConfig> {
    set(newConfig) {
      if let index = configData.config.localConfigs.firstIndex(where: { $0.proto == .http }) {
        configData.config.localConfigs[index] = newConfig.wrappedValue
      } else {
        configData.config.localConfigs.append(
          LocalConfig(proto: .http, localAddress: "127.0.0.1", localPort: 1090))
      }
    }
    get {
      if let index = configData.config.localConfigs.firstIndex(where: { $0.proto == .http }) {
        return $configData.config.localConfigs[index]
      } else {
        configData.config.localConfigs.append(
          LocalConfig(proto: .http, localAddress: "127.0.0.1", localPort: 1090))
        return $configData.config.localConfigs[configData.config.localConfigs.count - 1]
      }
    }
  }

  private func saveData() {
    configData.save()
  }

  var body: some View {
    GeometryReader { gp in
      VStack(alignment: .leading, spacing: 16) {
        LaunchAtLogin.Toggle {
          Text("Launch at Login")
        }
        VStack(alignment: .leading) {
          Text("SOCKS5 Proxy")
          HStack {
            TextField("Bind Host", text: socks5Config.localAddress)
            Text(":")
            TextField("Bind Port", value: socks5Config.localPort, formatter: NumberFormatter())
              .frame(width: portTextFieldWidth)
          }
        }
        VStack(alignment: .leading) {
          Text("HTTP Proxy")
          HStack {
            TextField("Bind Host", text: httpConfig.localAddress)
            Text(":")
            TextField("Bind Port", value: httpConfig.localPort, formatter: NumberFormatter())
              .frame(width: portTextFieldWidth)
          }
        }
        Toggle(
          "UDP",
          isOn: Binding<Bool>(
            get: { configData.config.mode == .tcp_and_udp },
            set: {
              if $0 {
                configData.config.mode = .tcp_and_udp
              } else {
                configData.config.mode = .tcp_only
              }
              saveData()
            }
          )
        )
        Toggle(
          "TCP_NODELAY",
          isOn: Binding<Bool>(
            get: { configData.config.noDelay },
            set: {
              configData.config.noDelay = $0
              saveData()
            }
          )
        )
        Toggle(
          "IPv6 First",
          isOn: Binding<Bool>(
            get: { configData.config.ipv6First },
            set: {
              configData.config.ipv6First = $0
              saveData()
            }
          )
        )
        HStack {
          Text("nofile")
          TextField("", value: $configData.config.nofile, formatter: NumberFormatter()).frame(
            width: portTextFieldWidth)
        }
      }.padding().frame(width: 300).position(x: gp.size.width / 2, y: gp.size.height / 2)
    }.contentShape(Rectangle()).onTapGesture {
      NSApp.keyWindow?.makeFirstResponder(nil)
      saveData()
    }
  }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    AdvancedSettingsView().environmentObject(ConfigData())
  }
}
