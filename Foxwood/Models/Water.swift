//
//  Water.swift
//  Foxwood
//
//  Created by Alex on 16.01.2025.
//

import SwiftUI


enum WaterGameConstants {
    
}

enum WaterGameState: Equatable {
    case initial
    case countdown(Int)
    case playing
    case paused
    case finished(success: Bool)
}
