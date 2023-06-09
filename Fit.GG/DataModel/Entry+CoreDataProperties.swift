//
//  Entry+CoreDataProperties.swift
//  Fit.GG
//
//  Created by Ashwin George on 31/5/2023.
//
//

import Foundation
import CoreData


extension Entry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entry> {
        return NSFetchRequest<Entry>(entityName: "Entry")
    }

    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var totalCalories: Int64
    @NSManaged public var weight: Int64
    @NSManaged public var log: String?
    @NSManaged public var breakfast: NSSet?
    @NSManaged public var dinner: NSSet?
    @NSManaged public var lunch: NSSet?

}

// MARK: Generated accessors for breakfast
extension Entry {

    @objc(addBreakfastObject:)
    @NSManaged public func addToBreakfast(_ value: Food)

    @objc(removeBreakfastObject:)
    @NSManaged public func removeFromBreakfast(_ value: Food)

    @objc(addBreakfast:)
    @NSManaged public func addToBreakfast(_ values: NSSet)

    @objc(removeBreakfast:)
    @NSManaged public func removeFromBreakfast(_ values: NSSet)

}

// MARK: Generated accessors for dinner
extension Entry {

    @objc(addDinnerObject:)
    @NSManaged public func addToDinner(_ value: Food)

    @objc(removeDinnerObject:)
    @NSManaged public func removeFromDinner(_ value: Food)

    @objc(addDinner:)
    @NSManaged public func addToDinner(_ values: NSSet)

    @objc(removeDinner:)
    @NSManaged public func removeFromDinner(_ values: NSSet)

}

// MARK: Generated accessors for lunch
extension Entry {

    @objc(addLunchObject:)
    @NSManaged public func addToLunch(_ value: Food)

    @objc(removeLunchObject:)
    @NSManaged public func removeFromLunch(_ value: Food)

    @objc(addLunch:)
    @NSManaged public func addToLunch(_ values: NSSet)

    @objc(removeLunch:)
    @NSManaged public func removeFromLunch(_ values: NSSet)

}

extension Entry : Identifiable {

}
