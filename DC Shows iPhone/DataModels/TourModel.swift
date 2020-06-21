//
//  TourModel.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import Foundation
import Firebase

protocol TourModelProtocol: class {
    func itemsDownloaded(items: [TourModel])
}

class TourModel {
    var year: Int = 0
    var poster: String? = ""
    
    weak var delegate: TourModelProtocol!
    
    func getDBReference() -> Firestore {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.isPersistenceEnabled = false
        db.settings = settings
        return db
    }
    
    fileprivate func downloadFromPHP() {
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/gettours.php?userid=738792812")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        
        var jsonElement = NSDictionary()
        var tours = [TourModel]()
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            let tour = TourModel()
            if let year = jsonElement["year"] as? Int,
                let poster = jsonElement["poster"] as? String {
                tour.year = year
                tour.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
            }
            tours.append(tour)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.itemsDownloaded(items: tours)
        })
    }
    
    func downloadFromFireBase() {
        let db = getDBReference()
        db.collection("tours").order(by: "year", descending: true).getDocuments() { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            var tours = [TourModel]()
            for doc in documents {
                let tour = TourModel()
                if let year = doc.data()["year"] as? Int, let poster = doc.data()["poster"] as? String {
                    tour.year = year
                    tour.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
                }
                tours.append(tour)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.delegate.itemsDownloaded(items: tours)
            })
        }
    }
    
    func downloadItems(serverDataSource: String) {
        if serverDataSource == "PHP" {
            downloadFromPHP()
        }
        else {
            downloadFromFireBase()
        }
    }
}

