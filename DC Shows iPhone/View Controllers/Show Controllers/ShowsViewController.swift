//
//  ShowsViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/6/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit

class ShowsViewController: UIViewController, ShowModelProtocol {
    
    var searchStr: String? = ""
    var year: String?
    var shows: [ShowModel] = []

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let showModel = ShowModel()
        showModel.delegate = self
        if searchStr != "" {
            // Searching
            showModel.search(searchStr: searchStr!)
        }
        else {
            // Selected a tour
            showModel.downloadItems(year: year!)
        }
    }
    
    func itemsDownloaded(items: [ShowModel]) {
        shows = items
        collectionView.reloadData()
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
       URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
     func downloadImage(from url: URL, cell: ShowCollectionViewCell) {
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

extension ShowsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
          .dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as! ShowCollectionViewCell
        let show = shows[indexPath.row]
        cell.lblDate.text = "\(show.showDate!)"
        cell.lblLocation.text = "\(show.location!)"
        let url = URL(string: show.poster!)
        downloadImage(from: url!, cell: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Show") as! ShowViewController
        vc.showID = "\(shows[indexPath.row].id)"
        navigationController?.pushViewController(vc, animated: true)
    }

}
