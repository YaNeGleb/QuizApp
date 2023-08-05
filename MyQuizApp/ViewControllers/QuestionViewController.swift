//
//  QuestionViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 16.07.2023.
//

import UIKit
import CoreData

protocol QuizCompletionDelegate: AnyObject {
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
    var currentGame: RecordGame?
    var selectedAnswers: [Int] = []
    weak var quizCompletionDelegate: QuizCompletionDelegate?
    var isAnswerButtonTapped = false
    var selectedAnswerIndex: Int? = nil
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        createNewGame()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Если пользователь не ответил на ни один вопрос и не нажал на кнопку рестарта, удаляем текущую игру
        if selectedAnswers.isEmpty && !nextQuestionButton.isHidden {
            guard let currentGame = self.currentGame else { return }
            CoreDataManager.shared.persistentContainer.viewContext.delete(currentGame)
            CoreDataManager.shared.saveContext()
        }
        updateStatisticsForCurrentDate(completedQuestions: currentQuestionIndex)
    }

    
    // MARK: - Core Data
    func saveGameRecord() {
        guard let currentGame = self.currentGame else {
            return
        }
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let totalQuestions = questions.count
        let completedQuestions = selectedAnswers.count
        
        currentGame.countCorrectAnswer = Int16(userScore)
        currentGame.completedQuestions = Int16(completedQuestions)
        currentGame.countQuestions = Int16(totalQuestions)
        
        CoreDataManager.shared.saveContext()

    }
    
    // MARK: - Create New Game
    func createNewGame() {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        // Создаем новую игру и устанавливаем значения
        let gameRecord = RecordGame(context: context)
        gameRecord.category = category?.name
        gameRecord.countQuestions = Int16(questions.count)
        gameRecord.date = Date()

        // Сохраняем новую игру и изменения в базе данных
        CoreDataManager.shared.saveContext()

        // Сохраняем текущую игру в свойство контроллера
        currentGame = gameRecord
    }
    
    // MARK: - Save Game Question
    func saveGameQuestion() {
        guard let currentGame = self.currentGame, !questions.isEmpty, questions.indices.contains(currentQuestionIndex) else {
            return
        }
        
        let imageUrl = questions[currentQuestionIndex].imageUrl

        let context = CoreDataManager.shared.persistentContainer.viewContext
        let gameQuestion = QuestionGame(context: context)
        gameQuestion.question = questions[currentQuestionIndex].question
        gameQuestion.correctAnswer = questions[currentQuestionIndex].answers[questions[currentQuestionIndex].correctAnswerIndex]
        gameQuestion.userAnswer = selectedAnswerIndex.map { questions[currentQuestionIndex].answers[$0] } ?? "No Answer"
        gameQuestion.game = currentGame
        gameQuestion.image = imageUrl
        
        CoreDataManager.shared.saveContext()
    }
    
    func updateStatisticsForCurrentDate(completedQuestions: Int) {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let currentDate = Date()
        let fetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", currentDate as NSDate)

        do {
            let results = try context.fetch(fetchRequest)
            if let existingDay = results.first {
                // Если найден объект "Day" для текущей даты
                if let existingStatistics = existingDay.statisticToOne {
                    // Обновляем существующую статистику
                    existingStatistics.completedQuestions += Int16(completedQuestions)
                    try context.save()
                } else {
                    // Если статистика для текущей даты не найдена, создаем новый "Statistics" объект
                    let newStatistics = Statistics(context: context)
                    newStatistics.completedQuestions = Int16(completedQuestions)

                    // Устанавливаем связь между объектами "Day" и "Statistics"
                    existingDay.statisticToOne = newStatistics

                    try context.save()
                }
            } else {
                // Если объект "Day" для текущей даты не найден, создаем новый
                let newDay = Day(context: context)
                newDay.date = currentDate

                // Создаем новый "Statistics" объект и устанавливаем его значения
                let newStatistics = Statistics(context: context)
                newStatistics.completedQuestions = Int16(completedQuestions)

                // Устанавливаем связь между объектами "Day" и "Statistics"
                newDay.statisticToOne = newStatistics

                try context.save()
            }
        } catch {
            print("Ошибка при получении или обновлении объектов Day: \(error)")
        }
    }

      // Метод для сохранения ответа на текущий вопрос
      func saveGameQuestion(selectedAnswerIndex: Int) {
          guard let currentGame = self.currentGame, !questions.isEmpty, questions.indices.contains(currentQuestionIndex) else {
              return
          }
          let imageUrl = questions[currentQuestionIndex].imageUrl

          let context = CoreDataManager.shared.persistentContainer.viewContext
          let gameQuestion = QuestionGame(context: context)
          gameQuestion.question = questions[currentQuestionIndex].question
          gameQuestion.correctAnswer = questions[currentQuestionIndex].answers[questions[currentQuestionIndex].correctAnswerIndex]
          gameQuestion.userAnswer = questions[currentQuestionIndex].answers[selectedAnswerIndex]
          gameQuestion.game = currentGame
          gameQuestion.image = imageUrl

          CoreDataManager.shared.saveContext()
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
            questionLabel.frame = CGRect(x: 0, y: imageView.frame.maxY + 16, width: customView.bounds.width, height: customView.bounds.height * 0.2)
            
            // Load image from URL
            imageView.loadImage(fromURL: imageURL)
        } else {
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
            
            if !isAnswerButtonTapped, let selectedAnswerIndex = selectedAnswerIndex {
                selectedAnswers.append(selectedAnswerIndex)
            }
            
            
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
        
        selectedAnswerIndex = sender.tag
        
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
        saveGameQuestion()
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
        
        present(alert, animated: true)
    }
    
    
    // MARK: - Save Previous Game
    func savePreviousGame() {
        guard let category = self.category else { return }
        let previousGameCategory = category.name
        let previousGameQuestionCount = questions.count
        let previousGameCorrectAnswers = userScore
        let completedQuestion = currentQuestionIndex
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(previousGameCategory, forKey: UserDefaultsKeys.previousGameCategory)
        userDefaults.set(previousGameQuestionCount, forKey: UserDefaultsKeys.previousGameQuestionCount)
        userDefaults.set(previousGameCorrectAnswers, forKey: UserDefaultsKeys.previousGameCorrectAnswers)
        userDefaults.set(completedQuestion, forKey: UserDefaultsKeys.completedQuestion)

        saveGameRecord()
        
        quizCompletionDelegate?.didCompleteQuiz(with: previousGameCategory, completedQuestion: completedQuestion, questionCount: previousGameQuestionCount, correctAnswers: previousGameCorrectAnswers)
    }
    
    // MARK: - Restart Quiz
    func restartQuiz() {
        currentQuestionIndex = 0
        currentQuestion = 1
        userScore = 0
        selectedAnswers = []
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

