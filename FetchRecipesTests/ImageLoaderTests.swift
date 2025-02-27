//
//  ImageLoaderTests.swift
//  FetchRecipesTests
//
//  Created by Roman Temchenko on 2025-02-26.
//

import Testing
@testable import FetchRecipes
import UIKit


actor ImageCacheMock: ImageCache {
    
    var imageRequestCount = 0
    var imageSaveCount = 0
    private var mockImage: UIImage?
    
    func setMockImage(_ image: UIImage?) {
        self.mockImage = image
    }
    
    func image(for url: URL) async throws -> UIImage {
        imageRequestCount += 1
        if let mockImage {
            return mockImage
        }
        else {
            throw ImageCacheError.notFound
        }
    }
    
    func save(_ image: UIImage, for url: URL) async {
        imageSaveCount += 1
    }
}

actor RemoteImageLoaderMock: ImageLoader {
    
    var imageRequestCount = 0
    private var sleepDelayMs: Int64?
    
    func setSleepDelayMs(_ sleepDelayMs: Int64?) {
        self.sleepDelayMs = sleepDelayMs
    }
    
    func image(for url: URL) async throws -> UIImage {
        imageRequestCount += 1
        if let sleepDelayMs {
            try? await Task.sleep(for: .milliseconds(sleepDelayMs))
        }
        throw UnexpectedError(message: "Not implemented")
    }
    
}

struct ImageLoaderTests {

    @Test func testLoadFromRemote() async throws {
        let remoteImageLoader = RemoteImageLoaderMock()
        let imageCache = ImageCacheMock()
        let sut = ImageLoaderImpl(imageCache: imageCache, remoteImageLoader: remoteImageLoader)
        await #expect(throws: UnexpectedError.self, performing: {
            let _ = try await sut.image(for: URL(string: "test.com")!)
        })
        await #expect(imageCache.imageRequestCount == 1)
        await #expect(remoteImageLoader.imageRequestCount == 1)
    }
    
    @Test func testLoadFromCache() async throws {
        let remoteImageLoader = RemoteImageLoaderMock()
        let imageCache = ImageCacheMock()
        let sut = ImageLoaderImpl(imageCache: imageCache, remoteImageLoader: remoteImageLoader)
        
        await imageCache.setMockImage(UIImage(systemName: "globe"))
        
        let _ = try await sut.image(for: URL(string: "test.com")!)
        await #expect(imageCache.imageRequestCount == 1)
        await #expect(remoteImageLoader.imageRequestCount == 0)
    }
    
    @Test func testRequestDeduplication() async throws {
        let remoteImageLoader = RemoteImageLoaderMock()
        let imageCache = ImageCacheMock()
        let sut = ImageLoaderImpl(imageCache: imageCache, remoteImageLoader: remoteImageLoader)
        
        await remoteImageLoader.setSleepDelayMs(1000)
        
        let task1 = Task.detached {
            let _ = try? await sut.image(for: URL(string: "test.com")!)
        }
        let task2 = Task.detached {
            let _ = try? await sut.image(for: URL(string: "test.com")!)
        }
        
        let _ = await [task1.value, task2.value]
        
        await #expect(imageCache.imageRequestCount == 1)
        await #expect(remoteImageLoader.imageRequestCount == 1)
    }

}
