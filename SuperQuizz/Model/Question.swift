//
//  Question.swift
//  SuperQuizz
//
//  Created by formation7 on 04/12/2018.
//  Copyright © 2018 formation7. All rights reserved.
//

import Foundation

class Question {
    var questionID: Int?
    var questionTitleLabel: String
    var propositions = [String]()
    var correctAnswer: String?
    var userAnswer: String?
    
    init(titleLabel: String) {
        self.questionTitleLabel = titleLabel
    }
    
    func addProposition (proposition: String) {
        self.propositions.append(proposition)
    }
    
    func checkAnswer(answer: String) -> Bool {
        if correctAnswer == answer {
            return true
        } else {
            return false
        }
    }
    
    func getCorrectAnswerIndex() -> Int {
        if checkAnswer(answer: propositions[0]) {
            return 1
        } else if checkAnswer(answer: propositions[1]) {
            return 2
        } else if checkAnswer(answer: propositions[2]) {
            return 3
        } else {
            return 4
        }
    }
}
