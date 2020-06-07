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

    override func viewDidLoad() {
        super.viewDidLoad()

        let showDetailModel = ShowDetailModel()
        showDetailModel.delegate  = self
        showDetailModel.downloadDetails(id: showID!)
        showDetailModel.downloadSetList(id: showID!)
    }

    override func viewDidAppear(_ animated: Bool) {
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
    
    func detailsDownloaded(item: ShowDetailModel) {
    }
    
    func setListDownloaded(setList: [SongModel]) {
    }
    
}

extension ShowViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        return cell
    }
    
}
                                                                                                                                                                                                                                                                                                                                                                            
