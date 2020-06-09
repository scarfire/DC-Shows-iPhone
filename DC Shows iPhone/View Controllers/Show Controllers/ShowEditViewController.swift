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
    
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var txtNotes: UITextView!
    @IBOutlet weak var txtAudio: UITextField!
    @IBOutlet weak var switchAttended: UISwitch!
    
    var showID: String?
    var shows: [NSManagedObject] = []
    var show = NSManagedObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        txtNotes.text = ""
      //1
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      let managedContext = appDelegate.persistentContainer.viewContext
    let showDetailsFetch = NSFetchRequest<NSManagedObject>(entityName: "ShowDetails")
      
      do {
        let intShowID = Int16(showID!)
        showDetailsFetch.predicate = NSPredicate(format: "showID == %i", intShowID!)
        shows = try managedContext.fetch(showDetailsFetch)
        if shows.count > 0 {
            // Object exists - grab 1st in case of multiples
            show = shows.first!
            txtNotes.text = show.value(forKeyPath: "notes") as? String
            txtAudio.text = show.value(forKeyPath: "audio") as? String
            let rating = show.value(forKeyPath: "rating") as? Int16
            if rating != nil {
                lblRating.text =  "\(rating)"
                stepper.value = Double(rating!)
            }
            let attended = show.value(forKeyPath: "attended") as? String
            if attended == "true" {
                switchAttended.isOn = true
            }
            else {
                switchAttended.isOn = false
            }
        }
        else {
            // Object doesn't exist yet - create it
            let entity = NSEntityDescription.entity(forEntityName: "ShowDetails", in: managedContext)!
            show = NSManagedObject(entity: entity, insertInto: managedContext)
            show.setValue(Int16(showID!), forKey: "showID")
            show.setValue("false", forKeyPath: "attended")
            show.setValue(0, forKeyPath: "rating")
            switchAttended.isOn = false
            stepper.value = 1.0
            do {
              try managedContext.save()
            }
            catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
            }
        }
      }
      catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
           return
        }
         
         let managedContext = appDelegate.persistentContainer.viewContext
         
        show.setValue(Int16(showID!), forKey: "showID")
        show.setValue(txtAudio.text, forKeyPath: "audio")
        show.setValue(txtNotes.text, forKeyPath: "notes")
        show.setValue(Int16(stepper.value), forKeyPath: "rating")  
        if switchAttended.isOn {
            show.setValue("true", forKeyPath: "attended")
        }
        else {
            show.setValue("false", forKeyPath: "attended")
        }

         // 4
         do {
           try managedContext.save()
         }
         catch let error as NSError {
           print("Could not save. \(error), \(error.userInfo)")
         }
        navigationController?.popViewController(animated: true)
    }
   
}
