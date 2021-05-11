enum Protocol: String, CaseIterable, Identifiable, Codable {
  case socks = "socks"
  case http = "http"

  var id: String { self.rawValue }
}
