//
//  ShowViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/4/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit
import CoreData

class ShowViewController: UIViewController {

    var showID: String?
    var showDate: String?
    var searchStr: String?
    var setList: [SongModel] = []
    var defaultAudio: String?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblBuilding: UILabel!
    @IBOutlet weak var btnAudio: UIBarButtonItem!
    
    let showDetailModel = CoreDataShow()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        if searchStr != nil {
            // Called from a search
            return
        }
        if showID == nil {
            // Random - need random ID first
            //showDetailModel.getRandomShowID()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if showID != nil {
            // Coming from Shows - load show details
            if let show = loadShowDetails() {
                refreshUI(show: show)
            }
        }
    }

    func loadShowDetails() -> CoreDataShow? {
        // Load show details from Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Show")
        let sort = NSSortDescriptor(key: "date_show", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "show_id == %@", showID!.description)
        do {
          let showsResult = try managedContext.fetch(request)
            for data in showsResult as [NSManagedObject] {
                var show = CoreDataShow()
                show.showID = data.value(forKey: "show_id") as! Int
                show.location = data.value(forKey: "city_state_country") as! String
                show.printDate = data.value(forKey: "date_printed") as! String
                show.poster = data.value(forKey: "poster") as! String
                show.building = data.value(forKey: "building") as! String
                show.defaultAudio = data.value(forKey: "default_audio") as! String
                show.user_rating = data.value(forKey: "user_rating") as! Int
                show.user_notes = data.value(forKey: "user_notes") as! String
                show.user_audio = data.value(forKey: "user_audio") as! String
                show.user_attended = data.value(forKey: "user_attended") as! String
                return show
            }
        }
        catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
        return nil
    }
    
    func refreshUI(show: CoreDataShow) {
        showID = String(show.showID)
        if show.user_audio != "" {
            defaultAudio = show.user_audio
        }
        else {
            defaultAudio = show.defaultAudio
        }
        if defaultAudio == "" {
            btnAudio.isEnabled = false
        }
        else {
            btnAudio.isEnabled = true
        }
        lblDate.text  = show.printDate
        lblCity.text = show.location
        lblBuilding.text = show.building
        lblRating.text = (show.user_rating > 0) ? String(show.user_rating) : "Unrated"
        let url = URL(string: show.poster)
        downloadImage(from: url!)
    }
    
    @IBAction func edit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "ShowEdit") as! ShowEditViewController
        vc.showID = showID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func posterTapped(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func photos(_ sender: Any) {
    }
    
    @IBAction func videos(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "Videos") as! VideosViewController
        vc.showID = showID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func audio(_ sender: Any) {
        if let url = URL(string: "\(defaultAudio!)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func random(_ sender: Any) {
       // showDetailModel.getRandomShowID()
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
       // showDetailModel.getAdjacentShow(showDate: showDate!, showType: "Next")
    }
    
    @IBAction func swipeRight(_ sender: Any) {
       // showDetailModel.getAdjacentShow(showDate: showDate!, showType: "Previous")
    }
    
    func setListDownloaded(setList: [SongModel]) {
        self.setList = setList
        tableView.reloadData()
        let topRow = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
    
    func sendMessage(msg: String)
    {
        showAlert(msg: msg)
    }
    
}

extension ShowViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        if setList[indexPath.row].set == "T" {
            // Title row
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.white
        }
        else {
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.black
            if setList[indexPath.row].set == "N" {
                // Notes cell - needs to be bigger than one line
                cell.textLabel?.numberOfLines = 20
            }
        }
        cell.textLabel?.text = setList[indexPath.row].title!
        return cell
    }
}

extension ShowViewController {
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
       URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
     func downloadImage(from url: URL) {
       getData(from: url) {
          data, response, error in
          guard let data = data, error == nil else {
             return
          }
          DispatchQueue.main.async() {
            self.imgPoster.image = UIImage(data: data)
          }
       }
    }
}
