//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Fenominall on 05.01.2024.
//

import UIKit
import CoreData
import EssentialFeed_2023
import EssentialFeed_2023iOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer
            .defaultDirectoryURL()
            .appending(path: "feed-store.sqlite")
        )
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        configureWindow()
    }
     
    // When you cannot invoke a method you want to test(e.g. framework limitation), move the logic to a method you can invoke.
    func configureWindow() {
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        window?.rootViewController = UINavigationController(rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallback: localFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader))))
    }
}
