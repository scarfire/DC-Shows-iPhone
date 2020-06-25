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
    }
    
    func downloadShows() {
        // Get shows for tour year
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
