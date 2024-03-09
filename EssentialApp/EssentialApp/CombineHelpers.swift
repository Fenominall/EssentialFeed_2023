//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Владислав Тодоров on 20.01.2024.
//

import Foundation
import Combine
import EssentialFeed_2023

// converting - public typealias LoadMoreCompletion = (Result<Self, Error>) -> Void - into a Combine publisher and back
public extension Paginated {
    init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
            self.init(items: items, loadMore: loadMorePublisher.map { publisher in
                return { completion in
                    publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
                        if case let .failure(error) = result {
                            completion(.failure(error))
                        }
                    }, receiveValue: { result in
                        completion(.success(result))
                    }))
                }
            })
        }
    
    var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
        guard let loadMore = loadMore else { return nil }
        
        return {
            Deferred {
                Future(loadMore)
            }.eraseToAnyPublisher()
        }
    }
}

// This is the RemoteLoader now as abstraction
public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(from url: URL) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = self.loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIngoringResult(data, for: url)
        }).eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIngoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}

public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    func loadPublisher() -> Publisher {
        // A Deferred is a lazy publisher that awaits subscription before running.
        // So you can use it to wrap and make an eager publisher lazy.
        // For example, you can wrap a Future to defer its work:
        Deferred {
            // Because the types match between RemoteFeedLoader completion block and the Future completion block
            // we can just path the load function for the completion parameter
            // in this the 'self' is the RemoteFeddLoader itself
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>)
    -> AnyPublisher<Output, Failure> {
        // First, it tries to use the primary source (self). If the primary publisher produces an error, use fallbackPublisher.
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    // Added a side effect the same as in FeedLoaderCacheDecorator
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == [FeedImage] {
        // Since the received Output closure has the same signature with saveIngoringResult function,
        // it can be passed directly cache.saveIgnoringResult
        handleEvents(receiveOutput: cache.saveIgnoringResult)
            .eraseToAnyPublisher()
    }
    
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == Paginated<FeedImage> {
        handleEvents(receiveOutput: cache.saveIgnoringResult)
            .eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
    
    func saveIgnoringResult(_ page: Paginated<FeedImage>) {
        saveIgnoringResult(page.items)
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        // the receive operator always dispatch asyncronously
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler()
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        public init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            action()
        }
        
        func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
            // When we cannot execute immidiately we can forward the message to the main queue scehduler
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
        
    }
}
