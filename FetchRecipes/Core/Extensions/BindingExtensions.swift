//
//  BindingExtensions.swift
//  FetchRecipes
//
//  Created by Roman Temchenko on 2025-02-26.
//

import SwiftUI

extension Binding {
    
    func asBool<T: Sendable>() -> Binding<Bool> where Value == Optional<T> {
        Binding<Bool> {
            self.wrappedValue != nil
        }
        set: {
            newValue in
            if !newValue {
                self.wrappedValue = nil
            }
        }
    }
}
