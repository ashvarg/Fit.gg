//
//  Food+CoreDataProperties.swift
//  Fit.GG
//
//  Created by Ashwin George on 28/5/2023.
//
//

import Foundation
import CoreData


extension Food {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Food> {
        return NSFetchRequest<Food>(entityName: "Food")
    }

    @NSManaged public var calories: Int64
    @NSManaged public var carbohydrates: Int64
    @NSManaged public var fats: Int64
    @NSManaged public var name: String?
    @NSManaged public var protein: Int64
    @NSManaged public var breakfastFood: Entry?
    @NSManaged public var dinnerFood: Entry?
    @NSManaged public var lunchFood: Entry?

}

extension Food : Identifiable {

}
