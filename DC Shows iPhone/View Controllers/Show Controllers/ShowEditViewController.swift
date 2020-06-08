//
//  ShowEditViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit
import CoreData

class ShowEditViewController: UIViewController {
    
    var showID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.setNavigationBarHidden(true, animated: false)
        showAlert(msg: showID!)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    /*
     
    func updateDatabase(_ request:URLRequest) {
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if (error != nil) {
                print("error=" + String(describing: error))
                return
            }
            
            // print("response = \(response)")
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            print("responseString = " + String(describing: responseString))
            
            DispatchQueue.main.async {
                // Close window on main thread since it's a UI action
                //if let delegate = self.delegate {
                self.get()
                //}
            }
            
        })
        task.resume()
    }
     */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
