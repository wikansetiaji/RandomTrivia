//
//  APIRequest.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 26/12/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import Foundation

class APIRequest{
    static let shared = APIRequest()
    
    enum Error {
        case zeroItem
        case noInternet
    }
    
    var task: URLSessionDataTask?
    
    func fetchFacts(id:Int, successFetch: @escaping ([FactModel]) -> Void, errorFetch: @escaping (Error) -> Void) {
        let url = URL(string: "https://opentdb.com/api.php?amount=5&category=\(id)&type=boolean&encode=base64")!
        
        task?.cancel()
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                errorFetch(Error.noInternet)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error")
                errorFetch(Error.noInternet)
                return
            }
            
            if let data = data{
                let result = try! JSONDecoder().decode(FactResponse.self, from: data)
                if (result.results.count == 0){
                    errorFetch(Error.zeroItem)
                    return
                }
                successFetch(result.results)
            }
        })
        task?.resume()
    }
    
    func fetchCategories(successFetch: @escaping ([CategoryModel]) -> Void, errorFetch: @escaping (Error) -> Void) {
        let url = URL(string: "https://opentdb.com/api_category.php")!
        
        task?.cancel()
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                errorFetch(Error.noInternet)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error")
                errorFetch(Error.noInternet)
                return
            }
            
            if let data = data{
                let result = try! JSONDecoder().decode(CategoryResponse.self, from: data)
                if (result.trivia_categories.count == 0){
                    errorFetch(Error.zeroItem)
                    return
                }
                successFetch(result.trivia_categories)
            }
        })
        
        task?.resume()
    }
}
