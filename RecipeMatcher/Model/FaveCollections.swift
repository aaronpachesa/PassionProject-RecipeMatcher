//  FaveCollections.swift
//  RecipeMatcher
//  Created by Eric Widjaja on 8/10/20.
//  Copyright © 2020 Eric W. All rights reserved.

import Foundation

struct FaveCollections: Codable {
    let recipeType: String
    let recipeTitle: String
    let recipes: [RecipeWrapper]
    
    init(recipeType: String, recipeTitle: String, recipes: [RecipeWrapper]) {
        self.recipeType = recipeType
        self.recipeTitle = recipeTitle
        self.recipes = recipes
    }
}
