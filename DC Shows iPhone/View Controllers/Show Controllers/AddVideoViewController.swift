//
//  AddVideoViewController.swift
//  DC Shows iPhone
//
//  Created by Todd Stevens on 6/5/20.
//  Copyright © 2020 Todd Stevens. All rights reserved.
//

import UIKit
import CoreData

class AddVideoViewController: UIViewController {
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtLink: UITextField!
    
    var showID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           return
        }
         
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Video", in: managedContext)!
        let show = NSManagedObject(entity: entity, insertInto: managedContext)

        show.setValue(Int16(showID!), forKey: "showID")
        show.setValue(txtTitle.text, forKeyPath: "title")
        show.setValue(txtLink.text, forKeyPath: "url")
        do {
           try managedContext.save()
        }
        catch let error as NSError {
           print("Could not save. \(error), \(error.userInfo)")
        }
        navigationController?.popViewController(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
