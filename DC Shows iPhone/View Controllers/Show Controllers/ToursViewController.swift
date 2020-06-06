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

        func itemsDownloaded(items: [TourModel]) {
                tours = items
                collectionView.reloadData()
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
        let imgView = UIImageView()
        imgView.downloadImage(from: url!, cell: cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tour = tours[indexPath.row]
        let year = "\(tour.year)"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Shows") as! ShowsViewController
        vc.year = year
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIImageView {
   func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
      URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
   }
    func downloadImage(from url: URL, cell: TourCollectionViewCell) {
      getData(from: url) {
         data, response, error in
         guard let data = data, error == nil else {
            return
         }
         DispatchQueue.main.async() {
            cell.poster.image = UIImage(data: data)
         }
      }
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
