//
// MainWindowController.swift
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

/// Manages the MainWindow.xib.
class MainWindowController: NSWindowController, NSWindowDelegate {

  /// Handles the icon creation process.
  var iconset = Iconset()

  override var windowNibName: String? {
    return "MainWindow"
  }

  override func windowDidLoad() {
    super.windowDidLoad()
    // Hide the title's visibility to get the unified toolbar.
    if let window = window {
      window.titleVisibility = .hidden
    }
  }

  // MARK: - Actions

  /// Start the export process for the current iconset.
  ///
  /// - parameter sender: NSToolbarItem that sent the message.
  @IBAction func export(_ sender: NSToolbarItem) {
    guard let window = window else {
      return
    }
    // Create and configure a new NSSavePanel.
    let dialog = NSSavePanel()
    dialog.allowedFileTypes = ["icns"]
    dialog.allowsOtherFileTypes = false

    // Display the save dialog.
    dialog.beginSheetModal(for: window) { (result: Int) -> Void in
      if result == NSFileHandlingPanelOKButton {
        do {
          try self.iconset.writeToURL(dialog.url)
        } catch {
          // Create an alert to inform the user something went terribly wrong.
          let alert = NSAlert()

          alert.messageText     = "This should not have happened!"
          alert.informativeText = "The icns file could not be saved due to a critical error."
          alert.beginSheetModal(for: window, completionHandler: nil)

          print(error)
        }
      }
    }
  }

  /// Gets called everytime a user drops an image onto a connected NSImageView.
  /// Resizes the dropped images to the appropriate size and adds them to the icon object.
  ///
  /// - parameter sender: An NSImageView
  @IBAction func resize(_ sender: NSImageView) {
    // Create a new image scaled @1x
    let img = IconImage(sender.image, withSize: NSSize(width: sender.tag / 2, height: sender.tag / 2), andScale: .x1)
    // Create a new image scaled @2x
    let img2x = IconImage(sender.image, withSize: NSSize(width: sender.tag, height: sender.tag), andScale: .x2)
    // Add the generated images to the iconset.
    if let filename1x = img?.filename, let filename2x = img2x?.filename {
      iconset[filename1x] = img
      iconset[filename2x] = img
    }
  }
}
