//
//  HomeViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 3/5/2023.
//

import UIKit
import FirebaseAuth
import Firebase

class HomeViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    
    weak var databaseController: DatabaseProtocol?


    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("Error: ", error.localizedDescription)
        }
    }
    
   
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
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
