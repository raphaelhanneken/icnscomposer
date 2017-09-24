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

/// Exceptions for Iconset
///
/// - missingURL: The given URL, to save the icns file to, couldn't be unwrapped.
enum IconsetError: Error {
    case missingURL
}

/// Handles the iconset creation.
struct Iconset {

    /// Holds the necessary images to create an iconset that conforms iconutil
    var images = [String: IconImage]()

    subscript(filename: String) -> IconImage? {
        get {
            return images[filename]
        }

        set {
            images[filename] = newValue
        }
    }

    ///  Saves an icns file to the supplied url.
    ///
    ///  - parameter url: URL to save the icns file to.
    ///  - throws: A MissingURL error, when the supplied url cant be unwrapped.
    func writeToURL(_ url: URL?) throws {
        guard let url = url else {
            throw IconsetError.missingURL
        }
        // Create a random iconset within the temporary directory.
        let tmpURL = try writeToTemporaryDir()
        // Create the .icns file.
        try runIconUtilWithInput(tmpURL, andOutputURL: url)
        // Open the working directory.
        NSWorkspace.shared.open(url.deletingLastPathComponent())
    }

    /// Create a new iconset within the user's temporary directory.
    ///
    /// - returns: The URL where the iconset were written to.
    fileprivate func writeToTemporaryDir() throws -> URL {
        // Create a randomly named dictionary.
        let icnSet = "\(Int(arc4random_uniform(99999) + 10000)).iconset/"
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory() + icnSet, isDirectory: true)
        // Create the temporary directory.
        try FileManager.default.createDirectory(at: tmpURL, withIntermediateDirectories: true, attributes: nil)
        // Save every single associated image.
        for (_, image) in images {
            try image.writeToURL(tmpURL)
        }
        return tmpURL
    }

    ///  Executes iconutil with the given url as input path.
    ///
    ///  - parameter input:  Path to a convertable iconset directory.
    ///  - parameter output: Path to the location, where to save the generated icns file.
    ///
    ///  - throws: Throws a MissingURL error, in case one of the supplied urls cant be unwrapped.
    private func runIconUtilWithInput(_ input: URL?, andOutputURL output: URL?) throws {
        guard let input = input,
            var output = output else {
            throw IconsetError.missingURL
        }
        if output.pathExtension != "icns" {
            output = output.appendingPathExtension("icns")
        }
        // Create a new process to run /usr/bin/iconutil
        let iconUtil = Process()
        // Configure and launch the Task.
        iconUtil.launchPath = "/usr/bin/iconutil"
        iconUtil.arguments = ["-c", "icns", "-o", output.path, input.path]
        iconUtil.launch()
        iconUtil.waitUntilExit()
        // Delete the temporary iconset
        try FileManager.default.removeItem(at: input)
    }
}
