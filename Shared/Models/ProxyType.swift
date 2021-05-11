enum ProxyType: String, CaseIterable, Identifiable, Codable {
  case manual = "manual"
  case off = "off"

  var id: String { self.rawValue }
}
