//
//  FoodData.swift
//  Fit.GG
//
//  Created by Ashwin George on 4/5/2023.
//

import UIKit

public class FoodData: NSObject, Decodable {
    var name: String?
    var dataType: String?
    var calories: Int?
    var carbohydrates: Int?
    var proteins: Int?
    var fats: Int?
    
    private enum RootKeys: String, CodingKey{
        case description
        case foodNutrients
        case dataType
        
    }
    

    private struct Nutrient: Decodable{
        var nutrientName: String
        var value: Int
        var unitName: String
    }
    
    required public init(from decoder: Decoder) throws {
        let foodContainer = try decoder.container(keyedBy: RootKeys.self)
        
        name = try foodContainer.decode(String.self, forKey: .description)
        dataType = try foodContainer.decode(String.self, forKey: .dataType)
        
        if let nutrients = try? foodContainer.decode([Nutrient].self, forKey: .foodNutrients){
            for nutrient in nutrients {
                if nutrient.nutrientName == "Protein"{
                    proteins = nutrient.value
                    
                }
                else if nutrient.nutrientName == "Total lipid (fat)"{
                    fats = nutrient.value
                }
                else if nutrient.nutrientName == "Carbohydrate, by difference"{
                    carbohydrates = nutrient.value
                }
                else if nutrient.nutrientName == "Energy"{
                    calories = nutrient.value
                }
                    
            }
            
            
        }
    }
    // let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)
    
    // MARK: - Welcome
}
