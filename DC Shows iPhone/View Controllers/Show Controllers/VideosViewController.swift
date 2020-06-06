//
//  VideosViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit

class VideosViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
/*
     Get MySQL data from server
     
     func get() {
         let url = URL(string: "https://toddlstevens.com/apps/walking/getallevents.php")
         let data = try? Data(contentsOf: url!)
         values = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
         tableView.reloadData()
       }
     
     */
    // Delete a row from video list
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//          if editingStyle == .delete {
//               // Delete the row from the server
//               let walkingEvent = values[indexPath.row] as! [String:Any]
//               let eventID = (walkingEvent["id"] as! Int)
//               let url = "https://toddlstevens.com/apps/walking/deleteevent.php"
//               let postString = "&id=" + String(describing: eventID)
//               let request = NSMutableURLRequest(url: URL(string: url)!)
//               request.httpMethod = "POST"
//               request.httpBody = postString.data(using: String.Encoding.utf8)
//               updateDatabase(request as URLRequest)
//
//           } else if editingStyle == .insert {
//               // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//           }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
