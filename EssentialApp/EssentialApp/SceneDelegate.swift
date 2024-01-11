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
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
//        
//        let localStoreURL = NSPersistentContainer
//            .defaultDirectoryURL()
//            .appending(path: "feed-store.sqlite")
//        
//        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
//        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
//        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
        window?.rootViewController = FeedUIComposer.feedComposedWith(
            feedLoader: remoteFeedLoader,
            imageLoader: remoteImageLoader)
    }
}
