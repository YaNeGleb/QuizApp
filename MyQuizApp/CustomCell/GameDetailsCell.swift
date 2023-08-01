//
//  GameDetailsCell.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 30.07.2023.
//

import UIKit

class GameDetailsCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var quizImageView: UIImageView!
    
    func configure(with game: QuestionGame, cellNumber: Int) {
        questionLabel.text = "\(game.question ?? "Нет данных")"
        answerLabel.text = "Ответ: \(game.userAnswer ?? "Нет данных")"
        correctAnswerLabel.text = "Ваш ответ: \(game.correctAnswer ?? "Нет данных")"
        

            if let imageUrlString = game.image, let imageUrl = URL(string: imageUrlString) {
                quizImageView.loadImage(fromURL: imageUrl)
                quizImageView.layer.cornerRadius = 16
                quizImageView.isHidden = false
            } else {
                quizImageView.isHidden = true
            }
        
        
        colorView.layer.cornerRadius = 16
        
        if game.userAnswer == game.correctAnswer {
            colorView.backgroundColor = .green
        } else {
            colorView.backgroundColor = .systemRed
        }
        
        percentLabel.text = "\(cellNumber + 1)"
    }
}
