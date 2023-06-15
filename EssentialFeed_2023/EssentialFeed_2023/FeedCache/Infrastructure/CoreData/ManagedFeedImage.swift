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
    @NSManaged var cache: ManagedCache
    
    var local: LocalFeedImage {
        return LocalFeedImage(
            id: id,
            description: imageDescription,
            location: location,
            url: url)
    }
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.id = local.id
            managedFeedImage.imageDescription = local.description
            managedFeedImage.location = local.location
            managedFeedImage.url = local.imageURL
            return managedFeedImage
        })
    }
}

extension ManagedFeedImage: Identifiable {}
