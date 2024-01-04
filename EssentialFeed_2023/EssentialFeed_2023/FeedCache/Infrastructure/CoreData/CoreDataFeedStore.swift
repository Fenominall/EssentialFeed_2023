//
//  CoreDataFeedStore.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 6/12/23.
//

import Foundation
import CoreData


public final class CoreDataFeedStore {
    
    //MARK: - Properties
    private let model = "FeedStore"
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    //MARK: - Initialization
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: model, url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
