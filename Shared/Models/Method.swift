enum Method: String, CaseIterable, Identifiable, Codable {
  case aes_256_gcm = "aes-256-gcm"
  case aes_128_gcm = "aes-128-gcm"
  case chacha20_ietf_poly1305 = "chacha20-ietf-poly1305"
  case plain = "plain"
  case none = "none"

  var id: String { self.rawValue }
}
