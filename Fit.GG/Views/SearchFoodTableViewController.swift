//
//  SearchFoodTableViewController.swift
//  Fit.GG
//
//  Created by Ashwin George on 4/5/2023.
//

import UIKit

class SearchFoodTableViewController: UITableViewController, UISearchBarDelegate {
    let CELL_FOOD = "foodCell"
    let API_KEY = "1G9rwL9m83iSEbDUooAKtri6vEJIY64lbhnkA1YK"
    let REQUEST_STRING = "https://api.nal.usda.gov/fdc/v1/foods/search?dataType=Survey%20%28FNDDS%29&api_key=1G9rwL9m83iSEbDUooAKtri6vEJIY64lbhnkA1YK&query="
    var newFood = [FoodData]()
    var indicator = UIActivityIndicatorView()
    weak var databaseController: DatabaseProtocol?
    
    
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
        databaseController = appDelegate?.databaseController
        
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newFood.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_FOOD, for: indexPath)
        
        let food = newFood[indexPath.row]
        cell.textLabel?.text = food.name
        cell.detailTextLabel?.text = String(food.dataType!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    
    func requestFoodsNamed(_ foodName: String) async {
        
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
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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