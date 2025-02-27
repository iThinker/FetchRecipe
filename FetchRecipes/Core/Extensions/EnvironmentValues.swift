//
//  EnvironmentValues.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-26.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var imageLoader: ImageLoader = ImageLoaderImpl.shared
}
