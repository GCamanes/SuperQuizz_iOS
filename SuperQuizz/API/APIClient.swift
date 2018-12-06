//
//  APIClient.swift
//  SuperQuizz
//
//  Created by formation7 on 06/12/2018.
//  Copyright © 2018 formation7. All rights reserved.
//

import Foundation

class APIClient {
    
    static let instance = APIClient()
    
    private let urlServer = "http://192.168.10.48:3000"
    private let KEY_SERVER_ID = "id"
    private let KEY_SERVER_LABEL = "title"
    private let KEY_SERVER_ANSWER1 = "answer_1"
    private let KEY_SERVER_ANSWER2 = "answer_2"
    private let KEY_SERVER_ANSWER3 = "answer_3"
    private let KEY_SERVER_ANSWER4 = "answer_4"
    private let KEY_SERVER_GOOD_ANSWER = "correct_answer"
    private let KEY_SERVER_AUTHOR_IMG_URL = "author_img_url"
    private let KEY_SERVER_AUTHOR = "author"
    
    private init () {}
    
    // GET ALL
    @discardableResult
    func getAllQuestionsFromServer(onSuccess:@escaping ([Question])->(), onError:@escaping (Error)->())-> URLSessionTask {
        
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)/questions")! )
        request.httpMethod = "GET"
        
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // si j'ai de la donnée
            if let data = data {
                
                // Je la transforme en Array
                let dataArray = try! JSONSerialization.jsonObject(with: data, options: []) as! [Any]
                var questionsToreturn = [Question]()
                // pour chaque objet d'ans l'array
                for object in dataArray {
                    
                    let objectDictionary = object as! [String:Any]
                    let q  = Question(titleLabel: objectDictionary[self.KEY_SERVER_LABEL] as! String)
                    q.addProposition(proposition: objectDictionary[self.KEY_SERVER_ANSWER1] as! String)
                    q.addProposition(proposition: objectDictionary[self.KEY_SERVER_ANSWER2] as! String)
                    q.addProposition(proposition: objectDictionary[self.KEY_SERVER_ANSWER3] as! String)
                    q.addProposition(proposition: objectDictionary[self.KEY_SERVER_ANSWER4] as! String)
                    
                    let correctAnswer = objectDictionary[self.KEY_SERVER_GOOD_ANSWER] as! NSNumber
                    if correctAnswer == 1 {
                        q.correctAnswer = q.propositions[0]
                    } else if correctAnswer == 2 {
                        q.correctAnswer = q.propositions[1]
                    } else if correctAnswer == 3 {
                        q.correctAnswer = q.propositions[2]
                    } else {
                        q.correctAnswer = q.propositions[3]
                    }
                    q.questionID = objectDictionary[self.KEY_SERVER_ID] as? Int
                    q.authorImageUrl = objectDictionary[self.KEY_SERVER_AUTHOR_IMG_URL] as? String ?? nil
                    questionsToreturn.append(q)
                }
                onSuccess(questionsToreturn)
                
            } else  {
                onError(error!)
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    // DELETE
    @discardableResult
    func deleteQuestionFromServer(id: Int, onSuccess:@escaping ()->(), onError:@escaping (Error)->())-> URLSessionTask {
        
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)/questions/\(String(id))")! )
        request.httpMethod = "DELETE"
        
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // si j'ai de la donnée
            if data != nil {
                onSuccess()
            } else  {
                onError(error!)
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    // POST
    @discardableResult
    func addQuestionFromServer(question: Question, onSuccess:@escaping ()->(), onError:@escaping (Error)->())-> URLSessionTask {
        
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)/questions")! )
        request.httpMethod = "POST"
        
        let jsonObject: [String:Any] = [
            self.KEY_SERVER_LABEL : question.questionTitleLabel,
            self.KEY_SERVER_ANSWER1 : question.propositions[0],
            self.KEY_SERVER_ANSWER2 : question.propositions[1],
            self.KEY_SERVER_ANSWER3 : question.propositions[2],
            self.KEY_SERVER_ANSWER4 : question.propositions[3],
            self.KEY_SERVER_GOOD_ANSWER : question.getCorrectAnswerIndex()
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // si j'ai de la donnée
            if data != nil {
                onSuccess()
            } else  {
                onError(error!)
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
    
    // PUT
    @discardableResult
    func updateQuestionFromServer(question: Question, onSuccess:@escaping ()->(), onError:@escaping (Error)->())-> URLSessionTask {
        
        //préparation de la requete
        var request = URLRequest(url: URL(string: "\(urlServer)/questions/\(String(question.questionID!))")! )
        request.httpMethod = "PUT"
        
        let jsonObject: [String:Any] = [
            self.KEY_SERVER_LABEL : question.questionTitleLabel,
            self.KEY_SERVER_ANSWER1 : question.propositions[0],
            self.KEY_SERVER_ANSWER2 : question.propositions[1],
            self.KEY_SERVER_ANSWER3 : question.propositions[2],
            self.KEY_SERVER_ANSWER4 : question.propositions[3],
            self.KEY_SERVER_GOOD_ANSWER : question.getCorrectAnswerIndex()
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // preparation de la tache de telechargezmebnt des données
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // si j'ai de la donnée
            if data != nil {
                onSuccess()
            } else  {
                onError(error!)
            }
        }
        // lance la tache
        task.resume()
        
        // revoie la tache pour pouvoir l'annuler
        return task
    }
}
