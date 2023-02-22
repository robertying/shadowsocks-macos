import SwiftUI

struct MainView: View {
  @AppStorage("proxyType") var proxyType: ProxyType = ProxyType.bypass_china_ips

  @State var processLoading: Bool = false
  @State var processRunning: Bool = false
  @State var aclUpdaterLoading: Bool = false

  let processStatusPublisher = NotificationCenter.default
    .publisher(for: Notification.ProcessRunningStatus)
  let aclUpdaterStatusPublisher = NotificationCenter.default
    .publisher(for: Notification.AclUpdaterStatus)

  var body: some View {
    GeometryReader { gp in
      VStack {
        HStack {
          Image("MonoIcon").renderingMode(.template)
            .resizable().frame(width: 32, height: 32).colorMultiply(.primary)
          Text("Shadowsocks").font(.title)
        }
        HStack {
          Image(systemName: "circle.fill").foregroundColor(
            Color(processRunning ? .systemGreen : .systemOrange))
          Text(
            processLoading
              ? (processRunning ? "Stopping" : "Starting")
              : (processRunning ? "Running" : "Stopped"))
        }
        HStack {
          Button(
            action: {
              ProcessRunner.start()
            },
            label: {
              Text("Start").frame(width: gp.size.width * 5 / 12)
            }
          ).disabled(processRunning || processLoading)
          Button(
            action: {
              ProcessRunner.stop()
            },
            label: {
              Text("Stop").frame(width: gp.size.width * 2 / 12)
            }
          ).disabled(!processRunning || processLoading)
        }.padding(.top, 8)
        Picker(
          "",
          selection: Binding<ProxyType>(
            get: { proxyType },
            set: {
              proxyType = $0
              ProcessRunner.start()
            }
          )
        ) {
          Text("Bypass China").tag(ProxyType.bypass_china_ips)
          Text("Proxy GFW").tag(ProxyType.proxy_gfw)
          Text("Manual").tag(ProxyType.manual)
        }.pickerStyle(SegmentedPickerStyle())
        Spacer()
        VStack {
          Button(
            action: {
              AclUpdater.update()
            },
            label: {
              Text("Update ACLs").frame(width: gp.size.width * 8 / 12)
            }
          ).disabled(aclUpdaterLoading)
          Button(
            action: {
              NSApp.activate(ignoringOtherApps: true)
              if #available(macOS 13, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
              } else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
              }
            },
            label: {
              Text("Open Settings").frame(width: gp.size.width * 8 / 12)
            })
          Button(
            action: {
              NSApp.terminate(self)
            },
            label: {
              Text("Quit").frame(width: gp.size.width * 8 / 12)
            })
        }
      }.padding().onAppear {
        self.processRunning = ProcessRunner.running
        self.processLoading = ProcessRunner.loading
      }.onReceive(processStatusPublisher) { (obj) in
        if let userInfo = obj.userInfo, let running = userInfo["running"],
          let loading = userInfo["loading"]
        {
          self.processRunning = running as! Bool
          self.processLoading = loading as! Bool
        }
      }.onReceive(aclUpdaterStatusPublisher) { (obj) in
        if let userInfo = obj.userInfo,
          let loading = userInfo["loading"]
        {
          self.aclUpdaterLoading = loading as! Bool
        }
      }.position(x: gp.size.width / 2, y: gp.size.height / 2)
    }
  }
}

extension Notification {
  static let ProcessRunningStatus = Notification.Name("ProcessRunningStatus")
  static let AclUpdaterStatus = Notification.Name("AclUpdaterStatus")
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView().frame(width: 300, height: 250)
  }
}
