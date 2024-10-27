enum Plugin: String, CaseIterable, Identifiable, Codable {
    case v2ray_plugin = "v2ray-plugin"
    case none = ""

    var id: String { self.rawValue }
}
