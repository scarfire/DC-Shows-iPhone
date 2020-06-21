//
//  ShowModel.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import Foundation
import Firebase

protocol ShowModelProtocol: class {
    func itemsDownloaded(items: [ShowModel])
}

class ShowModel: NSObject {
    var id: Int = 0
    var location: String? = ""
    var showDate: String? = ""
    var poster: String? = ""

    weak var delegate: ShowModelProtocol!

    func getDBReference() -> Firestore {
        let db = Firestore.firestore()
        let settings = db.settings
        settings.isPersistenceEnabled = false
        db.settings = settings
        return db
    }

    fileprivate func searchPHP(_ searchStr: String) {
        // Get shows where searched song exists
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getsearchresults.php?search=\(searchStr)")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        
        var jsonElement = NSDictionary()
        var shows = [ShowModel]()
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            let show = ShowModel()
            if let id = jsonElement["id"] as? Int,
                let location = jsonElement["city_state_country"] as? String,
                let showDate = jsonElement["showdate"] as? String,
                let poster = jsonElement["poster"] as? String {
                show.id = id
                show.showDate = showDate
                show.location = location
                show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
            }
            shows.append(show)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.itemsDownloaded(items: shows)
        })
    }
    
    func search(searchStr: String, serverDataSource: String) {
        if serverDataSource == "PHP" {
            searchPHP(searchStr)
        }
    }

    fileprivate func downloadFromPHP(year: String) {
        // Get shows for tour year
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getshowsfortour.php?year=\(year)")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        
        var jsonElement = NSDictionary()
        var shows = [ShowModel]()
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            let show = ShowModel()
            if let id = jsonElement["id"] as? Int,
                let location = jsonElement["city_state_country"] as? String,
                let showDate = jsonElement["showdate"] as? String,
                let poster = jsonElement["poster"] as? String {
                show.id = id
                show.showDate = showDate
                show.location = location
                show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
            }
            shows.append(show)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.itemsDownloaded(items: shows)
        })
    }
    
    func downloadFromFireBase(year: String) {
        let db = getDBReference()
        db.collection("shows").whereField("year", isEqualTo: "2019").order(by: "show_date").getDocuments() { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            var shows = [ShowModel]()
            for doc in documents {
                let show = ShowModel()
                if let showDate = doc.data()["show_date"] as? String,
                    let poster = doc.data()["poster"] as? String,
                    let location = doc.data()["city_state_country"] as? String
                {
                    show.showDate = showDate
                    show.location = location
                    show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
                }
                shows.append(show)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.delegate.itemsDownloaded(items: shows)
            })
        }
    }
    
    func downloadItems(year: String, serverDataSource: String) {
        if serverDataSource == "PHP" {
            downloadFromPHP(year: year)
        }
        else {
            downloadFromFireBase(year: year)
        }
    }
}
