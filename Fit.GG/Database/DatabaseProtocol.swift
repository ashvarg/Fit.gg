//
//  DatabaseProtocol.swift
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
//    func onAuthChange(change: )
   

}

protocol FireDatabaseProtocol: AnyObject {
    func cleanUp()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    
    func signInWith(email: String, password: String) -> Bool
    func signUpWith(email: String, password: String) -> Bool
    func signOut()
   
}

protocol CoreDatabaseProtocol: AnyObject {
    var currentEntry: Entry? {get set}
    func cleanUp()
    func addEntry(entryName: String, entryDate: Date, entryWeight: Int64) -> Entry
    func editEntry(entryName: String, newName: String, newEntryDate: Date, newEntryWeight: Int64) -> Bool
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func deleteEntry(entry: Entry)
    func addFoodToEntry(food: Food, entry: Entry, entryListType: String) -> Bool
    func removeFoodFromEntry(food: Food, entry: Entry)
    
   
    
    
    
   
}
