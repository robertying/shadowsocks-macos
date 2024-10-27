import SwiftUI

struct ServerConfigView: View {
    @EnvironmentObject var configData: ConfigData
    @State private var selectedConfig: ServerConfig?
    @State private var hasOpened: Bool = false

    var window: NSWindow? {
        NSApplication.shared.windows.last
    }

    private var index: Int? {
        configData.config.serverConfigs.firstIndex(where: {
            $0.id == selectedConfig?.id
        })
    }

    private var editingNewConfig: Bool {
        configData.config.serverConfigs.contains(where: { $0.address.isEmpty })
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Menu {
                        Button(action: {
                            let newConfig = ServerConfig()
                            configData.config.serverConfigs.append(newConfig)
                            selectedConfig = newConfig
                        }) {
                            Text("Edit Manually")
                        }
                    } label: {
                        Image(systemName: "plus")
                        Text("Add")
                    }.disabled(editingNewConfig)
                    Button(action: {
                        if index != nil {
                            configData.config.serverConfigs.remove(at: index!)
                        }
                        configData.save()
                    }) {
                        Image(systemName: "minus")
                    }.disabled(index == nil)
                }.padding(.horizontal).padding(.top, 8)

                List(selection: $selectedConfig) {
                    ForEach(configData.config.serverConfigs) { config in
                        NavigationLink(
                            destination: ServerConfigDetail(saveData: {
                                configData.save()
                            }).environmentObject(config)
                        ) {
                            ServerConfigRow(saveData: {
                                configData.save()
                            }).environmentObject(config)
                        }
                        .tag(config)
                    }
                }
            }

            Text("Select a configuration").padding()
        }.onReceive(
            NotificationCenter.default
                .publisher(for: NSWindow.willCloseNotification, object: window)
        ) { _ in
            if hasOpened {
                configData.save()
                ProcessRunner.start()
            }

            hasOpened = true
        }
    }
}
