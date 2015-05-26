//
//  AppDelegate.swift
//  Icns Composer
//
//  Created by Raphael Hanneken on 17/05/15.
//  Copyright (c) 2015 Raphael Hanneken. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // Handle the window via MainWindowController.
    var mainWindowController: MainWindowController?


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Create a new WindowController instance.
        let mainWindowController = MainWindowController()
        
        // Display the associated window on screen.
        mainWindowController.showWindow(self)
        
        // Point the instance variable to the WindowController object.
        self.mainWindowController = mainWindowController
    }
    
    // Reopen mainWindow, when the user clicks on the dock icon.
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let mainWindowController = self.mainWindowController {
            mainWindowController.showWindow(self)
        }
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

