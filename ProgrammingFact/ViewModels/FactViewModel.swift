//
//  FactViewModel.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 26/12/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import Foundation

class FactViewModel{
    var facts: [FactModel] = []{
        didSet{
            factsChanged?(facts)
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
    var factsChanged: (([FactModel]) -> Void)?
    var errorChanged: ((APIRequest.Error?) -> Void)?
    
    func fetchCategories(id: Int){
        isLoading = true
        APIRequest.shared.fetchFacts(id:id) { (facts) in
            self.isLoading = false
            self.facts = facts
        } errorFetch: { (err) in
            self.isLoading = false
            self.error = err
        }

    }
}
