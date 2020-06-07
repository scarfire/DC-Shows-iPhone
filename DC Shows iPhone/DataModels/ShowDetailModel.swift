//
//  ShowDetailModel.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/6/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit

protocol ShowDetailsModelProtocol: class {
    func detailsDownloaded(show: ShowDetailModel)
    func setListDownloaded(setList: [SongModel])
}

class ShowDetailModel: NSObject {
    var id: Int = 0
    var location: String? = ""
    var building: String? = ""
    var showDate: String? = ""
    var poster: String? = ""
    var defaultAudio: String? = ""
   
    weak var delegate: ShowDetailsModelProtocol!
 
    func downloadDetails(id: String) {
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getshow.php?show_id=\(id)")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

        var jsonElement = NSDictionary()
        jsonElement = jsonResult[0] as! NSDictionary
        let show = ShowDetailModel()
        if let id = jsonElement["id"] as? Int,
            let location = jsonElement["city_state_country"] as? String,
            let building = jsonElement["building"] as? String,
            let showDate = jsonElement["showdate"] as? String,
            let audio = jsonElement["audio"] as? String,
            let poster = jsonElement["poster"] as? String {
            show.id = id
            show.showDate = showDate
            show.location = location
            show.building = building
            show.defaultAudio = audio
            show.poster = "https://toddlstevens.com/apps/dcshows/images/posters/\(poster)"
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.detailsDownloaded(show: show)
        })
    }
    
    func downloadSetList(id: String) {
        let url = URL(string: "https://toddlstevens.com/apps/dcshows/mobile/server/getsetlist.php?show_id=\(id)")
        let data = try? Data(contentsOf: url!)
        let jsonResult = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray

        var jsonElement = NSDictionary()
        var setList = [SongModel]()
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            let song = SongModel()
            if let id = jsonElement["id"] as? Int,
                let title = jsonElement["title"] as? String,
                let set = jsonElement["set"] as? String {
                song.id = id
                song.title = title
                song.set = set
            }
            setList.append(song)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.setListDownloaded(setList: setList)
        })
    }
}
