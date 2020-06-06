//
//  ShowModel.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import Foundation

protocol ShowModelProtocol: class {
    func itemsDownloaded(items: [ShowModel])
}

class ShowModel: NSObject {
    var id: Int = 0
    var location: String? = ""
    var showDate: String? = ""
    var poster: String? = ""

    weak var delegate: ShowModelProtocol!

    func downloadItems(year: String) {
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
}
