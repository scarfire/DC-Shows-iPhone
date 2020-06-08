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
      
      //1
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
      }
      let managedContext = appDelegate.persistentContainer.viewContext
      
      //2
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ShowDetails")
      
      //3
      do {
        var show = try managedContext.fetch(fetchRequest)
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
         
         // 1
         let managedContext = appDelegate.persistentContainer.viewContext
         
         // 2
         let entity = NSEntityDescription.entity(forEntityName: "ShowDetails", in: managedContext)!
         let show = NSManagedObject(entity: entity, insertInto: managedContext)
         
         // 3
        show.setValue(txtAudio.text, forKeyPath: "audio")
        show.setValue(txtNotes.text, forKeyPath: "notes")
        show.setValue(0, forKeyPath: "rating")
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
