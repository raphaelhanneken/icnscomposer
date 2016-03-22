//
// Iconset.swift
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


enum IconsetError: ErrorType {
  case MissingURL
}


class Iconset {

  /// Holds the necessary images to create an iconset that conforms iconutil
  var images: [String : NSImage] = [:]


  /// Adds an image to the images dictionary.
  ///
  /// - parameter img:  Image object to add to the array
  /// - parameter size: Size of the given image, e.g. 512x512@2x
  func addImage(img: NSImage, ofSize size: String) {
    images[size] = img
  }

  ///  Saves an icns file to the supplied url.
  ///
  ///  - parameter url: URL to save the icns file to.
  ///  - throws: A MissingURL error, when the supplied url cant be unwrapped.
  func saveIcnsToURL(url: NSURL?) throws {
    // Unwrap the given url.
    guard let url = url else {
      throw IconsetError.MissingURL
    }

    // Get the temporary directory for the current user and
    // append the choosen iconset name + .iconset
    let tmpURL = NSURL(fileURLWithPath:
      NSTemporaryDirectory() + url.lastPathComponent! + ".iconset", isDirectory: true)

    // Build the iconset.
    try writeIconsetToURL(tmpURL)

    // Create the *.icns file.
    try runIconUtilWithInput(tmpURL, andOutputURL: url)

    // Open the working directory.
    NSWorkspace.sharedWorkspace().openURL(url.URLByDeletingLastPathComponent!)
  }


  ///  Saves the resized images as iconset to the supplied URL.
  ///
  ///  - parameter url: Path the location where to save the iconset.
  ///  - throws: A MissingURL error, in case the supplied url cant be unwrapped.
  func writeIconsetToURL(url: NSURL?) throws {
    // Unwrap the given url.
    guard let url = url else {
      throw IconsetError.MissingURL
    }

    // Create the iconset directory, if not already existent.
    try NSFileManager.defaultManager().createDirectoryAtURL(url,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)

    // For each image in the dictionary...
    for (size, image) in images {
      // ...append the appropriate file name to the given url,...
      let imgURL = url.URLByAppendingPathComponent("icon_\(size).png", isDirectory: false)

      // ...create a png representation and...
      guard let png = image.PNGRepresentation() else {
        continue
      }

      // ...write the png file to the HD.
      try png.writeToURL(imgURL, options: .DataWritingAtomic)
    }
  }


  ///  Executes iconutil with the given url as input path.
  ///
  ///  - parameter input:  Path to a convertable iconset directory.
  ///  - parameter output: Path to the location, where to save the generated icns file.
  ///
  ///  - throws: Throws a MissingURL error, in case one of the supplied urls cant be unwrapped.
  func runIconUtilWithInput(input: NSURL?, andOutputURL output: NSURL?) throws {
    // Unwrap the optional url.
    guard let input = input, output = output else {
      throw IconsetError.MissingURL
    }

    // Create a new task.
    let iconUtil = NSTask()

    // Append the .icns file extension to the output path.
    let outputURL = output.URLByAppendingPathExtension("icns")

    // Configure the NSTask and fire it up.
    iconUtil.launchPath = "/usr/bin/iconutil"
    iconUtil.arguments  = ["-c", "icns", "-o", outputURL.path!, input.path!]
    iconUtil.launch()
    iconUtil.waitUntilExit()

    // Delete the .iconset
    try NSFileManager.defaultManager().removeItemAtURL(input)
  }
}
