import Combine
import Foundation

final class ConfigData: ObservableObject {
  private static var appName: String {
    Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
  }

  private static var supportFolder: URL {
    do {
      return try FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
      ).appendingPathComponent(appName)
    } catch {
      fatalError("Can't find documents directory.")
    }
  }

  private static var exampleConfigUrl: URL {
    guard let file = Bundle.main.url(forResource: "config.json", withExtension: nil)
    else {
      fatalError("Couldn't find example config file in main bundle.")
    }
    return file
  }

  static var fileURL: URL {
    return supportFolder.appendingPathComponent("config.json")
  }

  @Published var config: Config = Config()

  func load() {
    DispatchQueue.global(qos: .background).async { [weak self] in
      guard let data = try? Data(contentsOf: Self.fileURL) else {
        print("Can't find config file. Copying from bundle.")
        do {
          let fileManager = FileManager.default
          try fileManager.createDirectory(
            at: Self.supportFolder, withIntermediateDirectories: false, attributes: nil)
          try fileManager.copyItem(at: Self.exampleConfigUrl, to: Self.fileURL)
          print("Copied example config file to support directory.")
          self?.load()
        } catch {
          print("Unable to copy example config file.")
        }
        return
      }
      guard let config = try? JSONDecoder().decode(Config.self, from: data) else {
        fatalError("Can't decode saved config data.")
      }
      DispatchQueue.main.async {
        self?.config = config
        print("Config loaded from file.")
      }
    }
  }

  func save() {
    DispatchQueue.global(qos: .background).async { [weak self] in
      guard let config = self?.config else { fatalError("Self out of scope.") }
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      guard let data = try? encoder.encode(config) else {
        fatalError("Error encoding config data.")
      }
      do {
        let outfile = Self.fileURL
        try data.write(to: outfile)
        print("Config saved to file.")
      } catch {
        fatalError("Can't write config data to file.")
      }
    }
  }
}
