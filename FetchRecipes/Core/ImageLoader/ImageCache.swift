//
//  ImageCache.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-25.
//

import Foundation
import UIKit

enum ImageCacheError: Error {
    /// Image was not found in cache.
    case notFound
}

protocol ImageCache: Sendable {
    /// Returns imaghe if it is available in local cache.
    /// Throws ``ImageCacheError``.
    /// - Parameter url: image url to use as a key.
    /// - Returns: result image.
    func image(for url: URL) async throws -> UIImage
    /// Saves image to cache if possible.
    /// Best effort.
    /// - Parameters:
    ///   - image: Image to save.
    ///   - url: Url to use as an image key.
    func save(_ image: UIImage, for url: URL) async
}

/// Default image cache implementation that stores images in a file system.
actor ImageCacheImpl: ImageCache {
    
    private static let cachedImageNamesKey = "ImageCacheImpl.cachedImageNamesKey"
    
    private let cachesDirectoryPath: URL
    private lazy var cachedImageNames: [String: String] = {
        UserDefaults.standard.dictionary(forKey: Self.cachedImageNamesKey) as? [String: String] ?? [:]
    }() {
        didSet {
            UserDefaults.standard.setValue(cachedImageNames, forKey: Self.cachedImageNamesKey)
        }
    }
    
    init() throws {
        let fileManager = FileManager.default
        let cachesDirectoryPath = URL.cachesDirectory.appending(component: "Images")
        self.cachesDirectoryPath = cachesDirectoryPath
        try fileManager.createDirectory(at: cachesDirectoryPath, withIntermediateDirectories: true)
    }
    
    func image(for url: URL) async throws -> UIImage {
        if let imageName = cachedImageNames[url.absoluteString] {
            do {
                let path = cachesDirectoryPath.appending(path: imageName)
                if let image = UIImage(contentsOfFile:path.absoluteString) {
                    return image
                } else {
                    throw UnexpectedError(message: "Could not deserialize image at path \(path)")
                }
            }
            catch {
                print("Could not get image from local storage \(error)")
                throw error
            }
        }
        else {
            throw ImageCacheError.notFound
        }
    }
    
    func save(_ image: UIImage, for url: URL) async {
        do {
            guard let data = image.pngData() else {
                throw UnexpectedError(message: "Could not serialize image")
            }
            let filename = UUID().uuidString.appending(".png")
            let path = cachesDirectoryPath.appending(path: filename)
            try data.write(to: path)
            cachedImageNames[filename] = url.absoluteString
        }
        catch {
            print("Failed to save image \(error)")
        }
    }
    
}
