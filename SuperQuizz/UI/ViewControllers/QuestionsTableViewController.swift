//
//  QuestionsTableViewController.swift
//  SuperQuizz
//
//  Created by formation7 on 04/12/2018.
//  Copyright © 2018 formation7. All rights reserved.
//

import UIKit

class QuestionsTableViewController: UITableViewController {
    
    var listQuestions = [Question]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SuperQuizz"
        
        let q1 = Question(titleLabel: "Qui est le plus balaise ?")
        q1.addProposition(proposition: "Superman")
        q1.addProposition(proposition: "Slipman")
        q1.addProposition(proposition: "Batman")
        q1.addProposition(proposition: "Captain Poo")
        q1.correctAnswer = "Batman"
        
        let q2 = Question(titleLabel: "Quelle est la couleur ?")
        q2.addProposition(proposition: "Rouge")
        q2.addProposition(proposition: "Bleu")
        q2.addProposition(proposition: "Vert")
        q2.addProposition(proposition: "Jaune")
        q2.correctAnswer = "Bleu"
        
        let q3 = Question(titleLabel: "Est-ce que le swift c'est cool ?")
        q3.addProposition(proposition: "ouais")
        q3.addProposition(proposition: "bof")
        q3.addProposition(proposition: "ça claque !")
        q3.addProposition(proposition: "non")
        q3.correctAnswer = "ça claque !"
        
        listQuestions.append(q1)
        listQuestions.append(q2)
        listQuestions.append(q3)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName:"QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       refreshViewFromServer()
    }
    
    //Mark: Refresh
    func refreshViewFromServer(){
        APIClient.instance.getAllQuestionsFromServer(
            onSuccess: { (questions) in
                //self.listQuestions = questions
                self.listQuestions = questions
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }) { (error) in
            print(error)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listQuestions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTableViewCell", for: indexPath)
            as! QuestionTableViewCell
        
        let q = listQuestions[indexPath.row]
        
        cell.questionTitltLabel.text = "\(String(q.questionID ?? 0)). \(q.questionTitleLabel)"
        
        if let userAnswer = q.userAnswer {
            if (q.checkAnswer(answer: userAnswer)) {
                cell.backgroundColor = UIColor.green
            } else {
                cell.backgroundColor = UIColor.red
            }
        } else {
             cell.backgroundColor = UIColor.white
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "AnswerViewController")
            as? AnswerViewController else {
                return
        }
        
        controller.question = listQuestions[indexPath.row]
        
        controller.setOnReponseAnswered { (questionAnswered, result) in
            self.navigationController?.popViewController(animated: true)
            
            if result {
                self.listQuestions[indexPath.row].userAnswer = questionAnswered.correctAnswer
            } else {
                self.listQuestions[indexPath.row].userAnswer = (questionAnswered.correctAnswer ?? "") + "_wrong"
            }
            
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreateOrEditQuestionViewController" {
            let controller = segue.destination as! CreateOrEditQuestionViewController
            controller.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edition") { (action, indexpath) in
            //TODO: edit question
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateOrEditQuestionViewController") as! CreateOrEditQuestionViewController
            controller.delegate = self
            controller.questionToEdit = self.listQuestions[indexPath.row]
            self.present(controller, animated: true, completion: nil)
        }
        
        //Creer l'action de suppresion de la liste
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Supression") { (action, indexpath) in
            
            let questionDeleteAlert = UIAlertController(title: "Suppression de question", message: "Que voulez-vous faire ?", preferredStyle: .alert)
            
            let actionDelete = UIAlertAction(title: "Supprimer", style: .destructive) { (action: UIAlertAction) in
                let question = self.listQuestions[indexPath.row]
                
                APIClient.instance.deleteQuestionFromServer(id: question.questionID! ,onSuccess: {
                    DispatchQueue.main.async {
                        self.listQuestions.remove(at: indexPath.row)
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.endUpdates()
                    }
                }, onError: { (error) in
                    print(error)
                })
            }
            let actionCancel = UIAlertAction(title: "Annuler", style: .default)
            
            questionDeleteAlert.addAction(actionCancel)
            questionDeleteAlert.addAction(actionDelete)
            self.present(questionDeleteAlert, animated: true, completion: nil)
        
        }
        return [editAction,deleteAction]
    }
}

extension QuestionsTableViewController : CreateOrEditQuestionDelegate {
    func userDidEditQuestion(q: Question, from vc: CreateOrEditQuestionViewController) {
        APIClient.instance.updateQuestionFromServer(question: q, onSuccess: {
            
        }, onError: { (error) in
            print(error)
        })
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        self.tableView.reloadData()
    }
    
    func userDidCreateQuestion(q: Question, from vc: CreateOrEditQuestionViewController) {
        APIClient.instance.addQuestionFromServer(question: q, onSuccess: {
            
        }, onError: { (error) in
            print(error)
        })
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        self.tableView.reloadData()
    }
}
