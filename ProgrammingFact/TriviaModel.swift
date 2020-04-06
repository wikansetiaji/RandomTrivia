//
//  FactQuestion.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 04/03/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import Foundation

class TriviaModel:Codable{
    var question: Data
    var correct_answer:Data
    
    var index = 0
    var last = false
    var first = false
    
    var title: String{
        get {
            return String(data: question, encoding: .utf8)!
        }
        
    }
    var answer: Bool{
        get{
            let ansString = String(data: correct_answer, encoding: .utf8)!
            if (ansString=="True"){
                return true
            }
            else{
                return false
            }
        }
    }
    
    var answered = false
    var status:String = ""
    
    private enum CodingKeys: String, CodingKey {
        case question
        case correct_answer
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decode(Data.self, forKey: .question)
        correct_answer = try container.decode(Data.self, forKey: .correct_answer)
    }

}
