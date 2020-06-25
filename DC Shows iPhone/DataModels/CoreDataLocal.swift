//
//  CoreData.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/24/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//
// This model is used to pull shows and set lists data from MySQL Server and into local Core Data file

import Foundation
import CoreData
import UIKit

struct CoreDataTour {
    var year: Int = 0
    var poster: String = ""
}

struct CoreDataShow {
    var showID: Int = 0
    var location: String = ""
    var building: String = ""
    var defaultAudio: String = ""
    var poster: String = ""
    var showDate: String = ""
    var printDate: String = ""
}

struct CoreDataSetList {
    var showID: Int = 0
    var songID: Int = 0
    var title: String = ""
    var setNumber: String = ""
}

class CoreDataLocal {

    func downloadData() {
        downloadTours()
        downloadShows()
        downloadSetLists()
    }
    
    func downloadTours() {
        // Download all tours
        /*
                 [{"year":2015,"poster":"2015nashville.png"},{"year":2016,"poster":"2016camden.png"},{"year":2017,"poster":"2017mountainview.png"},{"year":2018,"poster":"2018neworleans.png"},{"year":2019,"poster":"2019saratoga.png"},{"year":2020,"poster":"2020mexico.png"}]
                */
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/gettoursforCoreData.php?last_updated=2000-01-01")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

        var jsonElement = NSDictionary()
        var tours = [CoreDataTour]()
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            var tour = CoreDataTour()
            if let year = jsonElement["year"] as? Int,
                let poster = jsonElement["poster"] as? String {
                tour.year = year
                tour.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
            }
            tours.append(tour)
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           return
        }
         
        let managedContext = appDelegate.persistentContainer.viewContext
        for t in tours {
            let entity = NSEntityDescription.entity(forEntityName: "Tour", in: managedContext)!
            let tour = NSManagedObject(entity: entity, insertInto: managedContext)
            tour.setValue(Int16(t.year), forKey: "year")
            tour.setValue(t.poster, forKeyPath: "poster")
            do {
               try managedContext.save()
            }
            catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func downloadShows() {
        // Get all shows
        /*
                [{"id":87,"title":"Bertha","set_number":"1"},{"id":88,"title":"Good Lovin'","set_number":"1"},{"id":89,"title":"Shakedown Street","set_number":"1"},{"id":90,"title":"They Love Each Other","set_number":"1"},{"id":91,"title":"Black-Throated Wind","set_number":"1"},{"id":92,"title":"Mr. Charlie","set_number":"1"},{"id":93,"title":"Mississippi Half-Step Uptown Toodeloo","set_number":"1"},{"id":94,"title":"Throwing Stones","set_number":"1"},{"id":95,"title":"Althea","set_number":"2"},{"id":96,"title":"Estimated Prophet","set_number":"2"},{"id":97,"title":"Eyes of the World","set_number":"2"},{"id":98,"title":"Terrapin Station","set_number":"2"},{"id":99,"title":"Drums","set_number":"2"},{"id":100,"title":"Space","set_number":"2"},{"id":101,"title":"My Favorite Things","set_number":"2"},{"id":102,"title":"Days Between","set_number":"2"},{"id":103,"title":"China Cat Sunflower","set_number":"2"},{"id":104,"title":"I Know You Rider","set_number":"2"},{"id":105,"title":"Touch of Grey","set_number":"E"}]
                */
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getshowsforCoreData.php?last_updated=2000-01-01")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

        var jsonElement = NSDictionary()
        var shows = [CoreDataShow]()
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            var show = CoreDataShow()
            if let showID = jsonElement["show_id"] as? Int,
                let location = jsonElement["city_state_country"] as? String,
                let showDate = jsonElement["date_show"] as? String,
                let datePrinted = jsonElement["date_printed"] as? String,
                let building = jsonElement["building"] as? String,
                let defaultAudio = jsonElement["default_audio"] as? String,
                let poster = jsonElement["poster"] as? String {
                    show.showID = showID
                    show.showDate = showDate
                    show.printDate = datePrinted
                    show.building = building
                    show.location = location
                    show.defaultAudio = defaultAudio
                    show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
            }
            shows.append(show)
        }
    }
    
    func downloadSetLists() {
        // Download all set lists
        /*
                [{"show_id":70,"date_show":"2015-10-29","date_printed":"Oct 29, 2015","city_state_country":"Albany, NY","building":"Times Union Center","default_audio":"https:\/\/archive.org\/details\/10-29-15DeadAndCompanyTimesUnionCenterAlbanyNy","poster":"2015albany.png"},{"show_id":71,"date_show":"2015-10-31","date_printed":"Oct 31, 2015","city_state_country":"New York, NY","building":"Madison Square Garden","default_audio":"https:\/\/archive.org\/details\/Dc20151031.14.eyesOfTheWorld","poster":"2015newyorkcity.png"},{"show_id":82,"date_show":"2015-11-01","date_printed":"Nov 01, 2015","city_state_country":"New York, NY","building":"Madison Square Garden","default_audio":"https:\/\/archive.org\/details\/DeadCo.11-1-2015MSG","poster":"2015newyorkcity.png"}
                */
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getsetlistsforCoreData.php?last_updated=2000-01-01")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

        var jsonElement = NSDictionary()
        var setLists = [CoreDataSetList]()
        //var previousSet = ""
        
        // Loop through each song in set list
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary

            // Create and populate song
            var song = CoreDataSetList()
            if let title = jsonElement["title"] as? String,
                let showID = jsonElement["show_id"] as? Int,
                let setNumber = jsonElement["set_number"] as? String,
                let songID = jsonElement["id"] as? Int {
                    song.title = title
                    song.showID = showID
                    song.setNumber = setNumber
                    song.songID = songID
            }
            
//            if previousSet != song.setNumber {
//                // Set changed - add an extra set title row to set list and a blank above if not changing to 1st set
//                switch song.setNumber {
//                    case "1":
//                        AddSetTitle(set: song.setNumber!, setList: &setLists)
//                    case "2", "3", "E":
//                        AddBlankRow(&setList)
//                        AddSetTitle(set: song.setNumber!, setList: &setLists)
//                    default:
//                        break
//                }
//                previousSet = song.set!
//            }
            setLists.append(song)
        }
//        AddNotesSection(&setList)
//        DispatchQueue.main.async(execute: { () -> Void in
//            self.delegate.setListDownloaded(setList: setLists)
//        })
    }
//
//    fileprivate func getSetName(setNumber: String) -> String {
//        switch setNumber {
//        case "1":
//            return "1st Set"
//        case "2":
//            return "2nd Set"
//        case "3":
//            return "3rd Set"
//        case "Notes":
//            return "Notes"
//        default:
//            return "Encore"
//        }
//    }
//
//    fileprivate func AddSetTitle(setNumber: String, setList: inout [SongModel]) {
//        let song = SongModel()
//        song.title = getSetName(setNumber: setNumber)
//        song.set = "T" // Title
//        setList.append(song)
//    }
//
//    fileprivate func AddBlankRow(_ setList: inout [SongModel]) {
//        let song = SongModel()
//        song.title = ""
//        song.set = "B" // Blank
//        setList.append(song)
//    }
//
//    fileprivate func AddNotesSection(_ setList: inout [SongModel]) {
//        AddBlankRow(&setList)
//        AddSetTitle(set: "Notes", setList: &setLists)
//        AddNotes(&setList)
//    }
//
//    fileprivate func AddNotes(_ setList: inout [SongModel]) {
//        let song = SongModel()
//        song.title = ""
//        song.set = "N"
//        setList.append(song)
//    }
}