//
// MainWindowController.swift
// Icns Composer
// https://github.com/raphaelhanneken/icnscomposer
//

import Cocoa

/// Manages the MainWindow.xib.
class MainWindowController: NSWindowController, NSWindowDelegate {

    /// Handles creation of the .icns file.
    var iconset = Iconset()

    override var windowNibName: NSNib.Name {
        return NSNib.Name("MainWindow")
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        if let window = window {
            window.titleVisibility = .hidden
        }
    }

    /// Starts the export process for the current iconset.
    ///
    /// - parameter sender: NSToolbarItem that sent the export message.
    @IBAction func export(_: NSToolbarItem) {
        guard let window = window else {
            return
        }

        let dialog = NSSavePanel()
        dialog.allowedFileTypes = ["icns"]
        dialog.allowsOtherFileTypes = false
        dialog.beginSheetModal(for: window) { (result: NSApplication.ModalResponse) -> Void in
            if result != NSApplication.ModalResponse.OK {
                return
            }

            do {
                try self.iconset.writeToURL(dialog.url)
            } catch {
                let alert = NSAlert()
                alert.messageText = "Oh snap!"
                alert.informativeText = "Something went somewhere terribly wrong."
                alert.beginSheetModal(for: window, completionHandler: nil)
            }
        }
    }

    /// Gets called everytime a user drops an image onto a connected NSImageView.
    /// Resizes the dropped images to the appropriate size and adds them to the icon object.
    ///
    /// - parameter sender: The NSImageView that the images have been assigned to.
    @IBAction func resize(_ sender: NSImageView) {
        let img = IconImage(sender.image,
                            withSize: NSSize(width: Int(sender.tag / 2), height: Int(sender.tag / 2)),
                            andScale: .scale1x)

        let img2x = IconImage(sender.image,
                              withSize: NSSize(width: sender.tag, height: sender.tag),
                              andScale: .scale2x)

        if let filename1x = img?.filename, let filename2x = img2x?.filename {
            iconset[filename1x] = img
            iconset[filename2x] = img2x
        }
    }
}
