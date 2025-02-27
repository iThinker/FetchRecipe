//
//  ImageLoader.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-25.
//

import Foundation
import UIKit

protocol ImageLoader: Sendable {
    /// Returns image loaded from remote or local cache if possible.
    /// Throws error if image cannot be loaded.
    /// - Parameter url: Url to load image from.
    /// - Returns: Result image.
    func image(for url: URL) async throws -> UIImage
}

/// Default Image loader implementation.
/// Features:
/// - Request deduplication by url.
/// - Local image cache persisted between app launches.
actor ImageLoaderImpl: ImageLoader {
    
    static let shared = ImageLoaderImpl()
    
    private let imageCache: ImageCache?
    private let remoteImageLoader: ImageLoader
    
    private var fetchTasks = [URL: Task<UIImage, Error>]()
    
    init(imageCache: ImageCache? = try? ImageCacheImpl(), remoteImageLoader: ImageLoader = RemoteImageLoader()) {
        self.imageCache = imageCache
        self.remoteImageLoader = remoteImageLoader
    }
    
    func image(for url: URL) async throws -> UIImage {
        let resultTask: Task<UIImage, Error>
        if let existingTask = fetchTasks[url] {
            resultTask = existingTask
        }
        else {
            let newTask = Task {
                do {
                    return try await self.internalImage(for: url)
                }
                catch {
                    self.removeTask(for: url)
                    throw error
                }
            }
            
            resultTask = newTask
            fetchTasks[url] = newTask
        }
        
        return try await resultTask.value
    }
    
    private func internalImage(for url: URL) async throws -> UIImage {
        if let imageCache, let image = try? await imageCache.image(for: url) {
            return image
        }
        else {
            return try await fetchImage(for: url)
        }
    }
    
    private func fetchImage(for url: URL) async throws -> UIImage {
        do {
            let image = try await remoteImageLoader.image(for: url)
            await imageCache?.save(image, for: url)
            return image
        }
        catch {
            print("Failed to fetch image for url: \(url), error: \(error)")
            throw error
        }
    }

    private func removeTask(for url: URL) {
        fetchTasks.removeValue(forKey: url)
    }
    
}

final class RemoteImageLoader: ImageLoader {
    
    private let urlSession = URLSession.shared
    
    func image(for url: URL) async throws -> UIImage {
        let data = try await urlSession.data(from: url).0
        if let image = UIImage(data: data) {
            return image
        }
        else {
            throw UnexpectedError(message: "Failed to deserialize image.")
        }
    }
    
}
