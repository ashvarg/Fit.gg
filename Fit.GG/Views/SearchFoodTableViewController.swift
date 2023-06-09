//
//  SearchFoodTableViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 4/5/2023.
//

import UIKit

class SearchFoodTableViewController: UITableViewController, UISearchBarDelegate {
    weak var currentEntry: Entry?
    var foodListType: String?
    
    let CELL_FOOD = "foodCell"
    let API_KEY = "1G9rwL9m83iSEbDUooAKtri6vEJIY64lbhnkA1YK"
    let REQUEST_STRING = "https://api.nal.usda.gov/fdc/v1/foods/search?dataType=Survey%20%28FNDDS%29&api_key=1G9rwL9m83iSEbDUooAKtri6vEJIY64lbhnkA1YK&query="
    var newFood = [FoodData]()
    var indicator = UIActivityIndicatorView()
    weak var databaseController: CoreDatabaseProtocol?
    
    
    override func viewDidLoad() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.CoreDatabaseController
        
        currentEntry = databaseController?.currentEntry
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return newFood.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_FOOD, for: indexPath)
        
        let food = newFood[indexPath.row]
        cell.textLabel?.text = food.name
        cell.detailTextLabel?.text = String(food.calories!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Checks whether the caller wants the food to be placed into breakfast, lunch, or dinner
        if foodListType == "breakfast"{
            let food = newFood[indexPath.row]
            let _ = databaseController?.addFoodToEntry(foodData: food, entry: currentEntry!, entryListType: "breakfast")
            print("Breakfast added")
            navigationController?.popViewController(animated: true)
        }
        
        else if foodListType == "lunch"{
            let food = newFood[indexPath.row]
            let _ = databaseController?.addFoodToEntry(foodData: food, entry: currentEntry!, entryListType: "lunch")
            print("lunch added")
            navigationController?.popViewController(animated: true)
        }
        else if foodListType == "dinner"{
            let food = newFood[indexPath.row]
            let _ = databaseController?.addFoodToEntry(foodData: food, entry: currentEntry!, entryListType: "dinner")
            print("dinner added")
            navigationController?.popViewController(animated: true)
        }
    }
    
    func requestFoodsNamed(_ foodName: String) async {
        // Requests the API for data that the user has searched for
        guard let queryString = foodName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Query string can't be encoded.")
            return
        }
        guard let requestURL = URL(string: REQUEST_STRING + queryString) else { print("Invalid URL.")
            return
        }
        let urlRequest = URLRequest(url: requestURL)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            indicator.stopAnimating()
            
            let decoder = JSONDecoder()
            let foodListData = try decoder.decode(FoodListData.self, from: data)
            
            if let foods = foodListData.foods{
                newFood.append(contentsOf: foods)
                
                tableView.reloadData()
            }
        }
        catch let error {
            print(error)
        }
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        newFood.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text else {
            return
        }
        
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        Task {
            await requestFoodsNamed(searchText)
        }
    }
}
