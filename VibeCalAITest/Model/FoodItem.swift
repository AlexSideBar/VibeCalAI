import Foundation
import SwiftData

@Model
final class FoodItem: Codable {
    var id: UUID
    var name: String
    var calories: Double
    var carbs: Double
    var fat: Double
    var protein: Double
    var date: Date

    init(id: UUID = UUID(), name: String, calories: Double, carbs: Double, fat: Double, protein: Double, date: Date = Date()) {
        self.id = id
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.fat = fat
        self.protein = protein
        self.date = date
    }

    enum CodingKeys: String, CodingKey {
        case id, name, calories, carbs, fat, protein, date
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Double.self, forKey: .calories)
        carbs = try container.decode(Double.self, forKey: .carbs)
        fat = try container.decode(Double.self, forKey: .fat)
        protein = try container.decode(Double.self, forKey: .protein)
        date = try container.decode(Date.self, forKey: .date)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(calories, forKey: .calories)
        try container.encode(carbs, forKey: .carbs)
        try container.encode(fat, forKey: .fat)
        try container.encode(protein, forKey: .protein)
        try container.encode(date, forKey: .date)
    }
}
