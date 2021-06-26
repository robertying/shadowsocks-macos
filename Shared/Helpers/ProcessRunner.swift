import Foundation

final class ProcessRunner {
  private static var task: Process!

  static var loading: Bool = false {
    didSet {
      NotificationCenter.default.post(
        name: Notification.ProcessRunningStatus,
        object: nil, userInfo: ["running": running, "loading": loading])
    }
  }

  static var running: Bool = false {
    didSet {
      NotificationCenter.default.post(
        name: Notification.ProcessRunningStatus,
        object: nil, userInfo: ["running": running, "loading": loading])
    }
  }

  private static func kill(_ name: String) {
    let killTask = Process()
    killTask.launchPath = "/usr/bin/pkill"
    killTask.arguments = ["-x", name]

    var terminateObserver: NSObjectProtocol!
    terminateObserver = NotificationCenter.default.addObserver(
      forName: Process.didTerminateNotification, object: killTask, queue: nil
    ) { notification in
      print("CRIT: \(name) killed.")
      NotificationCenter.default.removeObserver(terminateObserver!)
    }

    try? killTask.run()
  }

  private static let configData = ConfigData()

  private static func unsetProxy() {
    let proxyTask = Process()
    proxyTask.launchPath =
      DirectoryHelper.binRootFolder.appendingPathComponent("networksetup.sh").path
    proxyTask.arguments = ["unset"]

    var terminateObserver: NSObjectProtocol!
    terminateObserver = NotificationCenter.default.addObserver(
      forName: Process.didTerminateNotification, object: proxyTask, queue: nil
    ) { notification in
      print("CRIT: system proxy unset.")
      NotificationCenter.default.removeObserver(terminateObserver!)
    }

    try? proxyTask.run()
  }

  private static func setProxy() {
    let proxyType =
      UserDefaults.standard.string(forKey: "proxyType") ?? ProxyType.bypass_china_ips.rawValue
    if proxyType == ProxyType.manual.rawValue {
      return
    }

    configData.load(
      onLoad: {
        let proxyTask = Process()
        proxyTask.launchPath =
          DirectoryHelper.binRootFolder.appendingPathComponent("networksetup.sh").path

        let httpConfig = configData.config.localConfigs.filter { $0.proto == .http }[0]
        proxyTask.arguments = ["set", httpConfig.localAddress, String(httpConfig.localPort)]

        var terminateObserver: NSObjectProtocol!
        terminateObserver = NotificationCenter.default.addObserver(
          forName: Process.didTerminateNotification, object: proxyTask, queue: nil
        ) { notification in
          print("CRIT: system proxy set.")
          NotificationCenter.default.removeObserver(terminateObserver!)
        }

        try? proxyTask.run()
      },
      onError: {
        unsetProxy()
      })
  }

  static func cleanup() {
    unsetProxy()
    kill("sslocal")
    kill("v2ray-plugin")
  }

  static func start() {
    loading = true

    cleanup()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      task = Process()
      task.currentDirectoryURL = DirectoryHelper.binFolder
      var environment = ProcessInfo.processInfo.environment
      environment["PATH"] =
        (environment["PATH"] ?? "")
        + ":\(DirectoryHelper.v2rayPluginUrl.deletingLastPathComponent().path)"
      task.environment = environment
      task.executableURL = DirectoryHelper.sslocalUrl

      let proxyType =
        UserDefaults.standard.string(forKey: "proxyType") ?? ProxyType.bypass_china_ips.rawValue
      if proxyType == ProxyType.manual.rawValue {
        task.arguments = ["-c", ConfigData.fileURL.path]
      } else {
        let aclUrl = DirectoryHelper.supportFolder.appendingPathComponent(proxyType)
          .appendingPathExtension("acl")
        task.arguments = ["-c", ConfigData.fileURL.path, "--acl", aclUrl.path]
      }

      let outputPipe = Pipe()
      let errorPipe = Pipe()
      task.standardOutput = outputPipe
      task.standardError = errorPipe
      let outputHandle = outputPipe.fileHandleForReading
      outputHandle.waitForDataInBackgroundAndNotify()
      let errorHandle = errorPipe.fileHandleForReading
      errorHandle.waitForDataInBackgroundAndNotify()

      var outputObserver: NSObjectProtocol!
      outputObserver = NotificationCenter.default.addObserver(
        forName: .NSFileHandleDataAvailable, object: outputHandle, queue: nil
      ) { notification in
        let data = outputHandle.availableData
        if data.count > 0 {
          print("Log: \(String(decoding: data, as: UTF8.self))")
          outputHandle.waitForDataInBackgroundAndNotify()
        } else {
          NotificationCenter.default.removeObserver(outputObserver!)
        }
      }

      var errorObserver: NSObjectProtocol!
      errorObserver = NotificationCenter.default.addObserver(
        forName: .NSFileHandleDataAvailable, object: errorHandle, queue: nil
      ) { notification in
        let data = errorHandle.availableData
        if data.count > 0 {
          print(String(decoding: data, as: UTF8.self))
          errorHandle.waitForDataInBackgroundAndNotify()
        } else {
          NotificationCenter.default.removeObserver(errorObserver!)
        }
      }

      var terminateObserver: NSObjectProtocol!
      terminateObserver = NotificationCenter.default.addObserver(
        forName: Process.didTerminateNotification, object: task, queue: nil
      ) { notification in
        running = false
        loading = false
        NotificationCenter.default.removeObserver(terminateObserver!)
        print("CRIT: sslocal terminated.")
      }

      print("CRIT: sslocal starting.")
      defer {
        loading = false
      }
      do {
        try task.run()
        running = true
        print("CRIT: sslocal started.")
        setProxy()
      } catch {
        running = false
        print("CRIT: sslocal failed to start.")
      }
    }
  }

  static func stop() {
    loading = true
    unsetProxy()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      print("CRIT: sslocal terminating.")
      task.terminate()
    }
  }
}
