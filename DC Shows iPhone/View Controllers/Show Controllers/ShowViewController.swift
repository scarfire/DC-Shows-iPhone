//
//  ShowViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/4/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit

class ShowViewController: UIViewController, ShowDetailsModelProtocol {

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
    
    let showDetailModel = ShowDetailModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        showDetailModel.delegate  = self
        if searchStr != nil {
            // Called from a search
            return
        }
        if showID == nil {
            // Random - need random ID first
            showDetailModel.getRandomShowID()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if showID != nil {
            // Coming from Shows
            showDetailModel.id = showID!
            showDetailModel.getNotes()
            showDetailModel.downloadSetList()
            showDetailModel.downloadDetails()
        }
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
        showDetailModel.getRandomShowID()
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        showDetailModel.getAdjacentShow(showDate: showDate!, showType: "Next")
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        showDetailModel.getAdjacentShow(showDate: showDate!, showType: "Previous")
    }
    
    func detailsDownloaded(show: ShowDetailModel) {
        showID = show.id
        showDate = show.showDate!
        defaultAudio = show.defaultAudio!
        if defaultAudio == "" {
            btnAudio.isEnabled = false
        }
        else {
            btnAudio.isEnabled = true
        }
        lblDate.text  = show.showDatePrint!
        lblCity.text = show.location!
        lblBuilding.text = show.building!
        
        lblRating.text = "" // populate later from Core Data if exists
        let url = URL(string: show.poster!)
        downloadImage(from: url!)
    }
    
    func setListDownloaded(setList: [SongModel]) {
        self.setList = setList
        tableView.reloadData()
        let topRow = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
    
    func notesDownloaded(notes: String) {
       // showAlert(msg: "Notes downloaded")
        
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
