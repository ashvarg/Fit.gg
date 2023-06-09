//
//  Food+CoreDataProperties.swift
//  Fit.GG
//
//  Created by Ashwin George on 31/5/2023.
//
//

import Foundation
import CoreData


extension Food {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Food> {
        return NSFetchRequest<Food>(entityName: "Food")
    }

    @NSManaged public var calories: Double
    @NSManaged public var carbohydrates: Double
    @NSManaged public var fats: Double
    @NSManaged public var name: String?
    @NSManaged public var protein: Double
    @NSManaged public var breakfastFood: NSSet?
    @NSManaged public var dinnerFood: NSSet?
    @NSManaged public var lunchFood: NSSet?

}

// MARK: Generated accessors for breakfastFood
extension Food {

    @objc(addBreakfastFoodObject:)
    @NSManaged public func addToBreakfastFood(_ value: Entry)

    @objc(removeBreakfastFoodObject:)
    @NSManaged public func removeFromBreakfastFood(_ value: Entry)

    @objc(addBreakfastFood:)
    @NSManaged public func addToBreakfastFood(_ values: NSSet)

    @objc(removeBreakfastFood:)
    @NSManaged public func removeFromBreakfastFood(_ values: NSSet)

}

// MARK: Generated accessors for dinnerFood
extension Food {

    @objc(addDinnerFoodObject:)
    @NSManaged public func addToDinnerFood(_ value: Entry)

    @objc(removeDinnerFoodObject:)
    @NSManaged public func removeFromDinnerFood(_ value: Entry)

    @objc(addDinnerFood:)
    @NSManaged public func addToDinnerFood(_ values: NSSet)

    @objc(removeDinnerFood:)
    @NSManaged public func removeFromDinnerFood(_ values: NSSet)

}

// MARK: Generated accessors for lunchFood
extension Food {

    @objc(addLunchFoodObject:)
    @NSManaged public func addToLunchFood(_ value: Entry)

    @objc(removeLunchFoodObject:)
    @NSManaged public func removeFromLunchFood(_ value: Entry)

    @objc(addLunchFood:)
    @NSManaged public func addToLunchFood(_ values: NSSet)

    @objc(removeLunchFood:)
    @NSManaged public func removeFromLunchFood(_ values: NSSet)

}

extension Food : Identifiable {

}
