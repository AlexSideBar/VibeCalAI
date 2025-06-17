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
        
        // Create the JSON schema for structured output
        let nutritionSchema = JSONSchema(
            type: .object,
            properties: [
                "name": JSONSchema(
                    type: .string,
                    description: "The name of the food item"
                ),
                "calories": JSONSchema(
                    type: .number,
                    description: "The estimated calories in the food"
                ),
                "carbs": JSONSchema(
                    type: .number,
                    description: "The estimated carbohydrates in grams"
                ),
                "fat": JSONSchema(
                    type: .number,
                    description: "The estimated fat content in grams"
                ),
                "protein": JSONSchema(
                    type: .number,
                    description: "The estimated protein content in grams"
                )
            ],
            required: ["name", "calories", "carbs", "fat", "protein"],
            additionalProperties: false
        )
        
        // Create the response format schema
        let responseFormatSchema = JSONSchemaResponseFormat(
            name: "nutrition_analysis",
            strict: true,
            schema: nutritionSchema
        )
        
        let systemMessage = ChatCompletionParameters.Message(
            role: .system,
            content: .text("You are a nutrition expert. Analyze the food in the image and provide accurate nutritional information. Estimate portion sizes carefully and provide realistic nutritional values. Always respond with the exact JSON structure requested.")
        )
        
        let userMessage = ChatCompletionParameters.Message(
            role: .user,
            content: .contentArray([
                .text("Analyze this food image and provide nutritional information including name, calories, carbs, fat, and protein. Be as accurate as possible with portion size estimation."),
                .imageUrl(.init(url: URL(string: "data:image/jpeg;base64,\(jpeg.base64EncodedString())")!)) 
            ])
        )
        
        // Use structured output with response format
        let parameters = ChatCompletionParameters(
            messages: [systemMessage, userMessage],
            model: .gpt4o,
            responseFormat: .jsonSchema(responseFormatSchema),
            temperature: 0
        )
        
        do {
            let completion = try await openAIService.startChat(parameters: parameters)
            
            guard let content = completion.choices?.first?.message?.content else {
                throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No content in response"])
            }
            
            print("AI Response: \(content)")
            
            // Parse the JSON response directly since it's guaranteed to be valid JSON
            guard let jsonData = content.data(using: String.Encoding.utf8) else {
                throw NSError(domain: "OpenAI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not convert response to data"])
            }
            
            let nutritionData = try JSONDecoder().decode(NutritionOutput.self, from: jsonData)
            
            return FoodItem(
                name: nutritionData.name,
                calories: nutritionData.calories,
                carbs: nutritionData.carbs,
                fat: nutritionData.fat,
                protein: nutritionData.protein
            )
            
        } catch {
            print("Error in OpenAI request: \(error)")
            throw error
        }
    }
}

// MARK: - DTOs
private struct NutritionOutput: Decodable {
    let name: String
    let calories: Double
    let carbs: Double
    let fat: Double
    let protein: Double
}
