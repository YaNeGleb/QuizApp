//
//  GameDetailsViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 30.07.2023.
//

import UIKit
import CoreData

class GameDetailsViewController: UIViewController {
    // MARK: - Properties
    var selectedGame: RecordGame?
    var percentage: Int = 0
    var questions: [QuestionGame] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - View Setup
    private func setupView() {
        setupTableView()
        calculatePercentageScore()
        setupNavigationBar()
        fetchQuestionsForSelectedGame()
    }
    
    private func setupNavigationBar() {
        title = "Отчет по игре"
        let percentageColor = colorForPercentageScore()
        let barButtonItem = UIBarButtonItem(title: "\(percentage)%", style: .plain, target: self, action: nil)
        barButtonItem.tintColor = percentageColor
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "GameDetailsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GameDetailsCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Percentage Calculation
    private func calculatePercentageScore() {
        if let selectedGame = selectedGame {
            let totalQuestionsAnswered = Float(selectedGame.completedQuestions)
            let userScore = Float(selectedGame.countCorrectAnswer)
            
            if totalQuestionsAnswered > 0 {
                percentage = Int((userScore / totalQuestionsAnswered) * 100)
            } else {
                percentage = 0
            }
        }
    }
    
    private func colorForPercentageScore() -> UIColor {
        switch percentage {
        case 0...30:
            return .systemRed
        case 31...60:
            return .systemOrange
        case 61...80:
            return .systemYellow
        case 81...100:
            return .systemGreen
        default:
            return .systemBlue
        }
    }
    
    // MARK: - Fetch Questions
    private func fetchQuestionsForSelectedGame() {
        if let questionsSet = selectedGame?.questions?.array as? [QuestionGame] {
            questions = questionsSet
        }
    }
}

// MARK: - UITableViewDelegate
extension GameDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDataSource
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
