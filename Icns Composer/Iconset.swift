//
//  Iconset.swift
//  Icns Composer
//
//  Created by Raphael Hanneken on 26/05/15.
//  Copyright (c) 2015 Raphael Hanneken. All rights reserved.
//

import Cocoa

class Iconset {
    
    /// Holds the necessary images to create an iconset that conforms iconutil
    var images: [String : NSImage] = [:]
    
    
    /**
     * Saves an *.icns file with images from self.images
     *
     * :param: url Path to the directory, where to save the icns file.
     */
    func saveIcnsToURL(url: NSURL?) {
        // Unwrap the given url.
        if let url = url {
            // Build the iconset.
            if self.writeIconsetToURL(url) {
                // Create the *.icns file.
                self.runIconUtilWithInputURL(url)
            }
            
            // Open the working directory.
            NSWorkspace.sharedWorkspace().openURL(url.URLByDeletingLastPathComponent!)
        }
    }
    
    /**
     * Adds an image to the images dictionary.
     *
     * :param: img  Image object to add to the array
     * :param: size Size of the given image, e.g. 512x512@2x
     */
    func addImage(img: NSImage, ofSize size: String) {
        self.images[size] = img
    }
    
    /**
     * Saves the resized images as *.iconsest to the given URL.
     *
     * :param: url Path to the directory, where to save the iconset.
     *
     * :returns: True on success
     */
    func writeIconsetToURL(url: NSURL) -> Bool {
        // Create the given directory, if not already existent.
        NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil, error: nil)
        
        // For each image in the dictionary...
        for (size, image) in self.images {
            // ...get a png representation, ...
            let pngRep = image.PNGRepresentation()
            
            // ...append the appropriate file name to the given url and...
            let url = url.URLByAppendingPathComponent("icon_\(size).png", isDirectory: false)
            
            // ...write the png file to the HD.
            pngRep.writeToURL(url, atomically: true)
        }
        
        return true
    }
    
    /**
     * Runs iconutil with the given url as input path.
     *
     * :param: url Path to a convertable iconset directory.
     */
    func runIconUtilWithInputURL(url: NSURL?) {
        // Unwrap the optional url.
        if let url = url {
            // Create a new task.
            let iconUtil = NSTask()
            
            // Get the last path component to use it as file name.
            let filename  = url.lastPathComponent!
            var outputURL = url.URLByDeletingLastPathComponent!
            
            // Remove the *.iconset extension...
            let icnsFile = filename.substringToIndex(advance(filename.endIndex, -8))
            // ...and append the new file to the new url object.
            let outputPath = "\(outputURL.path!)/\(icnsFile).icns"
            
            // Configure the NSTask and fire it up.
            iconUtil.launchPath = "/usr/bin/iconutil"
            iconUtil.arguments = ["-c", "icns", "-o", outputPath, "\(url.path!)"]
            iconUtil.launch()
            iconUtil.waitUntilExit()
            
            // Delete the .iconset
            NSFileManager.defaultManager().removeItemAtURL(url, error: nil)
        }
    }
}
