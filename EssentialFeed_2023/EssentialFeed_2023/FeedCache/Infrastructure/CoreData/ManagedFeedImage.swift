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
}

extension ManagedFeedImage: Identifiable {}
