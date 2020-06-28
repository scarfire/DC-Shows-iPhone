//
//  ToursViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/6/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ToursViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var tours: [CoreDataTour] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self

        // Load from PHP
//        let core = CoreDataLocal()
//        core.downloadData()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let tourFetch = NSFetchRequest<NSManagedObject>(entityName: "Tour")
        let sort = NSSortDescriptor(key: "year", ascending: false)
        tourFetch.sortDescriptors = [sort]
        do {
          let toursResult = try managedContext.fetch(tourFetch)
            for data in toursResult as [NSManagedObject] {
                //print(data.value(forKey: "year") as! Int)
                var tour = CoreDataTour()
                tour.year = data.value(forKey: "year") as! Int
                tour.poster = data.value(forKey: "poster") as! String
                tours.append(tour)
            }
        }
        catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text  == "" {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Shows") as! ShowsViewController
        vc.searchStr = searchBar.text
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func random(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Show") as! ShowViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func search(_ sender: Any) {
    }
    
    @IBAction func photos(_ sender: Any) {
    }
    
//    func itemsDownloaded(items: [TourModel]) {
//        tours = items
//        collectionView.reloadData()
//    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
       URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func downloadImage(from url: URL, cell: TourCollectionViewCell) {
downloadImage(from: <#T##URL#>, cell: <#T##TourCollectionViewCell#>)
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
        let url = URL(string: tour.poster)
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
    
    func writeImageToDocs(image:UIImage, url: URL){
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

        let fileName = url.lastPathComponent
        let destinationPath = URL(fileURLWithPath: documentsPath).appendingPathComponent(fileName)

        debugPrint("destination path is",destinationPath)

        do {
            try image.pngData()?.write(to: destinationPath)
        } catch {
            debugPrint("writing file error", error)
        }
    }

    func readImageFromDocs(url: URL)->UIImage?{
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let fileName = url.lastPathComponent
        let filePath = URL(fileURLWithPath: documentsPath).appendingPathComponent(fileName).path
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        } else {
            return nil
        }
    }
}
