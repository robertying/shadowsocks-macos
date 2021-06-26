import Foundation

final class AclUpdater {
  private static let CDN_URL = URL(
    string: "https://cdn.jsdelivr.net/gh/robertying/shadowsocks-acl@main")!

  private static let aclFiles = [
    "chinadomainlist.acl", "chinaiplist.acl", "chinalist.acl", "gfwlist.acl", "lanlist.acl",
  ]

  static func copyAclFilesFromBundleToSupportFolder() {
    let fileManager = FileManager.default
    do {
      let dirContents = try fileManager.contentsOfDirectory(atPath: DirectoryHelper.aclFolder.path)
      for fileName in dirContents {
        let sourceURL = DirectoryHelper.aclFolder.appendingPathComponent(fileName)
        let destURL = DirectoryHelper.supportFolder.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: destURL.path) {
          return
        } else {
          do { try FileManager.default.copyItem(at: sourceURL, to: destURL) } catch {
            print("Can't copy bundled acl file.")
          }
        }
      }
      print("Copied bundled acl files.")
    } catch {
      fatalError("Can't find bundled acl folder.")
    }
  }

  private static var group: DispatchGroup = DispatchGroup()

  private static func downloadAclFilesToSupportFolder(_ url: URL) {
    let downloadTask = URLSession.shared.downloadTask(with: url) {
      urlOrNil, responseOrNil, errorOrNil in
      defer {
        AclUpdater.group.leave()
      }

      guard let fileURL = urlOrNil else {
        return
      }
      do {
        let savedURL = DirectoryHelper.supportFolder.appendingPathComponent(url.lastPathComponent)
        try? FileManager.default.removeItem(at: savedURL)
        try FileManager.default.moveItem(at: fileURL, to: savedURL)
      } catch {
        print("Failed to download acl file from \(url).")
      }
    }
    downloadTask.resume()
  }

  static var loading: Bool = false {
    didSet {
      NotificationCenter.default.post(
        name: Notification.AclUpdaterStatus,
        object: nil, userInfo: ["loading": loading])
    }
  }

  static func update() {
    loading = true
    print("Started acl file download.")

    for acl in aclFiles {
      group.enter()
      downloadAclFilesToSupportFolder(CDN_URL.appendingPathComponent(acl))
    }

    group.notify(queue: .main) {
      print("Downloaded all acl files.")
      loading = false
      ProcessRunner.start()
    }
  }
}
