//
//  FactCell.swift
//  ProgrammingFact
//
//  Created by Wikan Setiaji on 03/03/20.
//  Copyright © 2020 Wikan Setiaji. All rights reserved.
//

import UIKit

class FactCell: UICollectionViewCell {
    @IBOutlet weak var factText:UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var buttonTrue: UIButton!
    @IBOutlet weak var buttonFalse: UIButton!
    @IBOutlet weak var answerText:UILabel!
    @IBOutlet weak var correctionText:UILabel!
    @IBOutlet weak var nextButton:UIButton!
    @IBOutlet weak var prevButton:UIButton!
    
    var viewController:CategoryViewController?
    
    var fact:FactModel!{
        didSet{
            update()
        }
    }
    
    func update(){
        
        factText.text = fact.title
        answerText.text = fact.status

        if (fact.answered){
            if (fact.answer){
                correctionText.text = "It's the Truth 😇"
            }
            else{
                correctionText.text = "It's a Lie 😈"
            }
            buttonTrue.isHidden = true
            buttonFalse.isHidden = true
            answerText.isHidden = false
            correctionText.isHidden = false
        }
        else{
            buttonTrue.isHidden = false
            buttonFalse.isHidden = false
            answerText.isHidden = true
            correctionText.isHidden = true
        }
    }
    
    func answer(answer:Bool){
        let actual = fact.answer
        fact.answered = true
        if (answer == actual){
            fact.status="You're Correct 👍"
            viewController?.answer(answer:true)
        }
        else{
            fact.status="You're Wrong 😔"
            viewController?.answer(answer:false)
        }
        update()
    }
    
    @IBAction func trueButtonClicked(_ sender: Any) {
        answer(answer: true)
    }
    
    @IBAction func falseButtonClicked(_ sender: Any) {
        answer(answer: false)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        viewController?.next(current:fact.index)
    }
    
    @IBAction func prevButtonClicked(_ sender: Any) {
        viewController?.prev(current:fact.index)
    }
}
