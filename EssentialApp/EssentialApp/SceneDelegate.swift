//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Fenominall on 05.01.2024.
//

import UIKit
import CoreData
import Combine
import EssentialFeed_2023
import EssentialFeed_2023iOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: CoreDataFeedStore.storeURL)
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
    
    
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?)
    -> AnyPublisher<Paginated<FeedImage>, Error> {
        
        makeRemoteFeedLoader(after: last)
            .map { newItems in
                (items + newItems, newItems.last)
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
            { self.makeRemoteLoadMoreLoader(items: items, last: last) }
        })
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makeRemoteFeedImageDataLoaderWithLocalFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback { [httpClient] in
                httpClient
                    .getPublisher(from: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            }
    }
}
