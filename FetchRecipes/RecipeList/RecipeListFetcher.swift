//
//  RecipeListRemoteFetcher.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-24.
//

import Foundation

protocol RecipeListFetcher: Sendable {
    func fetchRecipes() async throws -> [Recipe]
}

final class RecipeListRemoteFetcher: RecipeListFetcher {
    
    struct RecipesResponse: Codable {
        let recipes: [Recipe]
    }
    
    let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!
    let urlSession = URLSession.shared
    let decoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func fetchRecipes() async throws -> [Recipe] {
        do {
            let data = try await urlSession.data(from: url).0
            let recipes = try decoder.decode(RecipesResponse.self, from: data).recipes
            
            return recipes
        }
        catch {
            print("Error when fetching recipes: \(error)")
            throw error
        }
    }
    
}

#if targetEnvironment(simulator)
final class RecipeListPreviewFetcher: RecipeListFetcher {
    
    func fetchRecipes() async throws -> [Recipe] {
        return [Recipe.test]
    }
    
}
#endif
