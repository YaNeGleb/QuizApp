//
//  ButtonCell.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 16.07.2023.
//

import UIKit

class ButtonCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var countQuestionsLabel: UILabel!
    
    // MARK: - Properties
    var isSelectedCell: Bool = false {
        didSet {
            if isSelectedCell {
                categoryLabel.layer.borderWidth = 2.0
                categoryLabel.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                categoryLabel.layer.borderWidth = 0.0
                categoryLabel.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        categoryLabel.layer.masksToBounds = true
        categoryLabel.layer.cornerRadius = 30
    }
}
