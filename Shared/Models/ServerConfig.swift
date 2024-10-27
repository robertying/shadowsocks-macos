import Foundation
import Network

final class ServerConfig: Hashable, Codable, Identifiable, ObservableObject {
    var id: UUID
    @Published var remark: String?
    @Published var address: String
    @Published var port: UInt16
    @Published var method: Method
    @Published var password: String
    @Published var plugin: Plugin
    @Published var pluginOpts: String?
    @Published var disabled: Bool

    var isIpv6: Bool {
        let addr = IPv6Address(address)
        if addr != nil {
            return true
        } else {
            return false
        }
    }

    enum CodingKeys: String, CodingKey {
        case remark, address, port, method, password, plugin
        case pluginOpts = "plugin_opts"
        case disabled
    }

    init() {
        id = UUID()
        address = ""
        port = 443
        method = Method.aes_128_gcm
        password = ""
        plugin = Plugin.v2ray_plugin
        pluginOpts = "tls;host=www.example.com"
        disabled = false
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = UUID()
        remark = try? container.decode(String.self, forKey: .remark)
        address = (try? container.decode(String.self, forKey: .address)) ?? ""
        port = (try? container.decode(UInt16.self, forKey: .port)) ?? 443
        method =
            (try? container.decode(Method.self, forKey: .method))
            ?? Method.aes_128_gcm
        password = (try? container.decode(String.self, forKey: .password)) ?? ""
        plugin =
            (try? container.decode(Plugin.self, forKey: .plugin))
            ?? Plugin.v2ray_plugin
        pluginOpts =
            (try? container.decode(String.self, forKey: .pluginOpts))
            ?? "tls;host=www.example.com"
        disabled =
            (try? container.decode(Bool.self, forKey: .disabled)) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if remark != nil {
            try container.encode(remark, forKey: .remark)
        }
        try container.encode(address, forKey: .address)
        try container.encode(port, forKey: .port)
        try container.encode(method, forKey: .method)
        try container.encode(password, forKey: .password)
        if plugin != .none {
            try container.encode(plugin, forKey: .plugin)
            try container.encode(pluginOpts ?? "", forKey: .pluginOpts)
        }
        try container.encode(disabled, forKey: .disabled)
    }

    static func == (lhs: ServerConfig, rhs: ServerConfig) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
