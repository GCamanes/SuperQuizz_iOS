//
//  QuestionsTableViewController.swift
//  SuperQuizz
//
//  Created by formation7 on 04/12/2018.
//  Copyright © 2018 formation7. All rights reserved.
//

import UIKit
import SwiftIcons

class QuestionsTableViewController: UITableViewController {
    
    var listQuestions = [Question]()
    
    static var colorHighTheme = UIColor(red:0.20, green:0.56, blue:0.56, alpha:1.0)
    static var colorLowTheme = UIColor(red:0.78, green:0.88, blue:0.88, alpha:1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SuperQuizz"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName:"QuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "QuestionTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //refreshViewFromServer()
        synchronizeQuestionsWithServer ()
    }
    
    func synchronizeQuestionsWithServer () {
        
        var questionsServer = [Question]()
        APIClient.instance.getAllQuestionsFromServer(
            onSuccess: { (questions) in
                //self.listQuestions = questions
                questionsServer = questions
                for questionServer in questionsServer {
                    var foundQuestion: Question?
                    
                    for questionAppli in self.listQuestions {
                        if (questionServer.questionID == questionAppli.questionID) {
                            foundQuestion = questionAppli;
                            break;
                        }
                    }
                    
                    if let foundQuestion = foundQuestion {
                        foundQuestion.questionTitleLabel = questionServer.questionTitleLabel
                        foundQuestion.propositions[0] = questionServer.propositions[0]
                        foundQuestion.propositions[1] = questionServer.propositions[1]
                        foundQuestion.propositions[2] = questionServer.propositions[2]
                        foundQuestion.propositions[3] = questionServer.propositions[3]
                    } else {
                        self.listQuestions.append(questionServer)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }) { (error) in
            print(error)
        }
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
        cell.questionTitleLabel.text = "\(q.questionTitleLabel)"
        
        if q.userAnswer != nil {
            if (q.checkAnswer(answer: q.userAnswer ?? "")) {
                cell.questionAnswerView.backgroundColor = UIColor.green
            } else {
                cell.questionAnswerView.backgroundColor = UIColor.red
            }
        } else {
            cell.questionAnswerView.backgroundColor = UIColor.white
        }
        
        //Add image
        if let urlString = q.authorImageUrl {
            guard let url = URL(string: urlString) else {
                return cell
            }
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        cell.questionAuthorImage.image = UIImage(data: data)
                    }
                }
            }
        } else {
            cell.questionAuthorImage.setIcon(icon: .fontAwesomeSolid(.ban))
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
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CreateOrEditQuestionViewController") as! CreateOrEditQuestionViewController
            controller.delegate = self
            controller.questionToEdit = self.listQuestions[indexPath.row]
            self.present(controller, animated: true, completion: nil)
        }
        
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
