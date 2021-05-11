import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var statusBarItem: NSStatusItem!
  var menu: NSMenu!

  func applicationDidFinishLaunching(_ notification: Notification) {
    let mainView = MainView()
    let view = NSHostingView(rootView: mainView)
    view.frame = NSRect(x: 0, y: 0, width: 250, height: 200)

    let menuItem = NSMenuItem()
    menuItem.view = view

    let menu = NSMenu()
    menu.addItem(menuItem)

    self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    self.statusBarItem.menu = menu

    let statusBarIcon = NSImage(named: NSImage.Name("StatusBarIcon"))!
    self.statusBarItem.button?.image = statusBarIcon

    ProcessRunner.start()
  }

  func applicationWillTerminate(_ notification: Notification) {
    ProcessRunner.cleanup()
  }
}
