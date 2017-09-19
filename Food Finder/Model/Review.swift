//
//  Review.swift
//  Food Finder
//
//  Created by Per Friis on 19/09/2017.
//  Copyright © 2017 Per Friis Consult ApS. All rights reserved.
//

import Foundation
import CoreData

/// Codable version of Review coredata entity
struct ReviewCodable:Codable {
    let id:UUID
    let version:Int
    let created:Date
    let title:String
    let detail:String
    let stars:Int
    let author:String
}

extension Review {
    var codable:ReviewCodable {
        get {
            
            return ReviewCodable(id: UUID(uuidString:id!)!, version: Int(version), created: created!, title: title!, detail: detail!, stars: Int(stars), author: author!)
        }
        set {
            id = newValue.id.uuidString
            version = Int16(newValue.version)
            created = newValue.created
            title = newValue.title
            detail = newValue.detail
            stars = Int16(newValue.stars)
            author = newValue.author
        }
    }
    
    /// class func that finds all the menues that matches the predicate
    /// - Parameters:
    ///     - predicate: NSPredicate, default NSPredicate(format:"TRUEPREDICATE") returns all items
    ///     - context: the NSManagedObjectContext to use
    /// - Returns:
    ///     Will always return a list of items, the list might be empty
    class func find(predicate:NSPredicate = NSPredicate(format:"TRUEPREDICATE"), context:NSManagedObjectContext) -> [Review] {
        let fetchRequest:NSFetchRequest<Review> = Review.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return []
    }
    
    /// Class function, that find a menuItem based on the id
    /// - Parameters:
    ///     - id:UUID to find
    ///     - context:NSManagedObjectContext to use
    class func find(id:UUID, context:NSManagedObjectContext) -> Review? {
        return Review.find(predicate:NSPredicate(format:"id == %@",id.uuidString), context:context).first
    }
}
