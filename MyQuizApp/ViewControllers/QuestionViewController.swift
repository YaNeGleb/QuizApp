//
//  QuestionViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 16.07.2023.
//

import UIKit

protocol QuestionViewControllerDelegate: AnyObject {
    func didCompleteQuiz(with category: String, completedQuestion: Int, questionCount: Int, correctAnswers: Int)
}


class QuestionViewController: UIViewController {
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var countQuestionLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var answerButtonsStackView: UIStackView!
    @IBOutlet weak var helpButton: UIButton!
    
    
    // MARK: - Properties
    var questions: [Question] = []
    var currentQuestionIndex = 0
    var currentQuestion = 1
    var userScore = 0
    var category: Category?
    weak var delegate: QuestionViewControllerDelegate?
    var isAnswerButtonTapped = false
    
    
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        
    }
    
    
    // MARK: - Configure
    func configure() {
        showQuestion()
        
        nextQuestionButton.isHidden = true
        
        progressView.progress = 0.0
        
        customView.layer.cornerRadius = 15
        
    }
    
    // MARK: - Show Question
    func showQuestion() {
        guard let currentQuestion = category?.questions[currentQuestionIndex] else { return }
        questionLabel.text = currentQuestion.question
        questions = category!.questions
        updateScoreLabel()
        setupAnswerButtons()
        
        if let imageURL = URL(string: currentQuestion.imageUrl) {
            // If the image url is valid, display the imageView and load the image
            imageView.isHidden = false
            questionLabel.frame = CGRect(x: 0, y: imageView.frame.maxY + 16, width: customView.bounds.width, height: customView.bounds.height * 0.3)
            
            // Load image from URL
            imageView.loadImage(fromURL: imageURL)
        } else {
            // If the image URL is invalid or missing, hide the imageView and center the questionLabel
            imageView.isHidden = true
            questionLabel.center = CGPoint(x: customView.bounds.midX, y: customView.bounds.midY)
        }
    }
    
    // MARK: - Button Actions
    @IBAction func nextQuestion(_ sender: Any) {
        currentQuestionIndex += 1
        currentQuestion += 1
        if currentQuestionIndex < questions.count {
            showQuestion()
            savePreviousGame()
            nextQuestionButton.isHidden = true
            
            let progress = Float(currentQuestionIndex) / Float(questions.count)
            UIView.animate(withDuration: 0.5) {
                self.progressView.setProgress(progress, animated: true)
            }
        } else {
            showFinalScore()
        }
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
        guard let currentQuestion = category?.questions[currentQuestionIndex] else { return }
        let helpText = currentQuestion.help
        let customPopUpView = CustomPopUpView(frame: view.bounds, inView: self) // Передаем self как аргумент inView
        view.addSubview(customPopUpView)
        customPopUpView.show(helpText: helpText)
    }
    
    @objc func answerButtonTapped(_ sender: UIButton) {
        
        let currentQuestion = questions[currentQuestionIndex]
        
        if sender.tag == currentQuestion.correctAnswerIndex {
            userScore += 1
            sender.backgroundColor = .green
        } else {
            sender.backgroundColor = .red
            answerButtonsStackView.subviews[currentQuestion.correctAnswerIndex].backgroundColor = .green
        }
        
        // Blocking all answer buttons after choosing an answer
        for arrangedSubview in answerButtonsStackView.arrangedSubviews {
            guard let button = arrangedSubview as? UIButton else { continue }
            button.isEnabled = false
        }
        
        isAnswerButtonTapped = true
        nextQuestionButton.isHidden = false
        updateScoreLabel()
    }
    
    
    // MARK: - Show Final Score
    func showFinalScore() {
        let alert = UIAlertController(title: "Викторина окончена", message: "Твой счет - \(userScore) из \(questions.count).", preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Рестарт", style: .default) { _ in
            self.savePreviousGame()
            self.restartQuiz()
        }
        let mainvcAction = UIAlertAction(title: "Меню", style: .default) { _ in
            self.savePreviousGame()
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(restartAction)
        alert.addAction(mainvcAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Save Previous Game
    func savePreviousGame() {
        guard let category = self.category else { return }
        let previousGameCategory = category.name
        let previousGameQuestionCount = questions.count
        let previousGameCorrectAnswers = userScore
        let completedQuestion = currentQuestionIndex
        
        UserDefaults.standard.set(previousGameCategory, forKey: UserDefaultsKeys.previousGameCategory)
        UserDefaults.standard.set(previousGameQuestionCount, forKey: UserDefaultsKeys.previousGameQuestionCount)
        UserDefaults.standard.set(previousGameCorrectAnswers, forKey: UserDefaultsKeys.previousGameCorrectAnswers)
        UserDefaults.standard.set(completedQuestion, forKey: UserDefaultsKeys.completedQuestion)
        
        delegate?.didCompleteQuiz(with: previousGameCategory, completedQuestion: completedQuestion, questionCount: previousGameQuestionCount, correctAnswers: previousGameCorrectAnswers)
    }
    
    
    // MARK: - Restart Quiz
    func restartQuiz() {
        currentQuestionIndex = 0
        currentQuestion = 1
        userScore = 0
        progressView.progress = 0.0
        updateScoreLabel()
        showQuestion()
        nextQuestionButton.isHidden = true
        
    }
    
    // MARK: - Helper Methods
    func updateScoreLabel() {
        countQuestionLabel.text = "\(currentQuestion) / \(questions.count)"
        scoreLabel.text! = "Счет:" + " " + "\(userScore)"
    }
    
    func setupAnswerButtons() {
        guard let currentQuestion = category?.questions[currentQuestionIndex] else { return }
        
        isAnswerButtonTapped = false
        
        // Restoring the original color of all buttons before displaying a new question
        for arrangedSubview in answerButtonsStackView.arrangedSubviews {
            guard let button = arrangedSubview as? UIButton else { continue }
            button.backgroundColor = .systemBlue
            button.isEnabled = true
        }
        
        
        // Remove previous buttons from the stack view, if any
        for arrangedSubview in answerButtonsStackView.arrangedSubviews {
            answerButtonsStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
        
        for (index, answer) in currentQuestion.answers.enumerated() {
            let button = UIButton()
            button.setTitle(answer, for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.textAlignment = .center
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 16
            button.tag = index
            button.addTarget(self, action: #selector(answerButtonTapped(_:)), for: .touchUpInside)
            answerButtonsStackView.spacing = 10
            answerButtonsStackView.addArrangedSubview(button)
        }
    }
}

