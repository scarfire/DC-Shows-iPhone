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
    var setList: [CoreDataSetList] = []
    var show = CoreDataShow()
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
            setRandomShowID()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if showID != nil {
            // Coming from Shows - load show details
            if let show = loadShowDetails() {
                refreshUI(show: show)
            }
            loadSetLists()
        }
    }

    func loadSetLists() {
       // Load set lists for show from Core Data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "SetList")
        let sort = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "show_id == %@", showID!.description)
        do {
            var previousSet: String = ""
            let result = try managedContext.fetch(request)
            for data in result as [NSManagedObject] {
                var song = CoreDataSetList()
                song.title = data.value(forKey: "title") as! String
                song.setNumber = data.value(forKey: "set_number") as! String
                if previousSet != song.setNumber {
                    // Set changed - add an extra set title row to set list and a blank above if not changing to 1st set
                    switch song.setNumber {
                        case "1":
                            AddSetTitle(setNumber: song.setNumber)
                        case "2", "3", "E":
                            AddBlankRow()
                            AddSetTitle(setNumber: song.setNumber)
                        default:
                            break
                    }
                    previousSet = song.setNumber
                }
                setList.append(song)
            }

        }
        catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
        // Load table view
        tableView.reloadData()
        let topRow = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
    
    fileprivate func getSetName(setNumber: String) -> String {
        switch setNumber {
        case "1":
            return "1st Set"
        case "2":
            return "2nd Set"
        case "3":
            return "3rd Set"
        case "Notes":
            return "Notes"
        default:
            return "Encore"
        }
    }
    
    fileprivate func AddSetTitle(setNumber: String) {
        var song = CoreDataSetList()
        song.title = getSetName(setNumber: setNumber)
        song.setNumber = "T" // Title
        setList.append(song)
    }
    
    fileprivate func AddBlankRow() {
        var song = CoreDataSetList()
        song.title = ""
        song.setNumber = "B" // Blank
        setList.append(song)
    }
    
    fileprivate func AddNotesSection() {
        AddBlankRow()
        AddSetTitle(setNumber: "Notes")
        AddNotes()
    }

    fileprivate func AddNotes() {
        var song = CoreDataSetList()
        song.title = show.user_notes
        song.setNumber = "N"
        setList.append(song)
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
          let result = try managedContext.fetch(request)
            for data in result as [NSManagedObject] {
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
    
    func setRandomShowID() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject>(entityName: "Show")
        do {
          let result = try managedContext.fetch(request)
          let randomIndex = Int.random(in: 0..<result.count)
          let data = result[randomIndex]
          let id = data.value(forKey: "show_id") as! Int
          showID = String(id)
          print("Show ID:  " + showID!)
        }
        catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
            return
        }
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
       setRandomShowID()
       if let show = loadShowDetails() {
           refreshUI(show: show)
       }
       loadSetLists()
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
       // showDetailModel.getAdjacentShow(showDate: showDate!, showType: "Next")
    }
    
    @IBAction func swipeRight(_ sender: Any) {
       // showDetailModel.getAdjacentShow(showDate: showDate!, showType: "Previous")
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
        if setList[indexPath.row].setNumber == "T" {
            // Title row
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.white
        }
        else {
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.black
            if setList[indexPath.row].setNumber == "N" {
                // Notes cell - needs to be bigger than one line
                cell.textLabel?.numberOfLines = 20
            }
        }
        cell.textLabel?.text = setList[indexPath.row].title
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
