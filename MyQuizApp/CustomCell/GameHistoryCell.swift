//
//  GameHistoryCell.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 29.07.2023.
//

import UIKit
import Foundation

class GameHistoryCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var completedQuestions: UILabel!
    @IBOutlet weak var userScoreLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    
    var percentage: Int = 0
    
    func configure(with game: RecordGame) {
        categoryLabel.text = game.category
        startDateLabel.text = formatDate(game.date)
        completedQuestions.text = "Вопросов: \(game.completedQuestions) / \(game.countQuestions)"
        userScoreLabel.text = "Счет: \(game.countCorrectAnswer)"
        
        let totalQuestionsAnswered = Float(game.completedQuestions)
            let userScore = Float(game.countCorrectAnswer)

            if totalQuestionsAnswered > 0 {
                percentage = Int((userScore / totalQuestionsAnswered) * 100)
            } else {
                percentage = 0
            }
        
        percentLabel.textColor = .white
        percentLabel.text = "\(percentage)%"
        
        colorView.layer.cornerRadius = 25
        
        
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
    
    private func formatDate(_ date: Date?) -> String {
            guard let date = date else {
                return ""
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter.string(from: date)
        }
    
}
