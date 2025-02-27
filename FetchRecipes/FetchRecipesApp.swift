//
//  FetchRecipesApp.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-24.
//

import SwiftUI

@main
struct FetchRecipesApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView(viewModel: RecipeListViewModel())
        }
    }
}
