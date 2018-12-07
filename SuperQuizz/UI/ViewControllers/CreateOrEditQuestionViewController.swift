//
//  CreateOrEditQuestionViewController.swift
//  SuperQuizz
//
//  Created by formation7 on 05/12/2018.
//  Copyright © 2018 formation7. All rights reserved.
//

import UIKit

protocol CreateOrEditQuestionDelegate : AnyObject {
    func userDidEditQuestion(q: Question, from vc : CreateOrEditQuestionViewController) -> ()
    func userDidCreateQuestion(q: Question, from vc : CreateOrEditQuestionViewController) -> ()
}

class CreateOrEditQuestionViewController: UIViewController {
    
    var questionToEdit: Question?
    weak var delegate : CreateOrEditQuestionDelegate?
        
    @IBOutlet weak var questionLabelTextField: UITextField!
    @IBOutlet weak var answer1TextField: UITextField!
    @IBOutlet weak var answer2TextField: UITextField!
    @IBOutlet weak var answer3TextField: UITextField!
    @IBOutlet weak var answer4TextField: UITextField!
    
    @IBOutlet weak var answer1Switch: UISwitch!
    @IBOutlet weak var answer2Switch: UISwitch!
    @IBOutlet weak var answer3Switch: UISwitch!
    @IBOutlet weak var answer4Switch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        answer1Switch.setOn(false, animated: true)
        answer2Switch.setOn(false, animated: true)
        answer3Switch.setOn(false, animated: true)
        answer4Switch.setOn(false, animated: true)
        
        if let question = questionToEdit {
            questionLabelTextField.text = question.questionTitleLabel
            answer1TextField.text = question.propositions[0]
            answer2TextField.text = question.propositions[1]
            answer3TextField.text = question.propositions[2]
            answer4TextField.text = question.propositions[3]
            
            if question.checkAnswer(answer: question.propositions[0]) {
                answer1Switch.setOn(true, animated: true)
            } else if question.checkAnswer(answer: question.propositions[1]) {
                answer2Switch.setOn(true, animated: true)
            } else if question.checkAnswer(answer: question.propositions[2]) {
                answer3Switch.setOn(true, animated: true)
            } else {
                answer4Switch.setOn(true, animated: true)
            }
        } else {
            answer1Switch.setOn(true, animated: true)
        }
    }
    
    func createOrEditQuestion () {
        if isFullyFilled() {
        
            let questionLabel = questionLabelTextField.text ?? "no question label"
            let answer1 = answer1TextField.text ?? "no label 1"
            let answer2 = answer2TextField.text ?? "no label 2"
            let answer3 = answer3TextField.text ?? "no label 3"
            let answer4 = answer4TextField.text ?? "no label 4"
            
            var correctAnswer: String
            if answer1Switch.isOn {
                correctAnswer = answer1
            } else if answer2Switch.isOn {
                correctAnswer = answer2
            } else if answer3Switch.isOn {
                correctAnswer = answer3
            } else {
                correctAnswer = answer4
            }
            
            if let question = questionToEdit {
                question.questionTitleLabel = questionLabel
                question.propositions[0] = answer1
                question.propositions[1] = answer2
                question.propositions[2] = answer3
                question.propositions[3] = answer4
                question.correctAnswer = correctAnswer
                
                delegate?.userDidEditQuestion(q: question, from: self)
            } else {
                let question = Question(titleLabel: questionLabel)
                question.addProposition(proposition: answer1)
                question.addProposition(proposition: answer2)
                question.addProposition(proposition: answer3)
                question.addProposition(proposition: answer4)
                question.correctAnswer = correctAnswer
                
                delegate?.userDidCreateQuestion(q: question, from: self)
            }
        } else {
            let notFullyFilledAlert = UIAlertController(title: "Attention", message: "Chaque champ doit être rempli pour valider", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction) in }
            notFullyFilledAlert.addAction(action)
            self.present(notFullyFilledAlert, animated: true, completion: nil)
        }
    }
    
    func isFullyFilled() -> Bool {
        if answer1TextField.text != "" && answer2TextField.text != "" && answer3TextField.text != ""
            && answer4TextField.text != "" && questionLabelTextField.text != "" {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func userDidSwitchAnswer(_ sender: UISwitch) {
        answer1Switch.setOn(false, animated: true)
        answer2Switch.setOn(false, animated: true)
        answer3Switch.setOn(false, animated: true)
        answer4Switch.setOn(false, animated: true)
        
        sender.setOn(true, animated: true)
    }

    @IBAction func userDidTapValidate(_ sender: UIButton) {
        createOrEditQuestion()
    }
    
    @IBAction func userDidTapCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
