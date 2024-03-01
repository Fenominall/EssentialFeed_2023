//
//  ManagedFeedImage+CoreDataClass.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 6/3/23.
//
//

import Foundation
import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    var local: LocalFeedImage {
        return LocalFeedImage(
            id: id,
            description: imageDescription,
            location: location,
            url: url)
    }
    
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        // when loading data withing the cells, looking for in memory temporary lookup for data of the url and use it instead of macking a database request

        if let data = context.userInfo[url] as? Data { return data }
        
        return try first(with: url, in: context)?.data
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.imageURL
            // when stroing a new image checking if we already have the data for that image in the temporary userInfo dictionaty

            managed.data = context.userInfo[local.imageURL] as? Data
            return managed
        })
        context.userInfo.removeAllObjects()
        return images
    }
    
    // Called for each CoreData entity before it`s deletion
    override func prepareForDeletion() {
        super.prepareForDeletion()
        // storing the data for url
        managedObjectContext?.userInfo[url] = data
    }
}
