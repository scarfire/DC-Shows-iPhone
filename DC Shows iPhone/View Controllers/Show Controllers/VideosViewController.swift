//
//  VideosViewController.swift
//  DC Shows iPhone
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//
//  Uses Core Data to store user video links

import UIKit
import CoreData

class VideosViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var showID: String?
    var videos: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let showDetailsFetch = NSFetchRequest<NSManagedObject>(entityName: "Video")

        do {
          let intShowID = Int16(showID!)!
          showDetailsFetch.predicate = NSPredicate(format: "show_id == %i", intShowID)
          videos = try managedContext.fetch(showDetailsFetch)
        }
        catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }
    
     @IBAction func back(_ sender: Any) {
         navigationController?.popViewController(animated: true)
     }
     
     @IBAction func add(_ sender: Any) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let vc = storyboard.instantiateViewController(identifier: "AddVideo") as! AddVideoViewController
         vc.showID = showID
         navigationController?.pushViewController(vc, animated: true)
     }

}

extension VideosViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        let video = videos[indexPath.row]
        cell.textLabel?.text = video.value(forKeyPath: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let video = videos[indexPath.row]
        let url = video.value(forKeyPath: "url") as? String
        if let url = URL(string: url!) {
            UIApplication.shared.open(url)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                let video = videos[indexPath.row]
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                // Delete video from Managed Context
                managedContext.delete(video)
                // Delete video from array
                videos.remove(at: indexPath.row)
                // Delete video from table view
                tableView.deleteRows(at: [indexPath], with: .fade)
                try managedContext.save()
             }
             catch let error as NSError {
                print("Could not delete video. \(error), \(error.userInfo)")
             }
        }
    }
}
