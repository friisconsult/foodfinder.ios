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

class Cloud {
    static let shared:Cloud = Cloud()
    
    var persistentContainer:NSPersistentContainer! {
        didSet{
            persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        }
    }
    
    let apiUrl:URL
    let apiKey:String
    
    init() {
        guard let apiUrlString = Bundle.main.object(forInfoDictionaryKey: "api_url") as? String,
            let apiKey = Bundle.main.object(forInfoDictionaryKey: "api_key") as? String else {
            fatalError("error with the url")
        }
        self.apiUrl = URL(string:apiUrlString)!
        self.apiKey = apiKey
    }
    
    
    func baseRequest( path:String, method:String = "GET") -> URLRequest {
        
        var baseRequest = URLRequest(url: apiUrl.appendingPathComponent(path))
        baseRequest.httpMethod = method
        baseRequest.addValue("Agrajag", forHTTPHeaderField:"FC-APPLICATION-KEY")
        
        return baseRequest
    }
    

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
        
        dataTask.resume()
    }
    
}
