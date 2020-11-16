//
// IconImage.swift
// Icns Composer
// https://github.com/raphaelhanneken/icnscomposer
//

import Cocoa

/// The scales of an icon image.
///
/// - scale1x: An image scale of @1x
/// - scale2x: An image scale of @2x
enum ImageScale: String {
    case scale1x = "@1x"
    case scale2x = "@2x"
}

struct IconImage {

    /// The image object.
    let image: NSImage?

    /// The scale of the image object.
    let scale: ImageScale

    /// The images size.
    let size: NSSize

    /// The filename of the icon image based on it's size and scale, e.g. icon_32x32@2x.png
    var filename: String {
        switch scale {
        case .scale1x:
            return "icon_\(Int(size.width))x\(Int(size.height))\(scale.rawValue).png"
        case .scale2x:
            return "icon_\(Int(size.width / 2))x\(Int(size.height / 2))\(scale.rawValue).png"
        }
    }

    /// Initializes a new iconset image.
    ///
    /// - parameter image: The NSImage object, the IconImage should.
    /// - parameter size: The NSSize the supplied image should be resized to.
    /// - parameter scale: The scale type of the image.
    init?(_ image: NSImage?, withSize size: NSSize, andScale scale: ImageScale) {
        guard let image = image else {
            return nil
        }

        self.image = image.resize(toSize: size)
        self.scale = scale
        self.size = size
    }

    /// Writes the iconset image to the given url.
    ///
    /// - parameter url: The url to save the image to.
    func writeToURL(_ url: URL) throws {
        let imgURL = url.appendingPathComponent(filename, isDirectory: false)

        if let png = image?.PNGRepresentation {
            try png.write(to: imgURL, options: .atomic)
        }
    }
}
