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
            
            let tourModel = TourModel()
            tourModel.delegate = self
            tourModel.downloadItems()
        }

    @IBAction func random(_ sender: Any) {
    }
    
    @IBAction func search(_ sender: Any) {
    }
    
    @IBAction func photos(_ sender: Any) {
    }
    
    func itemsDownloaded(items: [TourModel]) {
                tours = items
                collectionView.reloadData()
        }
    
        func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
           URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
        }
    
        func downloadImage(from url: URL, cell: TourCollectionViewCell) {
            getData(from: url) { data, response, error in
                  guard let data = data, error == nil else {
                     return
                  }
                  DispatchQueue.main.async() {
                    cell.poster.image = UIImage(data: data)
                  }
            }
        }
}

extension ToursViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView
          .dequeueReusableCell(withReuseIdentifier: "TourCell", for: indexPath) as! TourCollectionViewCell
        //cell.backgroundColor = .black
        // Configure the cell
        let tour = tours[indexPath.row]
        cell.lblYear.text = "\(tour.year)"
        let url = URL(string: tour.poster!)
        downloadImage(from: url!, cell: cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Shows") as! ShowsViewController
        vc.year = "\(tours[indexPath.row].year)"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIViewController {
    func showAlert(msg: String) {
        let alert = UIAlertController(title: "DC Shows", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
