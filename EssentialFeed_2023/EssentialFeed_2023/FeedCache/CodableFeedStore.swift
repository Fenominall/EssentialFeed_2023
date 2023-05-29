//
//  CodableFeedStore.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 5/28/23.
//

import Foundation

public final class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    
    //    Move 'Codeable' conformance from the framework-agnostic 'LocalFeedImage'  type to the new framework-specific 'CodableFeedImage' type. The 'CodeableFeedImage' is a private type within the framework implementation since the 'Codable' requirement is a framework-specific detail.
    // In this case the DTO with a mapping used instead.
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.imageURL = image.imageURL
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(
                id: id,
                description: description,
                location: location ,
                url: imageURL)
        }
    }
    
    // Background queue and by default the operations rus serially
    private let queue = DispatchQueue(
        label: "\(CodableFeedStore.self)Queue",
        qos: .userInitiated
    )
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        // In this case only the value is captured not self inside the closure, it`s passed by copy, so it`s thread safe
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(feed: cache.localFeed, timestamp: cache.timeStamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage],
                       timestamp: Date,
                       completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async {
            
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: feed.map(CodableFeedImage.init),
                                  timeStamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
                
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        // The operations with side effects blocked with a flag to aviod concurency issue with other methods retrieve/insert
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path()) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}

