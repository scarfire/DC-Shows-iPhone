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
    var setList: [SongModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgPoster: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblBuilding: UILabel!

    let showDetailModel = ShowDetailModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        showDetailModel.delegate  = self
        showDetailModel.downloadSetList(id: showID!)
        showDetailModel.downloadDetails(id: showID!)
    }

    @IBAction func edit(_ sender: Any) {
    }

    @IBAction func photos(_ sender: Any) {
    }
    
    @IBAction func videos(_ sender: Any) {
    }
    
    @IBAction func audio(_ sender: Any) {
    }
    
    @IBAction func random(_ sender: Any) {
    }
    
    func detailsDownloaded(show: ShowDetailModel) {
        lblDate.text  = show.showDate!
        lblCity.text = show.location!
        lblBuilding.text = show.building!
        lblRating.text = "" // populate later from Core Data if exists
        let url = URL(string: show.poster!)
        downloadImage(from: url!)
    }
    
    func setListDownloaded(setList: [SongModel]) {
        self.setList = setList
        tableView.reloadData()
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
