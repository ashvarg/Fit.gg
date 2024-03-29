//
//  CoreDataController.swift
//  Fit.GG
//
//  Created by Ashwin George on 11/5/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, CoreDatabaseProtocol  {
    
    
    var currentEntry: Entry?
    var currentFoodList: Array<Food>?
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    var allEntriesFetchedResultsController: NSFetchedResultsController<Entry>?
    var allFoodFetchedResultsController: NSFetchedResultsController<Food>?
    var breakfastFetchedResultsController: NSFetchedResultsController<Food>?
    var lunchFetchedResultsController: NSFetchedResultsController<Food>?
    var dinnerFetchedResultsController: NSFetchedResultsController<Food>?
    
    
    
    
    
    override init(){
        // Initialises the Core Data stack
        persistentContainer = NSPersistentContainer(name: "Fit_GG")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error {
                fatalError("Failed to load Core Data stack with error: \(error)")
            }
            
        }
        
        super.init()
    }
    
    
    
    func cleanUp() {
        /*
         check to see if there are changes to be saved inside of the view context and then save
         */
        if persistentContainer.viewContext.hasChanges{
            do{
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .entries || listener.listenerType == .all {
            listener.onEntryListChange(change: .update, entries: fetchAllEntries())
        }
        if listener.listenerType == .breakfastFood || listener.listenerType == .all{
            listener.onBreakfastListChange(change: .update, entryFood: fetchBreakfastFood())
        }
        if listener.listenerType == .lunchFood || listener.listenerType == .all{
            listener.onLunchListChange(change: .update, entryFood: fetchLunchFood())
        }
        if listener.listenerType == .dinnerFood || listener.listenerType == .all{
            listener.onDinnerListChange(change: .update, entryFood: fetchDinnerFood())
        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    // Adds entry to coredata
    func addEntry(entryName: String, entryDate: Date, entryWeight: Int64, entryLog: String) -> Entry {
        let entry = NSEntityDescription.insertNewObject(forEntityName: "Entry",
        into: persistentContainer.viewContext) as! Entry
        entry.name = entryName
        entry.date = entryDate
        entry.weight = entryWeight
        entry.log = entryLog
        print("entry added")
        return entry
        
        
    }

    // Deletes the entry from coredata
    func deleteEntry(entry: Entry) {
        persistentContainer.viewContext.delete(entry)
    }
    
    // Once save is clicked, the entry being edited will be fetched and changed with the necessary changes
    func editEntry(entryName: String, newName: String, newEntryDate: Date, newEntryWeight: Int64, newLog: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", entryName)
        
        let context = persistentContainer.viewContext
        
        do{
            let results = try context.fetch(fetchRequest)
            if let editedEntry = results.first {
                editedEntry.name = newName
                editedEntry.date = newEntryDate
                editedEntry.weight = newEntryWeight
                editedEntry.log = newLog
                
                try context.save()
            }
            
        } catch{
            print("Fetch singular entry failed: \(error)")
        }
        
        return true
    }
    
    // Converts the object from the API to the food format from core data
    func convertFoodDataToFood(foodData: FoodData) -> Food {
        let food = NSEntityDescription.insertNewObject(forEntityName: "Food",
        into: persistentContainer.viewContext) as! Food
        food.name = foodData.name
        food.calories = foodData.calories!
        food.carbohydrates = foodData.carbohydrates!
        food.protein = foodData.proteins!
        food.fats = foodData.fats!
        
        
        return food
    }
    
    // Adds food to the respective entry based on which relationship food has with entry
    func addFoodToEntry(foodData: FoodData, entry: Entry, entryListType: String) -> Bool {
        
        let food = convertFoodDataToFood(foodData: foodData)
        
        if entryListType == "breakfast"{
            guard let breakfast = entry.breakfast, breakfast.contains(food) == false
            else{
                return false
            }
            entry.addToBreakfast(food)
            return true
        }
        
        else if entryListType == "lunch"{
            guard let lunch = entry.lunch, lunch.contains(food) == false
            else{
                return false
            }
            
            entry.addToLunch(food)
            return true
            
        }
        
        else if entryListType == "dinner"{
            guard let dinner = entry.dinner, dinner.contains(food) == false
            else{
                return false
            }
            entry.addToDinner(food)
            return true
        }
        
        else{
            print("Cannot add into entryList")
            return false
        }
        
    }

    // Fetches list of entries from coredata
    func fetchAllEntries() -> [Entry]{
        if allEntriesFetchedResultsController == nil {
            let request: NSFetchRequest<Entry> = Entry.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            allEntriesFetchedResultsController = NSFetchedResultsController<Entry>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            allEntriesFetchedResultsController?.delegate = self
            
            do {
                try allEntriesFetchedResultsController?.performFetch()
            } catch{
                print("Fetch request for entries failed: \(error)")
            }
        }
        
        if let entries = allEntriesFetchedResultsController?.fetchedObjects {
            return entries
        }
        print("fetched entries")
        return  [Entry]()
    }
    
    // fetches all food from coredata
    func fetchAllFood() -> [Food] {
        /*
        check if the fetched results controller is nil (i.e., not instantiated)
        */
        
        if allFoodFetchedResultsController == nil {
            // create fetch request
            let request: NSFetchRequest<Food> = Food.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            // initialise Fetched Results Controller
            
            allFoodFetchedResultsController = NSFetchedResultsController<Food>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // set this class to be the results delegate'
            allFoodFetchedResultsController?.delegate = self
            
            // perform fetch request
            do{
                try allFoodFetchedResultsController?.performFetch()
            }
            catch{
                print("Fetch Request Failed: \(error)")
            }
            
        }
        if let food = allFoodFetchedResultsController?.fetchedObjects {
            return food
        }
        return [Food]()
    }
    
    // fetches food from the breakfast category
    func fetchBreakfastFood() -> [Food] {
        // fetches current entry
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let entryName = currentEntry?.name
        print(entryName ?? "error")
        
        
        let predicate = NSPredicate(format: "ANY breakfastFood.name == %@", entryName!)
    
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        fetchRequest.predicate = predicate
        
        breakfastFetchedResultsController =
            NSFetchedResultsController<Food>(fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
        
        breakfastFetchedResultsController?.delegate = self
            
        do {
            try breakfastFetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch breakfast foods: \(error)")
        }
            
        
        var food = [Food]()
        if breakfastFetchedResultsController?.fetchedObjects != nil {
            food = (breakfastFetchedResultsController?.fetchedObjects)!
        }
        return food
    
    }
    
    // fetches food from the lunch category
    func fetchLunchFood() -> [Food] {
        // fetches current entry
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let entryName = currentEntry?.name
        print(entryName ?? "error")
        
        
        let predicate = NSPredicate(format: "ANY lunchFood.name == %@", entryName!)
    
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        fetchRequest.predicate = predicate
        
        lunchFetchedResultsController =
            NSFetchedResultsController<Food>(fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
        
        lunchFetchedResultsController?.delegate = self
            
        do {
            try lunchFetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch lunch foods: \(error)")
        }
            
        
        var food = [Food]()
        if lunchFetchedResultsController?.fetchedObjects != nil {
            food = (lunchFetchedResultsController?.fetchedObjects)!
        }
        return food
    
    }
    
    // fetches food from the dinner category
    func fetchDinnerFood() -> [Food] {
        // fetches current entry
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let entryName = currentEntry?.name
        print(entryName ?? "error")
        
        
        let predicate = NSPredicate(format: "ANY dinnerFood.name == %@", entryName!)
    
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        fetchRequest.predicate = predicate
        
        dinnerFetchedResultsController =
            NSFetchedResultsController<Food>(fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil, cacheName: nil)
        
        dinnerFetchedResultsController?.delegate = self
            
        do {
            try dinnerFetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch dinner foods: \(error)")
        }
            
        
        var food = [Food]()
        if dinnerFetchedResultsController?.fetchedObjects != nil {
            food = (dinnerFetchedResultsController?.fetchedObjects)!
        }
        return food
    
    }
    
    // Performs actions based on which view controller is the listener and what type of listener are they
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allEntriesFetchedResultsController {
            listeners.invoke() {listener in
                if listener.listenerType == .entries{
                    listener.onEntryListChange(change: .update, entries: fetchAllEntries())
                    
                }
            }
        }
        else if controller == breakfastFetchedResultsController {
            listeners.invoke() {listener in
                if listener.listenerType == .breakfastFood || listener.listenerType == .all{
                    listener.onBreakfastListChange(change: .update, entryFood: fetchBreakfastFood())
                }
            }
        }
        else if controller == lunchFetchedResultsController {
            listeners.invoke() {listener in
                if listener.listenerType == .lunchFood || listener.listenerType == .all{
                    listener.onLunchListChange(change: .update, entryFood: fetchLunchFood())
                }
            }
        }
        else if controller == dinnerFetchedResultsController {
            listeners.invoke() {listener in
                if listener.listenerType == .dinnerFood || listener.listenerType == .all{
                    listener.onDinnerListChange(change: .update, entryFood: fetchDinnerFood())
                }
            }
        }
    }
            
    
    
    
}
