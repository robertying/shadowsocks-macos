import Foundation

final class DirectoryHelper {
  #if arch(arm64)
    private static let arch = "arm64"
  #elseif arch(x86_64)
    private static let arch = "x86_64"
  #endif

  private static var appName: String {
    Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
  }

  static var supportFolder: URL {
    do {
      return try FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
      ).appendingPathComponent(appName)
    } catch {
      fatalError("Can't find support directory.")
    }
  }

  static var aclFolder: URL {
    guard let file = Bundle.main.url(forResource: "acl", withExtension: nil)
    else {
      fatalError("Couldn't find acl folder in main bundle.")
    }
    return file
  }

  static var binFolder: URL {
    guard let file = Bundle.main.url(forResource: "bin/\(arch)", withExtension: nil)
    else {
      fatalError("Couldn't find arch \(arch) in main bundle.")
    }
    return file
  }

  static var binRootFolder: URL {
    guard let file = Bundle.main.url(forResource: "bin", withExtension: nil)
    else {
      fatalError("Couldn't find bin folder in main bundle.")
    }
    return file
  }

  static var sslocalUrl: URL {
    guard let file = Bundle.main.url(forResource: "bin/\(arch)/sslocal", withExtension: nil)
    else {
      fatalError("Couldn't find sslocal in main bundle.")
    }
    return file
  }

  static var v2rayPluginUrl: URL {
    guard let file = Bundle.main.url(forResource: "bin/\(arch)/v2ray-plugin", withExtension: nil)
    else {
      fatalError("Couldn't find v2ray-plugin in main bundle.")
    }
    return file
  }

  static var cacheFolder: URL {
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

  static var pidFileUrl: URL {
    return cacheFolder.appendingPathComponent("sslocal.pid")
  }
}
