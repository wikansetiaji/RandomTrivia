//
//  CategoryViewModel.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 26/12/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import Foundation

class CategoryViewModel{
    var categories: [CategoryModel] = []{
        didSet{
            categoriesChanged?(categories)
        }
    }
    var isLoading = false{
        didSet{
            loadingStateChanged?(isLoading)
        }
    }
    
    var error: APIRequest.Error?{
        didSet{
            errorChanged?(error)
        }
    }
    
    var loadingStateChanged: ((Bool) -> Void)?
    var categoriesChanged: (([CategoryModel]) -> Void)?
    var errorChanged: ((APIRequest.Error?) -> Void)?
    
    func fetchCategories(){
        isLoading = true
        APIRequest.shared.fetchCategories { (categories) in
            self.isLoading = false
            self.categories = categories.sorted(){
                (this, other) in
                return this.title < other.title
            }
        } errorFetch: { (err) in
            self.isLoading = false
            self.error = err
        }

    }
    
}
