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
    var year: Int = 0
    var user_notes: String = ""
    var user_audio: String = ""
    var user_rating: Int = 0
    var user_attended: String = "N"
}

struct CoreDataSetList {
    var showID: Int = 0
    var id: Int = 0
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
        
        // Save tours to Core Data
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
                [{"show_id":70,"date_show":"2015-10-29","date_printed":"Oct 29, 2015","year":2015,"city_state_country":"Albany, NY","building":"Times Union Center","default_audio":"https:\/\/archive.org\/details\/10-29-15DeadAndCompanyTimesUnionCenterAlbanyNy","poster":"2015albany.png"},{"show_id":71,"date_show":"2015-10-31","date_printed":"Oct 31, 2015","year":2015,"city_state_country":"New York, NY","building":"Madison Square Garden","default_audio":"https:\/\/archive.org\/details\/Dc20151031.14.eyesOfTheWorld","poster":"2015newyorkcity.png"},{"show_id":82,"date_show":"2015-11-01","date_printed":"Nov 01, 2015","year":2015,"city_state_country":"New York, NY","building":"Madison Square Garden","default_audio":"https:\/\/archive.org\/details\/DeadCo.11-1-2015MSG","poster":"2015newyorkcity.png"}
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
                let year = jsonElement["year"] as? Int,
                let building = jsonElement["building"] as? String,
                let defaultAudio = jsonElement["default_audio"] as? String,
                let poster = jsonElement["poster"] as? String {
                    show.showID = showID
                    show.showDate = showDate
                    show.printDate = datePrinted
                    show.year = year
                    show.building = building
                    show.location = location
                    show.defaultAudio = defaultAudio
                    show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
            }
            shows.append(show)
        }
        
        // Save shows to Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           return
        }
         
        let managedContext = appDelegate.persistentContainer.viewContext
        for s in shows {
            let entity = NSEntityDescription.entity(forEntityName: "Show", in: managedContext)!
            let show = NSManagedObject(entity: entity, insertInto: managedContext)
            show.setValue(Int16(s.showID), forKey: "show_id")
            show.setValue(stringToDate(strDate: s.showDate), forKey: "date_show")
            show.setValue(s.printDate, forKey: "date_printed")
            show.setValue(s.building, forKey: "building")
            show.setValue(s.location, forKey: "city_state_country")
            show.setValue(s.defaultAudio, forKey: "default_audio")
            show.setValue(s.poster, forKeyPath: "poster")
            show.setValue(s.year, forKey: "year")
            show.setValue(0, forKey: "user_rating")
            show.setValue("N", forKey: "user_attended")
            show.setValue("", forKey: "user_audio")
            show.setValue("", forKey: "user_notes")
            do {
               try managedContext.save()
            }
            catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
            }
        }

    }
    
    func stringToDate(strDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: strDate) {
            return date
        }
        return Date()
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
                let id = jsonElement["id"] as? Int {
                    song.title = title
                    song.showID = showID
                    song.setNumber = setNumber
                    song.id = id
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
        
        // Save set lists to Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           return
        }
         
        let managedContext = appDelegate.persistentContainer.viewContext
        for s in setLists {
            let entity = NSEntityDescription.entity(forEntityName: "SetList", in: managedContext)!
            let show = NSManagedObject(entity: entity, insertInto: managedContext)
            show.setValue(Int32(s.id), forKey: "id")
            show.setValue(Int16(s.showID), forKey: "show_id")
            show.setValue(s.title, forKey: "title")
            show.setValue(s.setNumber, forKey: "set_number")
            do {
               try managedContext.save()
            }
            catch let error as NSError {
               print("Could not save. \(error), \(error.userInfo)")
            }
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
