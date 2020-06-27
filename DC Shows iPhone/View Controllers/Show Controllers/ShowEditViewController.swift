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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      txtNotes.text = ""
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      let managedContext = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSManagedObject>(entityName: "Show")
      request.predicate = NSPredicate(format: "show_id == %@", showID!.description)
      do {
        let result = try managedContext.fetch(request)
        for data in result as [NSManagedObject] {
            // Object exists - grab 1st in case of multiples
            
            txtNotes.text = data.value(forKeyPath: "user_notes") as? String
            txtAudio.text = data.value(forKeyPath: "user_audio") as? String
            let rating = data.value(forKeyPath: "user_rating") as? Int
            lblRating.text =  "\(rating!)"
            stepper.value = Double(rating!)
            let attended = data.value(forKeyPath: "user_attended") as? String
            if attended == "true" {
                switchAttended.isOn = true
            }
            else {
                switchAttended.isOn = false
            }
        }
      }
      catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
    
    @IBAction func ratingChanged(_ sender: Any) {
        lblRating.text = "\(Int(stepper!.value))"
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Show")
        request.predicate = NSPredicate(format: "show_id == %@", showID!.description)
        var show = NSManagedObject()
        do {
            let records = try managedContext.fetch(request)
            if let records = records as? [NSManagedObject] {
                show = records.first!
                show.setValue(txtNotes.text, forKeyPath: "user_notes")
                show.setValue(Int16(showID!), forKey: "show_id")
                show.setValue(txtAudio.text, forKeyPath: "user_audio")
                show.setValue(txtNotes.text, forKeyPath: "user_notes")
                show.setValue(Int16(stepper.value), forKeyPath: "user_rating")
                if switchAttended.isOn {
                    show.setValue("true", forKeyPath: "user_attended")
                }
                else {
                    show.setValue("false", forKeyPath: "user_attended")
                }
            }
            do {
                try managedContext.save()
            }
            catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        navigationController?.popViewController(animated: true)
    }
   
    
}
