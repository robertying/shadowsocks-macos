enum ProxyType: String, CaseIterable, Identifiable, Codable {
  case bypass_china = "chinalist"
  case bypass_china_domains = "chinadomainlist"
  case bypass_china_ips = "chinaiplist"
  case bypass_lan = "lanlist"
  case proxy_gfw = "gfwlist"
  case manual = "manual"

  var id: String { self.rawValue }
}
