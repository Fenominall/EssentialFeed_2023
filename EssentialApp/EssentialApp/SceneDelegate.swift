//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Fenominall on 05.01.2024.
//

import os
import UIKit
import CoreData
import Combine
import EssentialFeed_2023
import EssentialFeed_2023iOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(
            session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var logger = Logger(
        subsystem: "com.fenominall.EssentialApp",
        category: "main")
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(
                storeURL: CoreDataFeedStore.storeURL)
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeRemoteFeedImageDataLoaderWithLocalFallback,
            selection: showComments))
    
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    // When you cannot invoke a method you want to test(e.g. framework limitation), move the logic to a method you can invoke.
    func configureWindow() {
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()
        
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndPoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(from: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback()
    -> AnyPublisher<Paginated<FeedImage>, Error> {
        
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
        // wrapping received array of items into paginated generic array
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }
    
    
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?)
    -> AnyPublisher<Paginated<FeedImage>, Error> {
        
        localFeedLoader.loadPublisher()
            .zip(makeRemoteFeedLoader(after: last))
            .map { (cachedItems, newItems) in
                (cachedItems + newItems, newItems.last)
            }.map(makePage)
            .caching(to: localFeedLoader)
    }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
        
        return httpClient
        // functional sendwich
        //      [ sife-effect ]
            .getPublisher(from: url)
        //      -pure function--
            .tryMap(FeedItemsMapper.map)
        //      [ side-effect ]
            .eraseToAnyPublisher()
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makeRemoteFeedImageDataLoaderWithLocalFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback { [httpClient, logger] in
                httpClient
                    .getPublisher(from: url)
                    .logErrors(url: url, logger: logger)
                    .logElapesTime(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            }
    }
}

extension Publisher {
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents (
            receiveCompletion: { result in
                if case .failure = result {
                    logger.trace("Cache miss for url: \(url)")
                }
            }
        ).eraseToAnyPublisher()
    }
    
    func logErrors(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents (
            receiveCompletion: { result in
                if case let .failure(error) = result {
                    logger.trace("Failed to load url: \(url) with error: \(error.localizedDescription)")
                }
            }
        ).eraseToAnyPublisher()
    }
    
    func logElapesTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime()

        return handleEvents (
            receiveSubscription: { _ in
            logger.trace("Started loading url: \(url)")
                startTime = CACurrentMediaTime()
        },
            receiveCompletion: { result in
                let ellapsed = CACurrentMediaTime() - startTime
                logger.trace("Finished loading url: \(url) in \(ellapsed) seconds")
            }
        ).eraseToAnyPublisher()
    }
}
