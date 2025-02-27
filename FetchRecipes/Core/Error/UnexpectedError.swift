//
//  UnexpectedError.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-25.
//

import Foundation

/// Simple error implementation to communicate errors within the app.
/// Mostly useful for debug information logging.
/// Should not be used for business logic purposes.
struct UnexpectedError: Error, LocalizedError {
    let message: String
    
    var errorDescription: String? { message }
}
