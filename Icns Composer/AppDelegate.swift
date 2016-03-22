//
// AppDelegate.swift
// Icns Composer
// https://github.com/raphaelhanneken/icnscomposer
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Raphael Hanneken
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  /// Handle the window via MainWindowController.
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
  func applicationShouldHandleReopen(sender: NSApplication,
                                     hasVisibleWindows flag: Bool) -> Bool {
    if let mainWindowController = self.mainWindowController {
      mainWindowController.showWindow(self)
    }
    return true
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
}
