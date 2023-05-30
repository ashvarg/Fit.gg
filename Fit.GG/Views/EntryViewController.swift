//
//  EntryViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 11/5/2023.
//

import UIKit

class EntryViewController: UIViewController, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
    
    
    var listenerType = ListenerType.all
    
    @IBOutlet weak var dateField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var weightField: UITextField!
    
    @IBOutlet weak var logField: UITextView!
    
    
    @IBOutlet weak var breakfastTableView: UITableView!
    @IBOutlet weak var lunchTableView: UITableView!
    @IBOutlet weak var dinnerTableView: UITableView!
    
    var breakfastData: [Food] = []
    var lunchData: [Food] = []
    var dinnerData: [Food] = []
    
    weak var databaseController: CoreDatabaseProtocol?
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        super.viewDidLoad()
        
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
        navigationItem.leftBarButtonItem = backButton
        breakfastTableView.delegate = self
        lunchTableView.delegate = self
        dinnerTableView.delegate = self
        
        breakfastTableView.dataSource = self
        lunchTableView.dataSource = self
        dinnerTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.CoreDatabaseController
        
        // Do any additional setup after loading the view.
        
    }
    
    
    @objc private func backButtonPressed(){
        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to go back?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default){[weak self] (_) in
            self?.navigationController?.navigationBar.isUserInteractionEnabled = true
        }
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive){ [weak self] (_) in
            let entry = self?.databaseController?.currentEntry
            self?.databaseController?.deleteEntry(entry: entry!)
            
            self?.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func createEntry(_ sender: Any) {
        
        guard let date = dateField.text, let weight = weightField.text, let name = nameField.text
        else{
            return
        }
        
        if date.isEmpty || weight.isEmpty || name.isEmpty {
        var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty{
                errorMsg += "- Must provide a name\n"
            }
        if date.isEmpty {
            errorMsg += "- Must provide a date\n"
        }
        if weight.isEmpty {
            errorMsg += "- Must provide weight"
        }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        let _ = databaseController?.addEntry(entryName: name)
        print("Entry has been added")
        navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
        
        switch tableView {
            
        case breakfastTableView:
            numberOfRows = breakfastData.count
            
        case lunchTableView:
            numberOfRows = lunchData.count
            
        case dinnerTableView:
            numberOfRows = dinnerData.count
            
        default:
            print("Num rows in Section Wrong")
        }
        return numberOfRows
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        switch tableView {
            
        case breakfastTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: "breakfastCell", for: indexPath)
            let food = breakfastData[indexPath.row]
            cell.textLabel?.text = food.name
            
            
        case lunchTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: "lunchCell", for: indexPath)
            let food = lunchData[indexPath.row]
            cell.textLabel?.text = food.name
            
        case dinnerTableView:
            cell = tableView.dequeueReusableCell(withIdentifier: "dinnerCell", for: indexPath)
            let food = dinnerData[indexPath.row]
            cell.textLabel?.text = food.name
            
        default:
            print("Cell for row at Wrong")
        }
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller
        if segue.identifier == "BreakfastAddSegue"{
            
            
        }
            
    }

    func onEntryListChange(change: DatabaseChange, entries: [Entry]) {
        
    }
    
    func onBreakfastListChange(change: DatabaseChange, entryFood: [Food]) {
        breakfastData = entryFood
        breakfastTableView.reloadData()
    }
    
    func onLunchListChange(change: DatabaseChange, entryFood: [Food]) {
        lunchData = entryFood
        lunchTableView.reloadData()
    }
    
    func onDinnerListChange(change: DatabaseChange, entryFood: [Food]) {
        dinnerData = entryFood
        dinnerTableView.reloadData()
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


 
