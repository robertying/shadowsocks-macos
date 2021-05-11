import SwiftUI

@main
struct ShadowsocksApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  @StateObject private var configData = ConfigData()

  var body: some Scene {
    Settings {
      SettingsView().environmentObject(configData).onAppear {
        configData.load()
      }
    }
  }
}
