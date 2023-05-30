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
        if listener.listenerType == .entry || listener.listenerType == .all {
            listener.onEntryListChange(change: .update, entries: fetchAllEntries())
        }
        if listener.listenerType == .breakfastFood{
            listener.onBreakfastListChange(change: .update, entryFood: fetchBreakfastFood())
        }
        if listener.listenerType == .lunchFood{
            listener.onLunchListChange(change: .update, entryFood: fetchLunchFood())
        }
        if listener.listenerType == .dinnerFood{
            listener.onDinnerListChange(change: .update, entryFood: fetchDinnerFood())
        }
        listener.onEntryListChange(change: .update, entries: fetchAllEntries())
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addEntry(entryName: String) -> Entry {
        let entry = NSEntityDescription.insertNewObject(forEntityName: "Entry",
        into: persistentContainer.viewContext) as! Entry
        entry.name = entryName
        print("entry added")
        return entry
        
        
    }

    
    func deleteEntry(entry: Entry) {
        persistentContainer.viewContext.delete(entry)
    }
    
    
    func addFoodToEntry(food: Food, entry: Entry, entryListType: String) -> Bool {
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

    
    func removeFoodFromEntry(food: Food, entry: Entry) {
        
    }
    
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
    
    func fetchBreakfastFood() -> [Food] {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let entryName = currentEntry?.name
        print(entryName ?? "error")
        
        
        let predicate = NSPredicate(format: "ANY entries.name == %@ AND SELF in %@", entryName!, currentEntry?.breakfast ?? [])
    
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
    
    func fetchLunchFood() -> [Food] {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let entryName = currentEntry?.name
        print(entryName ?? "error")
        
        
        let predicate = NSPredicate(format: "ANY entries.name == %@ AND SELF in %@", entryName!, currentEntry?.lunch ?? [])
    
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
    
    func fetchDinnerFood() -> [Food] {
        let fetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let entryName = currentEntry?.name
        print(entryName ?? "error")
        
        
        let predicate = NSPredicate(format: "ANY entries.name == %@ AND SELF in %@", entryName!, currentEntry?.dinner ?? [])
    
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
            print("Failed to fetch breakfast foods: \(error)")
        }
            
        
        var food = [Food]()
        if dinnerFetchedResultsController?.fetchedObjects != nil {
            food = (dinnerFetchedResultsController?.fetchedObjects)!
        }
        return food
    
    }
    
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
                if listener.listenerType == .breakfastFood{
                    listener.onBreakfastListChange(change: .update, entryFood: fetchBreakfastFood())
                }
            }
        }
        else if controller == lunchFetchedResultsController {
            listeners.invoke() {listener in
                if listener.listenerType == .lunchFood{
                    listener.onLunchListChange(change: .update, entryFood: fetchLunchFood())
                }
            }
        }
        else if controller == dinnerFetchedResultsController {
            listeners.invoke() {listener in
                if listener.listenerType == .dinnerFood{
                    listener.onDinnerListChange(change: .update, entryFood: fetchDinnerFood())
                }
            }
        }
    }
            
    
    
    
}
