//
//  DatabaseProtocol.swift
//  Fit.GG
//
//  Created by Ashwin George on 11/5/2023.
//

import Foundation


enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case user
    case entry
    case food
    case all
    case entries
    case breakfastFood
    case lunchFood
    case dinnerFood
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onEntryListChange(change: DatabaseChange, entries: [Entry])
    func onBreakfastListChange(change: DatabaseChange, entryFood: [Food])
    func onLunchListChange(change: DatabaseChange, entryFood: [Food])
    func onDinnerListChange(change: DatabaseChange, entryFood: [Food])
   

}

protocol FireDatabaseProtocol: AnyObject {
    func cleanUp()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    
    func signInWith(email: String, password: String, completion: @escaping (Bool) -> Void)
    func signUpWith(email: String, password: String) -> Bool
    func signOut()
   
}

protocol CoreDatabaseProtocol: AnyObject {
    var currentEntry: Entry? {get set}
    func cleanUp()
    func addEntry(entryName: String, entryDate: Date, entryWeight: Int64, entryLog: String) -> Entry
    func editEntry(entryName: String, newName: String, newEntryDate: Date, newEntryWeight: Int64, newLog: String) -> Bool
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func deleteEntry(entry: Entry)
    func addFoodToEntry(foodData: FoodData, entry: Entry, entryListType: String) -> Bool
    func convertFoodDataToFood(foodData: FoodData) -> Food
    
   
    
    
    
   
}
