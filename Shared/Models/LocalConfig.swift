import Foundation
import Network

final class LocalConfig: Hashable, Codable, Identifiable, ObservableObject {
    @Published var proto: Protocol
    @Published var localAddress: String
    @Published var localPort: UInt16

    var id: String {
        return "\(localAddress):\(localPort)"
    }

    enum CodingKeys: String, CodingKey {
        case proto = "protocol"
        case localAddress = "local_address"
        case localPort = "local_port"
    }

    init(proto: Protocol, localAddress: String, localPort: UInt16) {
        self.proto = proto
        self.localAddress = localAddress
        self.localPort = localPort
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        proto =
            (try? container.decode(Protocol.self, forKey: .proto))
            ?? Protocol.socks
        localAddress =
            (try? container.decode(String.self, forKey: .localAddress))
            ?? "127.0.0.1"
        localPort =
            (try? container.decode(UInt16.self, forKey: .localPort)) ?? 1080
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(proto, forKey: .proto)
        try container.encode(localAddress, forKey: .localAddress)
        try container.encode(localPort, forKey: .localPort)
    }

    static func == (lhs: LocalConfig, rhs: LocalConfig) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
