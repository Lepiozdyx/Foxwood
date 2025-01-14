//
//  Achievement.swift
//  Foxwood
//
//  Created by Alex on 14.01.2025.
//

import Foundation

struct Achievement: Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let requirement: Int
    
    static let collectWater = Achievement(
        id: "water_100",
        title: "Water Master",
        description: "Collect 100 water",
        requirement: 100
    )
    
    static let collectFood = Achievement(
        id: "food_75",
        title: "Food Master",
        description: "Collect 75 food",
        requirement: 75
    )
    
    static let collectWood = Achievement(
        id: "wood_100",
        title: "Wood Master",
        description: "Collect 100 wood",
        requirement: 100
    )
    
    static let surviveNights = Achievement(
        id: "survive_10",
        title: "Survivor",
        description: "Survive 10 nights",
        requirement: 10
    )
}
