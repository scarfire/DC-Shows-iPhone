//
//  ShowsViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/6/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit

class ShowsViewController: UIViewController, ShowModelProtocol {
    
    var year: String?
    var shows: [ShowModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let showModel = ShowModel()
        showModel.downloadItems(year: year!)
    }
    
    func itemsDownloaded(items: [ShowModel]) {
        shows = items
        showAlert(msg: "\(shows.count)")
    }

}
