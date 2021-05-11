import Foundation

final class ProcessRunner {
  #if arch(arm64)
    private static let arch = "arm64"
  #elseif arch(x86_64)
    private static let arch = "x86_64"
  #endif

  private static var binUrl: URL {
    guard let file = Bundle.main.url(forResource: "bin/\(arch)", withExtension: nil)
    else {
      fatalError("Couldn't find arch \(arch) in main bundle.")
    }
    return file
  }

  private static var sslocalUrl: URL {
    guard let file = Bundle.main.url(forResource: "bin/\(arch)/sslocal", withExtension: nil)
    else {
      fatalError("Couldn't find sslocal in main bundle.")
    }
    return file
  }

  private static var v2rayPluginUrl: URL {
    guard let file = Bundle.main.url(forResource: "bin/\(arch)/v2ray-plugin", withExtension: nil)
    else {
      fatalError("Couldn't find v2ray-plugin in main bundle.")
    }
    return file
  }

  private static var cacheFolder: URL {
    do {
      return try FileManager.default.url(
        for: .cachesDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false)
    } catch {
      fatalError("Can't find cache directory.")
    }
  }

  private static var pidFileUrl: URL {
    return cacheFolder.appendingPathComponent("sslocal.pid")
  }

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

  static func cleanup() {
    kill("sslocal")
    kill("v2ray-plugin")
  }

  static func start() {
    loading = true

    cleanup()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      task = Process()
      task.currentDirectoryURL = binUrl
      var environment = ProcessInfo.processInfo.environment
      environment["PATH"] =
        (environment["PATH"] ?? "") + ":\(v2rayPluginUrl.deletingLastPathComponent().path)"
      task.environment = environment
      task.executableURL = sslocalUrl
      task.arguments = ["-c", ConfigData.fileURL.path]

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
        print("CRIT: sslocal terminated.")
        NotificationCenter.default.removeObserver(terminateObserver!)
      }

      print("CRIT: sslocal starting.")
      defer {
        loading = false
      }
      do {
        try task.run()
        running = true
        print("CRIT: sslocal started.")
      } catch {
        running = false
        print("CRIT: sslocal failed to start.")
      }
    }
  }

  static func stop() {
    loading = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      print("CRIT: sslocal terminating.")
      task.terminate()
    }
  }
}
