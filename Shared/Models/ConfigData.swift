import Combine
import Foundation

final class ConfigData: ObservableObject {
  private static var exampleConfigUrl: URL {
    guard let file = Bundle.main.url(forResource: "config.json", withExtension: nil)
    else {
      fatalError("Couldn't find example config file in main bundle.")
    }
    return file
  }

  static var fileURL: URL {
    return DirectoryHelper.supportFolder.appendingPathComponent("config.json")
  }

  @Published var config: Config = Config()

  func load(onLoad: (() -> Void)? = nil, onError: (() -> Void)? = nil) {
    DispatchQueue.global(qos: .background).async { [weak self] in
      guard let data = try? Data(contentsOf: Self.fileURL) else {
        print("Can't find config file. Copying from bundle.")
        do {
          let fileManager = FileManager.default
          try fileManager.createDirectory(
            at: DirectoryHelper.supportFolder, withIntermediateDirectories: false, attributes: nil)
          try fileManager.copyItem(at: Self.exampleConfigUrl, to: Self.fileURL)
          print("Copied example config file to support directory.")
          self?.load(onLoad: onLoad, onError: onError)
        } catch {
          print("Unable to copy example config file.")
          onError?()
        }
        return
      }
      guard let config = try? JSONDecoder().decode(Config.self, from: data) else {
        onError?()
        fatalError("Can't decode saved config data.")
      }
      DispatchQueue.main.async {
        self?.config = config
        print("Config loaded from file.")
        onLoad?()
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
