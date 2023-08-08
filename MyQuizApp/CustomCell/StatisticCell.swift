//
//  StatisticCell.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 07.08.2023.
//

import UIKit

class StatisticCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    // MARK: - Animation
    private var animationTimer: Timer?
    private var colorIndex: CGFloat = 0.0
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        startColorAnimation()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopColorAnimation()
    }
    
    // MARK: - Configuration
    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        startColorAnimation()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
    
    // MARK: - Color Animation
    private func startColorAnimation() {
        animationTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateBorderColor), userInfo: nil, repeats: true)
    }
    
    @objc private func updateBorderColor() {
        colorIndex += 0.01
        let red = (sin(0.3 * colorIndex) + 1.0) / 2.0
        let green = (sin(0.3 * colorIndex + 2.0) + 1.0) / 2.0
        let blue = (sin(0.3 * colorIndex + 4.0) + 1.0) / 2.0
        
        layer.borderWidth = 2.0
        layer.borderColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor
    }
    
    private func stopColorAnimation() {
        animationTimer?.invalidate()
    }
}

    
    
