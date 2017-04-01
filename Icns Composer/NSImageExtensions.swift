//
// NSImageExtensions.swift
// Icns Composer
// https://github.com/raphaelhanneken/icnscomposer
//

import Cocoa

extension NSImage {

    /// The height of the image.
    var height: CGFloat {
        return size.height
    }

    /// The width of the image.
    var width: CGFloat {
        return size.width
    }

    /// A PNG representation of the image.
    var PNGRepresentation: Data? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .PNG, properties: [:])
        }
        return nil
    }

    // MARK: Resizing

    /// Resize the image to the given size.
    ///
    /// - Parameter size: The size to resize the image to.
    /// - Returns: The resized image.
    func resize(toSize size: NSSize) -> NSImage? {
        // Create a new rect with given width and height
        let frame = NSRect(x: 0, y: 0, width: size.width, height: size.height)

        // Get the best representation for the given size.
        guard let rep = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        // Create an empty image with the given size.
        let img = NSImage(size: size, flipped: false, drawingHandler: { (_) -> Bool in

            if rep.draw(in: frame) {
                return true
            }

            return false
        })
        return img
    }

    /// Copy the image and resize it to the supplied size, while maintaining it's
    /// original aspect ratio.
    ///
    /// - Parameter size: The target size of the image.
    /// - Returns: The resized image.
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

    // MARK: Cropping

    /// Resize the image, to nearly fit the supplied cropping size
    /// and return a cropped copy the image.
    ///
    /// - Parameter size: The size of the new image.
    /// - Returns: The cropped image.
    func crop(toSize: NSSize) -> NSImage? {
        // Resize the current image, while preserving the aspect ratio.
        guard let resized = self.resizeMaintainingAspectRatio(withSize: size) else {
            return nil
        }

        // Get some points to center the cropping area.
        let x = floor((resized.width - size.width) / 2)
        let y = floor((resized.height - size.height) / 2)
        // Create the cropping frame.
        let frame = NSRect(x: x, y: y, width: width, height: height)

        // Get the best representation of the image for the given cropping frame.
        guard let rep = resized.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }

        // Create a new image with the new size
        let img = NSImage(size: size)
        defer { img.unlockFocus() }
        img.lockFocus()

        if rep.draw(in: NSRect(x: 0, y: 0, width: width, height: height),
                    from: frame,
                    operation: NSCompositingOperation.copy,
                    fraction: 1.0,
                    respectFlipped: false,
                    hints: [:]) {
            // Return the cropped image.
            return img
        }
        // Return nil in case anything fails.
        return nil
    }

    // MARK: Saving

    /// Save the images PNG representation to the supplied file URL.
    ///
    /// - Parameter url: The file URL to save the png file to.
    /// - Throws:        An NSImageExtension Error.
    func savePngTo(url: URL) throws {
        if let png = self.PNGRepresentation {
            try png.write(to: url, options: .atomicWrite)
        } else {
            throw NSImageExtensionError.creatingPngRepresentationFailed
        }
    }
}

/// Exceptions for the image extension class.
///
/// - creatingPngRepresentationFailed: Is thrown when the creation of the png representation failed.
enum NSImageExtensionError: Error {
    case creatingPngRepresentationFailed
}
