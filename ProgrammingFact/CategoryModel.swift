//
//  CategoryModel.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 11/03/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import Foundation

class CategoryModel:Codable{
    var id:Int
    var name:String
    
    var title: String{
        get {
            if (name.contains(": ")){
                var result = String(name.split(separator: ":")[1])
                result.removeFirst()
                return result
            }
            else{
                return name
            }
        }
        
    }
    
    init(_ id:Int, _ name:String) {
        self.id = id
        self.name = name
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
