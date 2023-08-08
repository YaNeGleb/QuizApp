//
//  GameHistoryCell.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 29.07.2023.
//

import UIKit

class GameHistoryCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var completedQuestions: UILabel!
    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    
    var percentage: Int = 0
    
    // MARK: - Configuration
    func configure(with game: RecordGame) {
        setupUI(with: game)
        calculatePercentage(with: game)
        setColorViewBackgroundColor()
    }
    
    private func setupUI(with game: RecordGame) {
        categoryLabel.text = game.category
        startDateLabel.text = formatDate(game.date)
        completedQuestions.text = "Вопросов: \(game.completedQuestions) / \(game.countQuestions)"
        userScoreLabel.text = "Счет: \(game.countCorrectAnswer)"
        percentLabel.textColor = .white
        colorView.layer.cornerRadius = 25
    }
    
    private func calculatePercentage(with game: RecordGame) {
        let totalQuestionsAnswered = Float(game.completedQuestions)
        let userScore = Float(game.countCorrectAnswer)
        
        if totalQuestionsAnswered > 0 {
            percentage = Int((userScore / totalQuestionsAnswered) * 100)
        } else {
            percentage = 0
        }
        percentLabel.text = "\(percentage)%"
    }
    
    private func setColorViewBackgroundColor() {
        switch percentage {
        case 0...30:
            colorView.backgroundColor = .red
        case 31...60:
            colorView.backgroundColor = .orange
        case 61...80:
            colorView.backgroundColor = .yellow
        case 81...100:
            colorView.backgroundColor = .green
        default:
            colorView.backgroundColor = .systemBlue
        }
    }
    
    // MARK: - Helper Method
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}
