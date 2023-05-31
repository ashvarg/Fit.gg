//
//  DiaryTableViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 11/5/2023.
//

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
        print(totalEntries.count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller
        if segue.identifier == "createEntry"{
            
            let _ = segue.destination as! EntryViewController
            let name = ""
            let date = Date()
            let weight = Int64(0)
            let entry = databaseController?.addEntry(entryName: name, entryDate: date, entryWeight: weight)
            print("Entry has been added")
            databaseController?.currentEntry = entry
            
        }
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
    

    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_ENTRY{
            // Delete the row from the data source
            let entry = totalEntries[indexPath.row]
            databaseController?.deleteEntry(entry: entry)
            
        }
    
    }
    
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
