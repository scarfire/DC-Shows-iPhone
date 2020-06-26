//
//  ShowsViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/6/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit
import CoreData

class ShowsViewController: UIViewController {
    
    var searchStr: String? = ""
    var year: String?
    var shows: [CoreDataShow] = []

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if searchStr != "" {
            // Searching
           searchShows(searchStr: searchStr!)
        }
        else {
            loadShows()
        }
    }

    func searchShows(searchStr: String) {
        // Search all set lists to get all show IDs containing selected string in title
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "SetList")
//        let sort = NSSortDescriptor(key: "date_show", ascending: true)
//        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "title CONTAINS[c] %@", searchStr)
        do {
          let showsResult = try managedContext.fetch(request)
            var searchShowIDs = [Int]()
            for data in showsResult as [NSManagedObject] {
                // Store matching show IDs
                searchShowIDs.append(data.value(forKey: "show_id") as! Int)
            }
            loadShows(searchShows: searchShowIDs)
        }
        catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func loadShows(searchShows: [Int]? = nil) {
        // Load shows for selected year from Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Show")
        let sort = NSSortDescriptor(key: "date_show", ascending: true)
        request.sortDescriptors = [sort]
        if searchShows == nil {
            // Load by year
            let intYear = Int(year!)!
            request.predicate = NSPredicate(format: "year == %i", intYear)
        }
        else {
            // Load by search
            request.predicate = NSPredicate(format: "show_id == %i ", 15)
        }
        do {
          let showsResult = try managedContext.fetch(request)
            for data in showsResult as [NSManagedObject] {
                var show = CoreDataShow()
                show.showID = data.value(forKey: "show_id") as! Int
                show.location = data.value(forKey: "city_state_country") as! String
                show.printDate = data.value(forKey: "date_printed") as! String
                show.poster = data.value(forKey: "poster") as! String
                show.year = data.value(forKey: "year") as! Int
                //show.showDate = data.value(forKey: "date_show") as! String
                shows.append(show)
            }
        }
        catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
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
        cell.lblDate.text = "\(show.printDate)"
        cell.lblLocation.text = "\(show.location)"
        let url = URL(string: show.poster)
        downloadImage(from: url!, cell: cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Show") as! ShowViewController
        vc.showID = "\(shows[indexPath.row].showID)"
        navigationController?.pushViewController(vc, animated: true)
    }

}
