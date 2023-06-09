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
    var calories: Double?
    var carbohydrates: Double?
    var proteins: Double?
    var fats: Double?
    
    enum RootKeys: String, CodingKey{
        case name = "description"
        case dataType
        case foodNutrients
        
    }
    

    private struct Nutrient: Decodable{
        var nutrientName: String
        let value: Double
    }
    
    
    
    
    required public init(from decoder: Decoder) throws {
        let foodContainer = try decoder.container(keyedBy: RootKeys.self)
        
        name = try foodContainer.decode(String.self, forKey: .name)
        dataType = try foodContainer.decode(String.self, forKey: .dataType)
        do{
            if let nutrients = try foodContainer.decodeIfPresent([Nutrient].self, forKey: .foodNutrients){
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
            catch{
                print("Decoding Nutrients failed: \(error)")
            }
            
            
        }
    
    // let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)
    
    // MARK: - Welcome
}
