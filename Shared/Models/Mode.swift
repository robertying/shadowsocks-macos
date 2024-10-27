enum Mode: String, CaseIterable, Identifiable, Codable {
    case tcp_only = "tcp_only"
    case tcp_and_udp = "tcp_and_udp"

    var id: String { self.rawValue }
}
