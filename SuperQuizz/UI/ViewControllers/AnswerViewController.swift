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
    
    @IBOutlet weak var progressViewAnswer: UIProgressView!
    var work: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionTitleLabel.text = question.questionTitleLabel
        buttonAnswer1.setTitle(question.propositions[0], for: .normal)
        buttonAnswer2.setTitle(question.propositions[1], for: .normal)
        buttonAnswer3.setTitle(question.propositions[2], for: .normal)
        buttonAnswer4.setTitle(question.propositions[3], for: .normal)
        
        self.work = DispatchWorkItem {
            for i in 1...50 {
                if self.work!.isCancelled {
                    break
                }
                Thread.sleep(forTimeInterval: 0.1)
                
                DispatchQueue.main.async {
                    self.progressViewAnswer.progress = Float(i) * 0.02
                    if i == 50 {
                        self.onQuestionAnswered?(self.question, false)
                    }
                }
            }
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: self.work!)
    }
    
    func setOnReponseAnswered(closure : @escaping (_ question: Question,_ isCorrectAnswer :Bool)->()) {
        onQuestionAnswered = closure
    }

    func userDidChooseAnswer(isCorrectAnswer: Bool) {
        // do animation according to user answer
        self.work!.cancel()
        onQuestionAnswered?(question, isCorrectAnswer)
    }
    
    @IBAction func userDidChooseAnswer(_ sender: UIButton) {
        print(question.checkAnswer(answer: sender.titleLabel?.text ?? "......."))
        userDidChooseAnswer(isCorrectAnswer: question.checkAnswer(answer: sender.titleLabel?.text ?? "......."))
    }
}

