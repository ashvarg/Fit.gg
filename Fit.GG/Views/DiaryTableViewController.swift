//
//  DiaryTableViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 11/5/2023.
// Table that contains entries

import UIKit

class DiaryTableViewController: UITableViewController, DatabaseListener {
    var listenerType = ListenerType.entries
    weak var databaseController: CoreDatabaseProtocol?
    
    var totalEntries: [Entry] = []
    let SECTION_ENTRY = 0
    let CELL_ENTRY = "entryCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.CoreDatabaseController
        
        
        tableView.reloadData()
    }
    
    func onEntryListChange(change: DatabaseChange, entries: [Entry]) {
        totalEntries = entries
        tableView.reloadData()
        
    }
    
    func onBreakfastListChange(change: DatabaseChange, entryFood: [Food]) {
        
    }
    
    func onLunchListChange(change: DatabaseChange, entryFood: [Food]) {
        
    }
    
    func onDinnerListChange(change: DatabaseChange, entryFood: [Food]) {
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return totalEntries.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.tabBarController?.tabBar.isHidden = false
        print(totalEntries.count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Creates a new entry that is edited and saved if the user wants the entry
        
        if segue.identifier == "createEntry"{
            
            let _ = segue.destination as! EntryViewController
            let name = ""
            let date = Date()
            let weight = Int64(0)
            let log = ""
            let entry = databaseController?.addEntry(entryName: name, entryDate: date, entryWeight: weight, entryLog: log)
            print("Entry has been added")
            databaseController?.currentEntry = entry
            
        }
        // Segue when user clicks on an entry
        else if segue.identifier == "diaryToEntrySegue"{
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell){
                let entry = totalEntries[indexPath.row]
                databaseController?.currentEntry = entry
                let destination = segue.destination as! EntryViewController
                destination.editingFlag = true
            }
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entryCell = tableView.dequeueReusableCell(withIdentifier: CELL_ENTRY, for: indexPath)
        var content = entryCell.defaultContentConfiguration()
        let entry = totalEntries[indexPath.row]
        content.text = entry.name
        
        entryCell.contentConfiguration = content
        return entryCell
    }
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       
        return true
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_ENTRY{
            // Delete the row from the data source
            let entry = totalEntries[indexPath.row]
            databaseController?.deleteEntry(entry: entry)
            
        }
        
    }
    
    
}
