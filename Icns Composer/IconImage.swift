//
// IconImage.swift
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

/// Defines the scale of an image.
///
/// - at1x: A Scale of @1x
/// - at2x: A Scale of @2x
/// - at3x: A Scale of @3x
enum ImageScale: String {
  case x1 = ""
  case x2 = "@2x"
}

/// Represents a single image of an iconset.
struct IconImage {
  /// Holds the image it represents.
  let image: NSImage?
  /// The image scale.
  let scale: ImageScale
  /// The images size.
  let size: NSSize

  var filename: String {
    switch scale {
    case .x1:
      return "icon_\(Int(size.width))x\(Int(size.height))\(scale.rawValue).png"
    case .x2:
      return "icon_\(Int(size.width / 2))x\(Int(size.height / 2))\(scale.rawValue).png"
    }
  }

  /// Initialize a new iconset image.
  init?(_ image: NSImage?, withSize size: NSSize, andScale scale: ImageScale) {
    guard let image = image else {
      return nil
    }
    // Resize the supplied image.
    self.image = image.copyWithSize(size)
    self.scale = scale
    self.size  = size
  }

  /// Write the iconset image to the supplied url.
  ///
  /// - parameter url: The url where to save the image.
  func writeToURL(_ url: URL) throws {
    // Define the image name.
    let imgURL = try url.appendingPathComponent(filename, isDirectory: false)

    // Get the png representation of the image and write it to the supplied url.
    if let png = image?.PNGRepresentation() {
      try png.write(to: imgURL, options: .atomic)
    }
  }
}
