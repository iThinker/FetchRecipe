//
//  RecipeListViewModel.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-24.
//

import Foundation
import Observation


@Observable
@MainActor
class RecipeListViewModel {
    
    private let fetcher: any RecipeListFetcher
    
    public var fetchError: Error?
    public private(set) var recipes: [Recipe]?
    
    init(fetcher: some RecipeListFetcher = RecipeListRemoteFetcher()) {
        self.fetcher = fetcher
    }
    
    public func start() {
        Task {
            await reload()
        }
    }
    
    public func reload() async {
        do {
            self.recipes = try await fetcher.fetchRecipes()
        }
        catch {
            self.fetchError = error
        }
    }
    
}

