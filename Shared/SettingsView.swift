import SwiftUI

struct SettingsView: View {
  private enum Tabs: Hashable {
    case servers, advanced, about
  }

  var body: some View {
    TabView {
      ServerConfigView()
        .tabItem {
          Label("Servers", systemImage: "server.rack")
        }
        .tag(Tabs.servers)
      AdvancedSettingsView()
        .tabItem {
          Label("Advanced", systemImage: "gear")
        }
        .tag(Tabs.advanced)
      AboutView()
        .tabItem {
          Label("About", systemImage: "info.circle")
        }
        .tag(Tabs.about)
    }.frame(width: 600, height: 300)
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView().environmentObject(ConfigData())
  }
}
