//
//  Recipe.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-24.
//

import Foundation

struct Recipe: Codable, Identifiable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case name, cuisine, photoUrlSmall, sourceUrl, youtubeUrl
        case id = "uuid"
    }
    
    // The unique identifier for the receipe.
    let id: UUID
    
    // The name of the recipe.
    let name: String
    
    // The cuisine of the recipe.
    let cuisine: String
    
    // The URL of the recipes’s small photo. Useful for list view.
    let photoUrlSmall: URL?
    
    // The URL of the recipe's original website.
    let sourceUrl: URL?
    
    // The URL of the recipe's YouTube video.
    let youtubeUrl: URL?
}

#if targetEnvironment(simulator)
extension Recipe {
    
    static let test = Recipe(id: UUID(),
                             name: "Test recipe",
                             cuisine: "Test cuisine",
                             photoUrlSmall: nil,
                             sourceUrl: URL(string: "google.com"),
                             youtubeUrl: URL(string:"https://www.youtube.com/watch?v=dQw4w9WgXcQ"))
    
}
#endif
