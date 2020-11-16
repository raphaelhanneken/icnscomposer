//
// Iconset.swift
// Icns Composer
// https://github.com/raphaelhanneken/icnscomposer
//

import Cocoa

/// Error cases for icns file generation
///
/// - missingURL: The given URL, to save the icns file to, is missing.
enum IconsetError: Error {
    case missingURL
}

struct Iconset {

    /// The necessary images to create an iconset that conforms iconutil
    var images: [String: IconImage]

    /// Initializes a new Iconset
    init() {
        images = [String: IconImage]()
    }

    /// Subscript to access a specific image inside the Iconset by it's filename.
    ///
    /// - parameter filename: The filename of the image to access
    subscript(filename: String) -> IconImage? {
        get { return images[filename] }
        set { images[filename] = newValue }
    }

    ///  Saves an icns file to the supplied url.
    ///
    ///  - parameter url: URL to save the icns file to.
    ///  - throws: A MissingURL error, when the supplied url can't be unwrapped.
    func writeToURL(_ url: URL?) throws {
        guard let url = url else {
            throw IconsetError.missingURL
        }

        let tmpURL = try writeToTemporaryDir()
        try runIconUtilWithInput(tmpURL, andOutputURL: url)

        NSWorkspace.shared.open(url.deletingLastPathComponent())
    }

    /// Create a new iconset within the user's temp directory.
    ///
    /// - returns: The URL where the iconset were written to.
    fileprivate func writeToTemporaryDir() throws -> URL {
        let icnSet = "\(Int(arc4random_uniform(99999) + 10000)).iconset/"
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory() + icnSet, isDirectory: true)

        try FileManager.default.createDirectory(at: tmpURL, withIntermediateDirectories: true, attributes: nil)

        for (_, image) in images {
            try image.writeToURL(tmpURL)
        }

        return tmpURL
    }

    ///  Executes iconutil with the given url as input path.
    ///
    ///  - parameter input: Path to a convertable iconset directory.
    ///  - parameter output: Path to the location, where to save the generated icns file.
    ///  - throws: Throws a MissingURL error, in case one of the supplied urls cant be unwrapped.
    private func runIconUtilWithInput(_ input: URL?, andOutputURL output: URL?) throws {
        guard let input = input, var output = output else {
            throw IconsetError.missingURL
        }

        if output.pathExtension != "icns" {
            output = output.appendingPathExtension("icns")
        }

        let iconUtil = Process()

        iconUtil.launchPath = "/usr/bin/iconutil"
        iconUtil.arguments = ["-c", "icns", "-o", output.path, input.path]
        iconUtil.launch()
        iconUtil.waitUntilExit()

        try FileManager.default.removeItem(at: input)
    }
}
