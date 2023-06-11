//
//  ManagedCache+CoreDataClass.swift
//  EssentialFeed_2023
//
//  Created by Fenominall on 6/3/23.
//
//

import Foundation
import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date?
    @NSManaged var feed: NSOrderedSet?
}



extension ManagedCache {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }

}

extension ManagedCache : Identifiable {

}

