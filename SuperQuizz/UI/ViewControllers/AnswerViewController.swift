//
//  ViewController.swift
//  SuperQuizz
//
//  Created by formation7 on 04/12/2018.
//  Copyright © 2018 formation7. All rights reserved.
//

import UIKit

class AnswerViewController: UIViewController {
    
    var question: Question!
    var onQuestionAnswered: ((_ q: Question, _ isCorrectAnswer: Bool) -> ())?

    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var buttonAnswer1: UIButton!
    @IBOutlet weak var buttonAnswer2: UIButton!
    @IBOutlet weak var buttonAnswer3: UIButton!
    @IBOutlet weak var buttonAnswer4: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTitleLabel.text = question.questionTitleLabel
        buttonAnswer1.setTitle(question.propositions[0], for: .normal)
        buttonAnswer2.setTitle(question.propositions[1], for: .normal)
        buttonAnswer3.setTitle(question.propositions[2], for: .normal)
        buttonAnswer4.setTitle(question.propositions[3], for: .normal)
        
    }
    
    func setOnReponseAnswered(closure : @escaping (_ question: Question,_ isCorrectAnswer :Bool)->()) {
        onQuestionAnswered = closure
    }

    func userDidChooseAnswer(isCorrectAnswer: Bool) {
        // do animation according to user answer
        onQuestionAnswered?(question, isCorrectAnswer)
    }
    
    @IBAction func userDidChooseAnswer(_ sender: UIButton) {
        userDidChooseAnswer(isCorrectAnswer: question.checkAnswer(answer: sender.titleLabel?.text ?? "......."))
    }
    
}

