//
//  MenuItem.swift
//  Food Finder
//
//  Created by Per Friis on 19/09/2017.
//  Copyright © 2017 Per Friis Consult ApS. All rights reserved.
//

import Foundation
import CoreData
/// codable version of the MenuItem core entity (NSManagedObject are not compatable with the codable protocol
struct MenuItemCodable:Codable {
    let id:UUID
    let version:Int
    let created:Date
    let owner:String
    let title:String
    let type:Int
    let price:Double
    let detail:String
}

extension MenuItem {
    /// a way to use codable protocol on NSManagedObject's
    var codable:MenuItemCodable {
        get {
            return MenuItemCodable(id: UUID(uuidString:id!)!, version: Int(version), created: created!, owner: owner!, title: title!, type: Int(type), price: price, detail:detail!)
        }
        set {
            id = newValue.id.uuidString
            version = Int16(newValue.version)
            created = newValue.created
            detail = newValue.detail
            owner = newValue.owner
            title = newValue.title
            type = Int16(newValue.type)
            price = newValue.price
        }
    }

    /// class func that finds all the menues that matches the predicate
    /// - Parameters:
    ///     - predicate: NSPredicate, default NSPredicate(format:"TRUEPREDICATE") returns all items
    ///     - context: the NSManagedObjectContext to use
    /// - Returns:
    ///     Will always return a list of items, the list might be empty
    class func find(predicate:NSPredicate = NSPredicate(format:"TRUEPREDICATE"), context:NSManagedObjectContext) -> [MenuItem] {
        let fetchRequest:NSFetchRequest<MenuItem> = MenuItem.fetchRequest()
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
    class func find(id:UUID, context:NSManagedObjectContext) -> MenuItem? {
        return MenuItem.find(predicate:NSPredicate(format:"id == %@",id.uuidString), context:context).first
    }
}
