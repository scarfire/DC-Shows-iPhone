//
//  ToursViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit

class ToursViewController: UIViewController, TourModelProtocol {
    var tours: [TourModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tourModel = TourModel()
        tourModel.delegate = self
        tourModel.downloadItems()
//        let tour = tourItems[0] as! [String:Any]
//        print(tour["year"] as! Int)
//        print(tour["poster"] as! String)
    }

    func itemsDownloaded(items: [TourModel]) {
            tours = items
            let tour = tours[2]
            print(tour.poster!)
    }

}

