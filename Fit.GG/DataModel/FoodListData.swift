//
//  FoodListData.swift
//  Fit.GG
//
//  Created by Ashwin George on 5/5/2023.
//

import UIKit

class FoodListData: NSObject, Decodable {
    var foods: [FoodData]?
    
    private enum CodingKeys: String, CodingKey{
        case foods = "foods"
    }
}
