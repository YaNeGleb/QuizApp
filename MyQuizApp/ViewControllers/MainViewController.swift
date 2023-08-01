//
//  ViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 16.07.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var startGameButton: UIButton!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var statisticsLabel: UILabel!
    @IBOutlet weak var historyButton: UIButton!
    
    
    // MARK: - Properties
    var previousGameCategory: String = "Нет данных"
    var previousGameQuestionCount: Int = 0
    var previousGameCorrectAnswers: Int = 0
    var previousGameCompletedQuestion: Int = 0
    
    var category: Category?
    var categories: [Category] = []
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPreviousGameData()
        setupTapGesture()
        configureUI()
        loadCategoriesFromJSON()
        configure()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Checking if a category is selected
        if let selectedCategory = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedCategory) {
            self.category = categories.first { $0.name == selectedCategory}
            categoryLabel.text = "Текущая категория: \n\(selectedCategory)"
        }
    }
    
    
    // MARK: - Tap Gesture Setup
    @objc func categoryLabelTapped(_ sender: UITapGestureRecognizer) {
        let groupsViewController = storyboard?.instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
        groupsViewController.categories = categories
        groupsViewController.delegate = self
        navigationController?.pushViewController(groupsViewController, animated: true)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryLabelTapped(_:)))
        categoryLabel.addGestureRecognizer(tapGesture)
        categoryLabel.isUserInteractionEnabled = true
    }
    
    
    // MARK: - Previous Game Data
    private func loadPreviousGameData() {
        previousGameCategory = UserDefaults.standard.string(forKey: UserDefaultsKeys.previousGameCategory) ?? "Нет данных"
        previousGameQuestionCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.previousGameQuestionCount)
        previousGameCorrectAnswers = UserDefaults.standard.integer(forKey: UserDefaultsKeys.previousGameCorrectAnswers)
        previousGameCompletedQuestion = UserDefaults.standard.integer(forKey: UserDefaultsKeys.completedQuestion)
    }
    
    
    // MARK: - Load Categories from JSON
    private func loadCategoriesFromJSON() {
        self.categories = DataManager.loadCategoriesFromJSON()
    }
    
    
    // MARK: - UI Configuration
    private func configureUI() {
        startGameButton.layer.cornerRadius = 16
        historyButton.layer.cornerRadius = 16
        
        categoryLabel.layer.masksToBounds = true
        categoryLabel.layer.cornerRadius = 20
        
        statisticsLabel.layer.masksToBounds = true
        statisticsLabel.layer.cornerRadius = 20
    }
    
    
    private func updateCategoryLabel() {
        guard let selectedCategory = category else {
            categoryLabel.text = "Текущая категория: \nНет данных"
            return
        }
        categoryLabel.text = "Текущая категория: \n\(selectedCategory.name)"
    }
    
    
    // MARK: - Configure Statistics Label
    func configure() {
        let attributedText = NSMutableAttributedString()
        
        // Add header
        let headerText = NSAttributedString(string: "Информация о прошлой игре:\n\n", attributes: [
            .font: UIFont.boldSystemFont(ofSize: 20),
        ])
        attributedText.append(headerText)
        
        // Add category
        let categoryText = NSAttributedString(string: "Категория: \(previousGameCategory)\n", attributes: [
            .font: UIFont.systemFont(ofSize: 18),
        ])
        attributedText.append(categoryText)
        
        // Add question information
        let questionText = NSAttributedString(string: "Пройдено вопросов: \(previousGameCompletedQuestion)/\(previousGameQuestionCount)\n", attributes: [
            .font: UIFont.systemFont(ofSize: 18),
        ])
        attributedText.append(questionText)
        
        // Add information about correct answers
        let percentage = Double(previousGameCorrectAnswers) / Double(previousGameCompletedQuestion) * 100
        let formattedPercentage = String(format: "%.1f", percentage)
        let correctAnswersText = NSAttributedString(string: "Правильных ответов: \(previousGameCorrectAnswers) (\(formattedPercentage)%)", attributes: [
            .font: UIFont.systemFont(ofSize: 18),
        ])
        attributedText.append(correctAnswersText)
        
        statisticsLabel.attributedText = attributedText
    }
    
    
    // MARK: - Play Button Tapped
    @IBAction func playButtonTapped(_ sender: Any) {
        guard let selectedCategory = category else {
            let alert = UIAlertController(title: "No Category Selected", message: "Please select a category first.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let questionViewController = storyboard?.instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
        questionViewController.category = selectedCategory
        questionViewController.delegate = self
        navigationController?.pushViewController(questionViewController, animated: true)
    }
}


// MARK: - CategorySelectionDelegate
extension MainViewController: CategorySelectionDelegate {
    func didSelectCategory(category: String) {
        self.category = categories.first { $0.name == category}
        categoryLabel.text = "Текущая категория: \n\(category)"
        
    }
}


// MARK: - QuestionViewControllerDelegate
extension MainViewController: QuestionViewControllerDelegate {
    func didCompleteQuiz(with category: String, completedQuestion: Int, questionCount: Int, correctAnswers: Int) {
        previousGameCategory = category
        previousGameQuestionCount = questionCount
        previousGameCorrectAnswers = correctAnswers
        previousGameCompletedQuestion = completedQuestion
        configure()
    }
}

  



