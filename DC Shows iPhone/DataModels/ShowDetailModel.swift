//
//  ShowDetailModel.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/6/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit
import CoreData

protocol ShowDetailsModelProtocol: class {
    func detailsDownloaded(show: ShowDetailModel)
    func setListDownloaded(setList: [SongModel])
    func sendMessage(msg: String)
//    func notesDownloaded(notes: String)
}

class ShowDetailModel: NSObject {
    var id: String?
    var location: String? = ""
    var building: String? = ""
    var showDate: String? = ""
    var showDatePrint: String? = ""
    var poster: String? = ""
    var defaultAudio: String? = ""
    var previousSet: String = ""
    var notes: String? = ""
    
    weak var delegate: ShowDetailsModelProtocol!
 
    func getNotes() {
        // Load notes from Core Data
        do {
            let intShowID = Int16(id!)
            notes = ""
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let showDetailsFetch = NSFetchRequest<NSManagedObject>(entityName: "ShowDetails")
            showDetailsFetch.predicate = NSPredicate(format: "showID == %i", intShowID!)
            let shows = try managedContext.fetch(showDetailsFetch)
            if shows.count > 0 {
                // Object exists - grab 1st in case of multiples
                let show = shows.first!
                notes = show.value(forKeyPath: "notes") as? String
                notes = notes ?? ""
            }
//            DispatchQueue.main.async(execute: { () -> Void in
//                self.delegate.notesDownloaded(notes: self.notes!)
//            })
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getAdjacentShow(showDate: String, showType: String) {
        var url: URL?
        var alert: String?
        if showType == "Next" {
            // Next show
            url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getnextshow.php?show_date=\(showDate)")
            alert = "This is the last show"
        }
        else {
            // Previous show
            url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getpreviousshow.php?show_date=\(showDate)")
            alert = "This is the first show"
        }
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        if jsonResult.count > 0 {
            // Next show found
            let jsonElement = jsonResult[0] as! NSDictionary
            let id = jsonElement["id"] as? Int
            self.id =  "\(id!)"
            DispatchQueue.main.async(execute: { () -> Void in
                self.getNotes()
                self.downloadDetails()
                self.downloadSetList()
            })
        }
        else {
            self.delegate?.sendMessage(msg: alert!)
        }
    }

    func getRandomShowID() {
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getrandomshow.php")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
        var jsonElement = NSDictionary()
        jsonElement = jsonResult[0] as! NSDictionary
        if let id = jsonElement["id"] as? Int {
            self.id = "\(id)"
            DispatchQueue.main.async(execute: { () -> Void in
                self.getNotes()
                self.downloadDetails()
                self.downloadSetList()
            })
        }
    }
    
    func downloadDetails() {
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getshow.php?show_id=\(id!)")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

        var jsonElement = NSDictionary()
        jsonElement = jsonResult[0] as! NSDictionary
        let show = ShowDetailModel()
        if let id = jsonElement["id"] as? Int,
            let location = jsonElement["city_state_country"] as? String,
            let building = jsonElement["building"] as? String,
            let showDate = jsonElement["show_date"] as? String,
            let showDatePrint = jsonElement["showdate"] as? String,
            let audio = jsonElement["audio"] as? String,
            let poster = jsonElement["poster"] as? String {
            show.id = "\(id)"
            show.showDate = showDate
            show.showDatePrint = showDatePrint
            show.location = location
            show.building = building
            show.defaultAudio = audio
            show.notes = notes!
            show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.detailsDownloaded(show: show)
        })
    }
    
    func downloadSetList() {
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getsetlist.php?show_id=\(id!)")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

        var jsonElement = NSDictionary()
        var setList = [SongModel]()

        // Loop through each song in set list
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary

            // Create and populate song
            let song = SongModel()
            if let title = jsonElement["title"] as? String,
                let set = jsonElement["set_number"] as? String {
                song.title = title
                song.set = set
            }
            
            if previousSet != song.set! {
                // Set changed - add an extra set title row to set list and a blank above if not changing to 1st set
                switch song.set! {
                    case "1":
                        AddSetTitle(set: song.set!, setList: &setList)
                    case "2", "3", "E":
                        AddBlankRow(&setList)
                        AddSetTitle(set: song.set!, setList: &setList)
                    default:
                        break
                }
                previousSet = song.set!
            }
            setList.append(song)
        }
        AddNotesSection(&setList)
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.setListDownloaded(setList: setList)
        })
    }
    
    fileprivate func getSetName(set: String) -> String {
        switch set {
        case "1":
            return "1st Set"
        case "2":
            return "2nd Set"
        case "3":
            return "3rd Set"
        case "Notes":
            return "Notes"
        default:
            return "Encore"
        }
    }
    
    fileprivate func AddSetTitle(set: String, setList: inout [SongModel]) {
        let song = SongModel()
        song.title = getSetName(set: set)
        song.set = "T" // Title
        setList.append(song)
    }
    
    fileprivate func AddBlankRow(_ setList: inout [SongModel]) {
        let song = SongModel()
        song.title = ""
        song.set = "B" // Blank
        setList.append(song)
    }
    
    fileprivate func AddNotesSection(_ setList: inout [SongModel]) {
        AddBlankRow(&setList)
        AddSetTitle(set: "Notes", setList: &setList)
        AddNotes(&setList)
    }

    fileprivate func AddNotes(_ setList: inout [SongModel]) {
        let song = SongModel()
        song.title = notes!
        song.set = "N"
        setList.append(song)
    }
}
