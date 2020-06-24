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
    var showIDs = [Int]()
    var shows = [ShowModel]()

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
            self.delegate.itemsDownloaded(items: self.shows)
        })
    }

    fileprivate func searchFireBase(searchStr: String) {
        getShowsForSearchFromFireBase(searchStr: searchStr)
    }

    func getShowForFireBase(showID: Int) {
        let db = getDBReference()
        db.collection("shows").whereField("show_id", isEqualTo: showID).getDocuments() { (querySnapshot, error) in
           guard let documents = querySnapshot?.documents else {
               print("Error fetching documents: \(error!)")
               return
           }

            for doc in documents {
                let show = ShowModel()
                if let showDate = doc.data()["showdate"] as? String,
                    let poster = doc.data()["poster"] as? String,
                    let location = doc.data()["city_state_country"] as? String
                {
                    show.id = showID
                    show.showDate = showDate
                    show.location = location
                    show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
                }
                self.shows.append(show)
                if showID == self.showIDs[self.showIDs.count-1] {
                    // Done getting all shows - display
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.delegate.itemsDownloaded(items: self.shows)
                    })
                }
            }
        }
    }

    func getShowsForSearchFromFireBase(searchStr: String) {
        // Get shows where searched song exists
        let db = getDBReference()
        // Find shows with selected song
        db.collection("set_lists").whereField("title", isEqualTo: "Terrapin Station").getDocuments() { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            for doc in documents {
                if let showID = doc.data()["show_id"] as? Int
                {
                    // get all shows that match
                    self.showIDs.append(showID)
                }
            }
            if self.showIDs.count > 0 {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.searchedShowsMatched()
                })
            }
        }
    }
    
    func searchedShowsMatched() {
        for showID in showIDs {
            getShowForFireBase(showID: showID)
        }
    }
    
    func search(searchStr: String, serverDataSource: String) {
        if serverDataSource == "PHP" {
            searchPHP(searchStr)
        }
        else {
            searchFireBase(searchStr: searchStr)
        }
    }

    fileprivate func downloadFromPHP(year: String) {
        // Get shows for tour year
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getshowsfortour.php?year=\(year)")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        
        var jsonElement = NSDictionary()
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
            self.shows.append(show)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.itemsDownloaded(items: self.shows)
        })
    }
    
    func downloadFromFireBase(year: String) {
        let db = getDBReference()
        db.collection("shows").order(by: "rawdate", descending: false).getDocuments() { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            for doc in documents {
                let show = ShowModel()
                if let showDate = doc.data()["showdate"] as? String,
                    let poster = doc.data()["poster"] as? String,
                    let showID = doc.data()["show_id"] as? Int,
                    let location = doc.data()["city_state_country"] as? String
                {
                    show.id = showID
                    show.showDate = showDate
                    show.location = location
                    show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
                }
                self.shows.append(show)
            }
            DispatchQueue.main.async(execute: { () -> Void in
                self.delegate.itemsDownloaded(items: self.shows)
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
