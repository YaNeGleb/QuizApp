//
//  GameHistoryCell.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 29.07.2023.
//

import UIKit

class GameHistoryCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var userAnswerLabel: UILabel!
    
    
    func configure(with game: GameRecord) {
          questionLabel.text = game.question
          categoryLabel.text = "Категория: \(game.category)"
          userAnswerLabel.text = "Ответ: \(game.userAnswer)"
      }
    
}
