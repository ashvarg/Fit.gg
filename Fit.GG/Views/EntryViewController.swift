//
//  EntryViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 11/5/2023.
// Reference for datepicker functionality: https://youtu.be/chROnJIF7dY UI DatePicker for UITextField | 2020

import UIKit

class EntryViewController: UIViewController, DatabaseListener, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var listenerType = ListenerType.all
    
    var editingFlag: Bool!
    
    @IBOutlet weak var dateField: UITextField!
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var weightField: UITextField!
    
    @IBOutlet weak var logField: UITextView!
    
    
    @IBOutlet weak var breakfastTableView: UITableView!
    @IBOutlet weak var lunchTableView: UITableView!
    @IBOutlet weak var dinnerTableView: UITableView!
    
    var breakfastData: [Food] = []
    var lunchData: [Food] = []
    var dinnerData: [Food] = []
    
    @IBOutlet weak var totalCaloriesField: UITextField!
    
    weak var databaseController: CoreDatabaseProtocol?
    
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.isHidden = true
        super.viewDidLoad()
        
    
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonPressed))
        navigationItem.leftBarButtonItem = backButton
        createDatePicker()
        breakfastTableView.delegate = self
        lunchTableView.delegate = self
        dinnerTableView.delegate = self
        
        breakfastTableView.dataSource = self
        lunchTableView.dataSource = self
        dinnerTableView.dataSource = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.CoreDatabaseController
        
        // Do any additional setup after loading the view.
        initializeFieldValues()
            
        print(breakfastData.count)
    }
    
    func initializeFieldValues(){
        
        nameField.text = databaseController?.currentEntry?.name
        
        logField.text = databaseController?.currentEntry?.log
        if let weight = databaseController?.currentEntry?.weight {
            weightField.text = String(weight)
        } else{
            weightField.text = nil
        }
        
        if let date = databaseController?.currentEntry?.date{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let dateString = dateFormatter.string(from: date)
            dateField.text = dateString
        } else{
            dateField.text = nil
        }
        
    }
    
    func createToolBar() -> UIToolbar{
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        return toolbar
    }
    
    func createDatePicker(){
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dateField.inputView = datePicker
        dateField.inputAccessoryView = createToolBar()
        
    }
    
    @objc func donePressed(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.dateField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
        
        
    }
    
    
    @objc private func backButtonPressed(){
        if editingFlag != true{
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
        else{
            let alertController = UIAlertController(title: "Go Back?", message: "Changes won't be saved", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default){[weak self] (_) in
                self?.navigationController?.navigationBar.isUserInteractionEnabled = true
            }
            let confirmAction = UIAlertAction(title: "Yes", style: .destructive){ [weak self] (_) in
                self?.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    @IBAction func createEntry(_ sender: Any) {
        
        guard let date = dateField.text, let weight = weightField.text, let name = nameField.text, let log = logField.text
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        guard let newdate = dateFormatter.date(from: date) else{
            displayMessage(title: "error", message: "Date not formatted Correctly")
            return
        }
        
        guard let weight = Int64(weight) else{
            displayMessage(title: "Weight error", message: "Weight not parsed")
            return
        }
        
        let _ = databaseController?.editEntry(entryName: (databaseController?.currentEntry?.name)!, newName: name, newEntryDate: newdate, newEntryWeight: weight, newLog: log)
        navigationController?.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func calculateCalories() -> Double {
        var totalBreakfastCalories = Double(0)
        var totalLunchCalories = Double(0)
        var totalDinnerCalories = Double(0)
        
        for breakfast in breakfastData {
            totalBreakfastCalories += breakfast.calories
        }
        
        for lunch in lunchData {
            totalLunchCalories += lunch.calories
        }
        
        for dinner in dinnerData{
            totalDinnerCalories += dinner.calories
        }
        
        let totalCalories = totalBreakfastCalories + totalLunchCalories + totalDinnerCalories
        
        return totalCalories
        
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
            var content = cell.defaultContentConfiguration()
            let food = breakfastData[indexPath.row]
            content.text = food.name
            cell.contentConfiguration = content
            
            
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
        if segue.identifier == "breakfastAddSegue"{
            let destination = segue.destination as! SearchFoodTableViewController
            destination.foodListType = "breakfast"
            
        }
        else if segue.identifier == "lunchAddSegue"{
            let destination = segue.destination as! SearchFoodTableViewController
            destination.foodListType = "lunch"
            
        }
        else if segue.identifier == "dinnerAddSegue"{
            let destination = segue.destination as! SearchFoodTableViewController
            destination.foodListType = "dinner"
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        totalCaloriesField.text = String(calculateCalories())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        
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


 
