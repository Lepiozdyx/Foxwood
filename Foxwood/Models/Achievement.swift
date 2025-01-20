
import Foundation

enum AchievementType: String, CaseIterable, Codable {
    case food = "food"
    case water = "water"
    case wood = "wood"
    case nights = "nights"
    
    var image: ImageResource {
        switch self {
        case .food: return .foodAchievement
        case .water: return .waterAchievement
        case .wood: return .woodAchievement
        case .nights: return .nightAchievement
        }
    }
    
    var requirement: Int {
        switch self {
        case .food, .water, .wood: return 20
        case .nights: return 10
        }
    }
}

struct Achievement: Codable, Hashable {
    let type: AchievementType
    var progress: Int
    
    var isUnlocked: Bool {
        progress >= type.requirement
    }
    
    var progressText: String {
        "Get \(progress)/\(type.requirement) \(type.rawValue.lowercased())"
    }
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.type == rhs.type
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

extension Achievement {
    static func initial(type: AchievementType) -> Achievement {
        Achievement(type: type, progress: 0)
    }
}
