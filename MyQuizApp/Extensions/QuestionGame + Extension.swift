//
//  QuestionGame + Extension.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 31.07.2023.
//

extension QuestionGame {
    func saveGameQuestion(question: String, correctAnswer: String, userAnswer: String, game: RecordGame, image: String, completedQuestions: Int, countCorrectAsnwers: Int) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let gameQuestion = QuestionGame(context: context)
        gameQuestion.question = question
        gameQuestion.correctAnswer = correctAnswer
        gameQuestion.userAnswer = userAnswer
        gameQuestion.game = game
        gameQuestion.image = image
        
        CoreDataManager.shared.saveContext()
    }
}
