import SwiftUI

struct AboutView: View {
  var body: some View {
    VStack(spacing: 16) {
      VStack(spacing: 0) {
        Image("RoundedIcon").resizable().frame(width: 64, height: 64)
        Text("Shadowsocks").font(.title)
      }
      Text(
        "Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) (Build \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String))"
      )
      Text("© 2021 Rui Ying")
    }.padding()
  }
}

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView().frame(width: 600, height: 300)
  }
}
