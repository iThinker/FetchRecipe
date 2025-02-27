//
//  RecipeListViewCell.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-25.
//

import SwiftUI

struct RecipeListViewCell: View {
    
    let recipe: Recipe
    
    @State var image: UIImage? = nil
    @Environment(\.imageLoader) var imageLoader
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            imageView
            VStack(alignment: .leading) {
                Text("Name: \(recipe.name)")
                    .font(.headline)
                Text("Cuisine: \(recipe.cuisine)")
                    .font(.subheadline)
                webSection
            }
        }
        .task {
            if let url = recipe.photoUrlSmall {
                self.image = try? await self.imageLoader.image(for: url)
            }
        }
    }
    
    private var imageView: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            else {
                Image(systemName: "fork.knife")
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(Color.secondary))
            }
        }
        .frame(width: 80, height: 80)
    }
    
    private var webSection: some View {
        Group {
            if recipe.sourceUrl != nil || recipe.youtubeUrl != nil {
                HStack {
                    Spacer()
                    if let url = recipe.sourceUrl {
                        Link(destination: url) {
                            linkImage(name: "globe",
                                      backgroundColor: .blue)
                        }
                    }
                    if let url = recipe.youtubeUrl {
                        Link(destination: url) {
                            linkImage(name: "play.rectangle",
                                      backgroundColor: .red)
                        }
                    }
                }
            }
        }
    }
    
    private func linkImage(name: String, backgroundColor: Color) -> some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .frame(width: 25, height: 25)
            .foregroundColor(.white)
            .padding(5)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    List {
        RecipeListViewCell(recipe: Recipe.test)
    }.listStyle(.plain)
}
