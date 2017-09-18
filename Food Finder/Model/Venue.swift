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
    

}
