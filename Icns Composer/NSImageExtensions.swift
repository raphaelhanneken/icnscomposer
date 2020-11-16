//
// NSImageExtensions.swift
// Icns Composer
// https://github.com/raphaelhanneken/icnscomposer
//

import Cocoa

/// Exceptions for the image extension class.
///
/// - creatingPngRepresentationFailed: Is thrown when the creation of the png representation failed.
enum NSImageExtensionError: Error {
    case creatingPngRepresentationFailed
}

extension NSImage {

    var height: CGFloat {
        return size.height
    }

    var width: CGFloat {
        return size.width
    }

    var PNGRepresentation: Data? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .png, properties: [:])
        }
        return nil
    }

    /// Resizes the image to the given size.
    ///
    /// - parameter size: The size to resize the image to.
    /// - returns: The resized image.
    func resize(toSize size: NSSize) -> NSImage? {
        let frame = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let rep = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }

        let img = NSImage(size: size, flipped: false, drawingHandler: { (_) -> Bool in

            if rep.draw(in: frame) {
                return true
            }
            return false
        })

        return img
    }

    /// Copies the image and resizes it to the supplied size, while maintaining it's
    /// original aspect ratio.
    ///
    /// - parameter size: The target size of the image.
    /// - returns: The resized image.
    func resizeMaintainingAspectRatio(withSize size: NSSize) -> NSImage? {
        let newSize: NSSize

        let widthRatio = size.width / width
        let heightRatio = size.height / height

        if widthRatio > heightRatio {
            newSize = NSSize(width: floor(width * widthRatio),
                             height: floor(height * widthRatio))
        } else {
            newSize = NSSize(width: floor(width * heightRatio),
                             height: floor(height * heightRatio))
        }
        return resize(toSize: newSize)
    }

    /// Resizes the image, to nearly fit the supplied cropping size
    /// and return a cropped copy the image.
    ///
    /// - parameter size: The size of the new image.
    /// - returns: The cropped image.
    func crop(toSize: NSSize) -> NSImage? {
        guard let resized = self.resizeMaintainingAspectRatio(withSize: size) else {
            return nil
        }

        // swiftlint:disable identifier_name
        let x = floor((resized.width - size.width) / 2)
        let y = floor((resized.height - size.height) / 2)
        let frame = NSRect(x: x, y: y, width: width, height: height)

        guard let rep = resized.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }

        let img = NSImage(size: size)
        defer { img.unlockFocus() }
        img.lockFocus()

        if rep.draw(in: NSRect(x: 0, y: 0, width: width, height: height),
                    from: frame,
                    operation: NSCompositingOperation.copy,
                    fraction: 1.0,
                    respectFlipped: false,
                    hints: [:]) {
            return img
        }

        return nil
    }

    /// Saves the images PNG representation to the supplied file URL.
    ///
    /// - parameter url: The file URL to save the png file to.
    /// - throws: An NSImageExtension Error.
    func savePngTo(url: URL) throws {
        guard let png = self.PNGRepresentation else {
            throw NSImageExtensionError.creatingPngRepresentationFailed
        }

        try png.write(to: url, options: .atomicWrite)
    }
}
