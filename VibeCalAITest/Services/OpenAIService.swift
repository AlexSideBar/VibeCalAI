import Foundation
import UIKit
import SwiftOpenAI

struct FoodAnalysisService {
    private let openAIService: OpenAIService
    
    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
            fatalError("Add OPENAI_API_KEY to Info.plist")
        }
        self.openAIService = OpenAIServiceFactory.service(apiKey: apiKey)
    }

    func analyze(image: UIImage) async throws -> FoodItem? {
        guard let jpeg = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let systemMessage = ChatCompletionParameters.Message(
            role: .system,
            content: .text("You are a nutrition expert. Analyze the food in the image and provide accurate nutritional information. You must respond with valid JSON using this exact format: {\"name\": \"food name\", \"calories\": 123, \"carbs\": 45, \"fat\": 12, \"protein\": 8}")
        )
        
        let userMessage = ChatCompletionParameters.Message(
            role: .user,
            content: .contentArray([
                .text("Analyze this food image and provide nutritional information including name, calories, carbs, fat, and protein. Be as accurate as possible with portion size estimation. Respond with JSON only."),
                .imageUrl(.init(url: URL(string: "data:image/jpeg;base64,\(jpeg.base64EncodedString())")!))
            ])
        )
        
        // Use the basic parameters without responseFormat for now
        let parameters = ChatCompletionParameters(
            messages: [systemMessage, userMessage],
            model: .gpt4o,
            temperature: 0
        )
        
        do {
            let completion = try await openAIService.startChat(parameters: parameters)
            
            guard let content = completion.choices.first?.message.content else {
                throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No content in response"])
            }
            
            print("AI Response: \(content)")
            
            // Try to extract JSON from the response
            let jsonString = extractJSON(from: content)
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not convert response to data"])
            }
            
            let nutritionData = try JSONDecoder().decode(NutritionOutput.self, from: jsonData)
            
            return FoodItem(
                name: nutritionData.name,
                calories: Double(nutritionData.calories),
                carbs: Double(nutritionData.carbs),
                fat: Double(nutritionData.fat),
                protein: Double(nutritionData.protein)
            )
            
        } catch {
            print("Error in OpenAI request: \(error)")
            throw error
        }
    }
    
    private func extractJSON(from text: String) -> String {
        // If the response is already JSON, return it
        if text.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("{") {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Try to find JSON within the text
        if let startRange = text.range(of: "{"),
           let endRange = text.range(of: "}", options: .backwards) {
            return String(text[startRange.lowerBound...endRange.upperBound])
        }
        
        return text
    }
}

// MARK: - DTOs
private struct NutritionOutput: Decodable {
    let name: String
    let calories: Int
    let carbs: Int
    let fat: Int
    let protein: Int
}