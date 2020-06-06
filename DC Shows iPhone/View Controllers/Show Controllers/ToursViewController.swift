//
//  ToursViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/6/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit

class ToursViewController: UIViewController, TourModelProtocol {
    @IBOutlet weak var collectionView: UICollectionView!
    var tours: [TourModel] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            collectionView.delegate = self
            collectionView.dataSource = self

            let tourModel = TourModel()
            tourModel.delegate = self
            tourModel.downloadItems()
        }

        func itemsDownloaded(items: [TourModel]) {
                tours = items
            collectionView.reloadData()
    //            let tour = tours[2]
    //            print(tour.poster!)
        }
}

extension ToursViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
          .dequeueReusableCell(withReuseIdentifier: "TourCell", for: indexPath)
        cell.backgroundColor = .black
        // Configure the cell
        return cell
    }
    
    
}
