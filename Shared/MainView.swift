import SwiftUI

struct MainView: View {
  let processRunning = NotificationCenter.default
    .publisher(for: Notification.ProcessRunningStatus)

  @State var loading: Bool = false
  @State var running: Bool = false

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
            Color(running ? .systemGreen : .systemOrange))
          Text(loading ? (running ? "Stopping" : "Starting") : (running ? "Running" : "Stopped"))
        }
        HStack {
          Button(
            action: {
              ProcessRunner.start()
            },
            label: {
              Text("Start").frame(width: gp.size.width * 5 / 12)
            }
          ).disabled(running || loading)
          Button(
            action: {
              ProcessRunner.stop()
            },
            label: {
              Text("Stop").frame(width: gp.size.width * 2 / 12)
            }
          ).disabled(!running || loading)
        }.padding(.top, 8)
        Spacer()
        VStack {
          Button(
            action: {
              NSApp.activate(ignoringOtherApps: true)
              NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
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
        self.running = ProcessRunner.running
        self.loading = ProcessRunner.loading
      }.onReceive(processRunning) { (obj) in
        if let userInfo = obj.userInfo, let running = userInfo["running"],
          let loading = userInfo["loading"]
        {
          self.running = running as! Bool
          self.loading = loading as! Bool
        }
      }.position(x: gp.size.width / 2, y: gp.size.height / 2)
    }
  }
}

extension Notification {
  static let ProcessRunningStatus = Notification.Name("ProcessRunningStatus")
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView().frame(width: 250, height: 200)
  }
}
