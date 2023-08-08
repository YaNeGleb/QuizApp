//
//  GameDetailsCell.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 30.07.2023.
//

import UIKit

class GameDetailsCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var quizImageView: UIImageView!
    
    // MARK: - Configure Cell
    func configure(with game: QuestionGame, cellNumber: Int) {
        setupImageView(with: game)
        setupColorView(with: game)
        setupLabels(with: game, cellNumber: cellNumber)
    }
    
    // MARK: - Setup Image View
    private func setupImageView(with game: QuestionGame) {
        if let imageUrlString = game.image, let imageUrl = URL(string: imageUrlString) {
            quizImageView.loadImage(fromURL: imageUrl)
            quizImageView.layer.cornerRadius = 16
            quizImageView.isHidden = false
        } else {
            quizImageView.isHidden = true
        }
    }
    
    // MARK: - Setup Color View
    private func setupColorView(with game: QuestionGame) {
        colorView.layer.cornerRadius = 16
        
        if game.userAnswer == game.correctAnswer {
            colorView.backgroundColor = .green
        } else {
            colorView.backgroundColor = .systemRed
        }
    }
    
    // MARK: - Setup Labels
    private func setupLabels(with game: QuestionGame, cellNumber: Int) {
        questionLabel.text = "\(game.question ?? "Нет данных")"
        answerLabel.text = "Ответ: \(game.userAnswer ?? "Нет данных")"
        correctAnswerLabel.text = "Ваш ответ: \(game.correctAnswer ?? "Нет данных")"
        percentLabel.text = "\(cellNumber + 1)"
    }
}
