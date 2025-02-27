//
//  RecipeListViewModelTests.swift
//  FetchRecipesTests
//
//  Created by Roman Temchenko on 2025-02-26.
//

import Testing
@testable import FetchRecipes

@MainActor
final class RecipeListFetcherMock: RecipeListFetcher {
    
    private var resultRecipes: [Recipe]?
    private var resultError: Error?
    
    func setResultRecipes(_ resultRecipes: [Recipe]?) {
        self.resultRecipes = resultRecipes
    }
    
    func setResultError(_ resultError: Error?) {
        self.resultError = resultError
    }
    
    func fetchRecipes() async throws -> [Recipe] {
        if let resultRecipes {
            return resultRecipes
        }
        else if let resultError {
            throw resultError
        }
        else {
            fatalError("Unexpected call with no stub provided")
        }
    }
}

@MainActor
struct RecipeListViewModelTests {

    @Test func testStart() async throws {
        let fetcher = RecipeListFetcherMock()
        let sut = RecipeListViewModel(fetcher: fetcher)
        fetcher.setResultRecipes([Recipe.test])
        
        sut.start()
        
        try? await Task.sleep(for: .milliseconds(16))
        #expect(sut.recipes == [Recipe.test])
    }

    @Test func testReload() async throws {
        let fetcher = RecipeListFetcherMock()
        let sut = RecipeListViewModel(fetcher: fetcher)
        fetcher.setResultRecipes([Recipe.test])
        
        await sut.reload()
        
        try? await Task.sleep(for: .milliseconds(16))
        #expect(sut.recipes == [Recipe.test])
    }
    
    @Test func testFetchError() async throws {
        let fetcher = RecipeListFetcherMock()
        let sut = RecipeListViewModel(fetcher: fetcher)
        fetcher.setResultError(UnexpectedError(message: "test"))
        
        await sut.reload()
        
        try? await Task.sleep(for: .milliseconds(16))
        #expect((sut.fetchError as? UnexpectedError)?.message == "test")
    }
}
