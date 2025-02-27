//
//  RecipeListView.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-24.
//

import SwiftUI

struct RecipeListView: View {
    
    @Bindable var viewModel: RecipeListViewModel
    
    var body: some View {
        Group {
            if let recipes = viewModel.recipes {
                if recipes.isEmpty {
                    ContentUnavailableView("No recipes available", systemImage: "face.dashed")
                }
                else {
                    List {
                        ForEach(recipes) { recipe in
                            RecipeListViewCell(recipe: recipe)
                                .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .alert("Fetch Error",
               isPresented: $viewModel.fetchError.asBool(),
               presenting: viewModel.fetchError,
               actions: { _ in
        }, message: { error in
            Text("\(error)")
        })
        .onAppear {
            viewModel.start()
        }
        .refreshable {
            await viewModel.reload()
        }
    }
    
}

#Preview {
    RecipeListView(viewModel: RecipeListViewModel(fetcher: RecipeListPreviewFetcher()))
}

