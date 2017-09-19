//
//  Cloud.swift
//  Food Finder
//
//  Created by Per Friis on 18/09/2017.
//  Copyright © 2017 Per Friis Consult ApS. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/// # Singleton
/// Cloud class is a singleton, that handles all the communition with the backend
/// it also handles the syncronization between the local storage (coreData) and backend
/// - Author:
/// Per Friis
class Cloud {
    
    /// The singleton access point
    static let shared:Cloud = Cloud()
    
    /// to enable the syncronozation with the local storage, you must set the persistentContainer
    ///
    /// - Note: When set, it sets the viewContext to automatically get changes from parent,
    /// you should be able to use the notifications and `NSFetchedResultsController`
    var persistentContainer:NSPersistentContainer! {
        didSet{
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
    
    /// Holds the baseurl to the api
    fileprivate let apiUrl:URL
    
    /// using with the template api back-end, there is implemented an API-key
    fileprivate let apiKey:String
    
    /// It is good practice to show the networkspinner, doing network trafic
    /// add one on each call, remember to substract when the call ends
    /// - Note: `defer` at the begining of a block call, to ensure the substraction when leaving the block
    fileprivate var networkCounter:Int = 0 {
        didSet{
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = self.networkCounter > 0
            }
        }
    }
    
    /// The default init, will get the url and api key from the info.plist
    /// * Important: remember to set the api url and api key in info.plist
    ///
    /// * __api_url__:_https://api.url.com_, please note the url must be _https:_
    ///
    /// * __api_key__:some string the matches the key for your api
    init() {
        guard let apiUrlString = Bundle.main.object(forInfoDictionaryKey: "api_url") as? String,
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "api_key") as? String else {
                fatalError("error with the url")
        }
        self.apiUrl = URL(string:apiUrlString)!
        self.apiKey = apiKey
    }
    
    
    /// The base request setup a URLRequest, with the base url, path component,
    /// method, api key and mimetype
    /// - parameters:
    ///     - path: the pathcomponent, to add to the base url
    ///     - method: GET (default), POST, DELETE ...
    func baseRequest( path:String, method:String = "GET") -> URLRequest {
        var baseRequest = URLRequest(url: apiUrl.appendingPathComponent(path))
        baseRequest.httpMethod = method
        baseRequest.addValue("Agrajag", forHTTPHeaderField:"FC-APPLICATION-KEY")
        baseRequest.addValue("application/json", forHTTPHeaderField:"content")
        
        return baseRequest
    }
    
    
    /// Gets all the venues from the backend and update the local storage
    ///
    /// if failes, it will just return withou doing anything, except when developering
    /// there a falure will cause an assertion
    func downloadVenues() {
        guard persistentContainer != nil else {
            assertionFailure("You must set the persistent container")
            return
        }
        
        let sessionConfiguration = URLSessionConfiguration.default
        if #available(iOS 11.0, *) {
            sessionConfiguration.waitsForConnectivity = true
        }
        let session = URLSession(configuration: sessionConfiguration)
        
        let dataTask = session.dataTask(with: baseRequest(path: "venues")) { (data, urlResponse, error) in
            defer {
                self.networkCounter -= 1
            }
            
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                assertionFailure(urlResponse!.description)
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                assertionFailure(httpResponse.description)
                return
            }
            
            guard let data = data else {
                assertionFailure("No data returned")
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            
            do {
                let venuesCodable = try jsonDecoder.decode([VenueCodable].self, from: data)
                
                self.persistentContainer.performBackgroundTask({ (context) in
                    
                    for codable in venuesCodable {
                        var venue = Venue.find(id: codable.id, context: context)
                        if venue == nil {
                            venue = Venue(context: context)
                        }
                        
                        venue?.codable = codable
                    }
                    
                    do {
                        try context.save()
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                })
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        
        self.networkCounter += 1
        dataTask.resume()
    }
    
    /// Get the detail data for a given venue and update the local storage
    func downloadDetail(venue:Venue) {
        guard let venueId = venue.id else {
            return
        }
        let request = baseRequest(path: "venues/\(venueId)")
        
        
        let configuration = URLSessionConfiguration.default
        if #available(iOS 11.0, *) {
            configuration.waitsForConnectivity = true
        }
        
        let session = URLSession(configuration: configuration)
        let task = session.dataTask(with: request) { (data, urlResponse, error) in
            defer {
                self.networkCounter -= 1
            }
            
            guard error == nil else {
                assertionFailure(error!.localizedDescription)
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                assertionFailure(urlResponse?.description ?? "problem with the urlResponse")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                assertionFailure(httpResponse.description)
                return
            }
            
            guard let data = data else {
                assertionFailure("Error with data, it looks like no data was returned")
                return
            }
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            
            do {
                let venueCodable = try jsonDecoder.decode(VenueCodable.self, from: data)
                self.persistentContainer.performBackgroundTask({ (context) in
                    if let venue = Venue.find(id: venueCodable.id, context: context) {
                        if let menuItemsCodable = venueCodable.menuItems {
                            for menuItemCodable in menuItemsCodable {
                                var menuItem = MenuItem.find(id: menuItemCodable.id, context: context)
                                if menuItem == nil {
                                    menuItem = MenuItem(context: context)
                                }
                                menuItem?.codable = menuItemCodable
                                menuItem?.venue = venue
                            }
                        }
                        if let reviewsCodable = venueCodable.reviews {
                            for reviewCodable in reviewsCodable {
                                var review = Review.find(id: reviewCodable.id, context: context)
                                if review == nil {
                                    review = Review(context: context)
                                }
                                review?.codable = reviewCodable
                                review?.venue = venue
                            }
                        }
                        do {
                            try context.save()
                        } catch {
                            assertionFailure(error.localizedDescription)
                        }
                    }
                })
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        
        networkCounter += 1
        task.resume()
        
    }
    
    
    
}
