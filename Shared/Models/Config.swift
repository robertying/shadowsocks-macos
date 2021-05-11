import Foundation
import Network

struct Config: Codable {
  var localConfigs: [LocalConfig] = []
  var serverConfigs: [ServerConfig] = []
  var mode: Mode = Mode.tcp_only
  var noDelay: Bool = true
  var nofile: UInt = 65535
  var ipv6First: Bool = false

  enum CodingKeys: String, CodingKey {
    case localConfigs = "locals"
    case serverConfigs = "servers"
    case mode
    case noDelay = "no_delay"
    case nofile
    case ipv6First = "ipv6_first"
  }

  init() {
    self.localConfigs = [
      LocalConfig(proto: .socks, localAddress: "127.0.0.1", localPort: 1080),
      LocalConfig(proto: .http, localAddress: "127.0.0.1", localPort: 1090),
    ]
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    localConfigs = (try? container.decode([LocalConfig].self, forKey: .localConfigs)) ?? []
    serverConfigs = (try? container.decode([ServerConfig].self, forKey: .serverConfigs)) ?? []
    mode = (try? container.decode(Mode.self, forKey: .mode)) ?? Mode.tcp_only
    noDelay = (try? container.decode(Bool.self, forKey: .noDelay)) ?? true
    nofile = (try? container.decode(UInt.self, forKey: .nofile)) ?? 65535
    ipv6First = (try? container.decode(Bool.self, forKey: .ipv6First)) ?? false
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(localConfigs, forKey: .localConfigs)
    try container.encode(serverConfigs, forKey: .serverConfigs)
    try container.encode(mode, forKey: .mode)
    try container.encode(noDelay, forKey: .noDelay)
    try container.encode(nofile, forKey: .nofile)
    try container.encode(ipv6First, forKey: .ipv6First)
  }
}
