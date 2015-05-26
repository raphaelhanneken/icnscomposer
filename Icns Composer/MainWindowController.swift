//
//  MainWindowController.swift
//  Icns Composer
//
//  Created by Raphael Hanneken on 17/05/15.
//  Copyright (c) 2015 Raphael Hanneken. All rights reserved.
//

import Cocoa

class MainWindowController : NSWindowController, NSWindowDelegate {
    
    override var windowNibName : String? {
        return "MainWindow"
    }
   
    @IBOutlet weak var  image1024: NSImageView!       /// Holds the 1024x1024px image
    @IBOutlet weak var   image512: NSImageView!       /// Holds the 512x512px image
    @IBOutlet weak var   image256: NSImageView!       /// Holds the 256x256px image
    @IBOutlet weak var   image128: NSImageView!       /// Holds the 64x63px image
    @IBOutlet weak var    image64: NSImageView!       /// Holds the 32x32px image
    
    /// Handles the icon creation process.
    let icon = Iconset()
    
    
    // override windowDidLoad() to hide the window title.
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // To display the unified toolbar, hide the window title.
        window!.titleVisibility = .Hidden
    }
    
    
    
    // MARK: - Actions
    
    /**
     * Gets called everytime the user clicks 'Export'.
     * Opens an NSSavePanel, to let the user choose, where to save the icns file.
     *
     * :param: sender An NSToolbarItem
     */
    @IBAction func export(sender: NSToolbarItem) {
        // Create a new NSSavePanel instance...
        let dialog = NSSavePanel()
        
        // ...and open it on top of the main window.
        dialog.beginSheetModalForWindow(self.window!) { (result: Int) -> Void in
            // Did the user choose a directory?
            if result == NSFileHandlingPanelOKButton {
                // Save the iconset to the HD.
                self.icon.saveIcnsToURL(dialog.URL?.URLByAppendingPathExtension("iconset"))
            }
        }
    }
    
    /**
     * Gets called everytime a user dropps an image onto a connected NSImageView.
     * Resizes the dropped images to the appropriate size and adds them to the icon object.
     *
     * :param: sender An NSImageView
     */
    @IBAction func resize(sender: NSImageView) {
        // Unwrap the given image object.
        if let img = sender.image {
            switch sender.tag {
                case 1024:
                    // Resize image to the appropriate size...
                    image1024.image = img.copyWithSize(width: 1024, height: 1024)
                    
                    // ...and add it to the icon object.
                    self.icon.addImage(self.image1024.image!, ofSize: "512x512@2x")
                    self.icon.addImage(img.copyWithSize(width: 512, height: 512)!, ofSize: "512x512")
                
                case 512:
                    // Resize image to the appropriate size...
                    image512.image = img.copyWithSize(width: 512, height: 512)
                    
                    // ...and add it to the icon object.
                    self.icon.addImage(self.image512.image!, ofSize: "256x256@2x")
                    self.icon.addImage(img.copyWithSize(width: 256, height: 256)!, ofSize: "256x256")
                    
                case 256:
                    // Resize image to the appropriate size...
                    image256.image = img.copyWithSize(width: 256, height: 256)
                    
                    // ...and add it to the icon object.
                    self.icon.addImage(self.image256.image!, ofSize: "128x128@2x")
                    self.icon.addImage(img.copyWithSize(width: 128, height: 128)!, ofSize: "128x128")
                    
                case 64:
                    // Resize image to the appropriate size...
                    image128.image = img.copyWithSize(width: 64, height: 64)
                    
                    // ...and add it to the icon object.
                    self.icon.addImage(self.image128.image!, ofSize: "32x32@2x")
                    self.icon.addImage(img.copyWithSize(width: 32, height: 32)!, ofSize: "64x64")
                    
                case 32:
                    // Resize image to the appropriate size...
                    image64.image = img.copyWithSize(width: 32, height: 32)
                    
                    // ...and add it to the icon object.
                    self.icon.addImage(self.image64.image!, ofSize: "16x16@2x")
                    self.icon.addImage(img.copyWithSize(width: 16, height: 16)!, ofSize: "16x16")
                    
                default:
                    // Nothing to do here. *flies away*
                    return
            }
        }
    }
}
