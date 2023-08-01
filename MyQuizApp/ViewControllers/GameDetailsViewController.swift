//
//  GameDetailsViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 30.07.2023.
//

import UIKit
import CoreData

class GameDetailsViewController: UIViewController {
    
    var selectedGame: RecordGame?
    var percentage: Int = 0
    var questions: [QuestionGame] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Отчет по игре"
        
        let nib = UINib(nibName: "GameDetailsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GameDetailsCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        
        if let selectedGame = selectedGame {
            let totalQuestionsAnswered = Float(selectedGame.completedQuestions)
            let userScore = Float(selectedGame.countCorrectAnswer)
            
            if totalQuestionsAnswered > 0 {
                percentage = Int((userScore / totalQuestionsAnswered) * 100)
            } else {
                percentage = 0
            }
        }
        
        let barButtonItem = UIBarButtonItem(title: "\(percentage)%", style: .plain, target: self, action: nil)
        
        switch percentage {
        case 0...30:
            barButtonItem.tintColor = .systemRed
        case 31...60:
            barButtonItem.tintColor = .systemOrange
        case 61...80:
            barButtonItem.tintColor = .systemYellow
        case 81...100:
            barButtonItem.tintColor = .systemGreen
        default:
            barButtonItem.tintColor = .systemBlue
        }
        
        navigationItem.rightBarButtonItem = barButtonItem
        
        if let questionsSet = selectedGame?.questions?.array as? [QuestionGame] {
            questions = questionsSet
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    
    
    
    
}

extension GameDetailsViewController: UITableViewDelegate {}

extension GameDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameDetailsCell", for: indexPath) as! GameDetailsCell
        
        
        let question = questions[indexPath.row]
        cell.configure(with: question, cellNumber: indexPath.row)
        
        return cell
    }
}


