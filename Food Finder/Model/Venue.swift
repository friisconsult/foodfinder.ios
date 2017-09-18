//
//  Venue.swift
//  Food Finder
//
//  Created by Per Friis on 18/09/2017.
//  Copyright © 2017 Per Friis Consult ApS. All rights reserved.
//

import Foundation
import CoreData

struct VenueCodable:Codable {
    let id:UUID
    let version:Int
    let created:Date
    let deleted:Bool
    let owner:String
    let title:String
    let detail:String?
    let type:Int
    let logoImaageUrl:String?
    let street:String?
    let zipCode:String?
    let city:String?
    let state:String?
    let country:String?
    let email:String?
    let phone:String?
    let latitude:Double
    let longitude:Double
    let priceLevel:Double
}

extension Venue {
    

    var codable:VenueCodable {
        get {
            let ID = UUID(uuidString: id!)!
            return VenueCodable(id: ID,
                                version: Int(version),
                                created: created!,
                                deleted: false,
                                owner: owner!,
                                title: title!,
                                detail: detail,
                                type: Int(type),
                                logoImaageUrl: logoImaageUrl,
                                street: street,
                                zipCode: zipCode,
                                city: city,
                                state: state,
                                country: country,
                                email: email,
                                phone: phone,
                                latitude: latitude, longitude: longitude,
                                priceLevel: priceLevel)
        }
        set {
            id = newValue.id.uuidString
            version = Int16(newValue.version)
            created = newValue.created
            owner = newValue.owner
            title = newValue.title
            detail = newValue.detail
            type = Int16(newValue.type)
            logoImaageUrl = newValue.logoImaageUrl
            street = newValue.street
            zipCode = newValue.zipCode
            city = newValue.city
            state = newValue.state
            country = newValue.country
            email = newValue.email
            latitude = newValue.latitude
            longitude = newValue.longitude
            priceLevel = newValue.priceLevel
        }
    }
    
    class func find(predicate:NSPredicate = NSPredicate(format:"TRUEPREDICATE"), context:NSManagedObjectContext) -> [Venue] {
        let fetchRequest:NSFetchRequest<Venue> = Venue.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            assertionFailure(error.localizedDescription)
        }
        return []
    }
    
    class func find(id:UUID,  context:NSManagedObjectContext) -> Venue? {
        return Venue.find(predicate: NSPredicate(format:"id == %@",id.uuidString), context: context).first
    }
}
