//
//  ShowViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/4/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit

class ShowViewController: UIViewController {

    var showID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //showAlert(msg: showID!)
//        let showModel = ShowModel()
//        showModel.delegate = self
//        showModel.downloadItems(year: year!)
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
                                                                                                                                                                                                                                                                                                                                                                            
