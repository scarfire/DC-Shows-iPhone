//
//  TourModel.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import Foundation

protocol TourModelProtocol: class {
    func itemsDownloaded(items: [TourModel])
}

class TourModel {
    var year: Int = 0
    var poster: String? = ""
    
    weak var delegate: TourModelProtocol!
        
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
    
    func downloadItems(serverDataSource: String) {
        if serverDataSource == "PHP" {
            downloadFromPHP()
        }
    }
}

