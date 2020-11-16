//
// AppDelegate.swift
// Icns Composer
// https://github.com/raphaelhanneken/icnscomposer
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindowController: MainWindowController?

    func applicationDidFinishLaunching(_: Notification) {
        let mainWindowController = MainWindowController()
        mainWindowController.showWindow(self)

        self.mainWindowController = mainWindowController
    }

    // Reopen mainWindow, when the user clicks on the dock icon.
    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        if let mainWindowController = self.mainWindowController {
            mainWindowController.showWindow(self)
        }
        return true
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
