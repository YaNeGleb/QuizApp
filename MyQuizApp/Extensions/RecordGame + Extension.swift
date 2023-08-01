//
//  RecordGame + Extension.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 31.07.2023.
//

import Foundation

extension RecordGame {
    func saveGameRecord(category: String, countQuestions: Int, correctAnswers: Int, countCorrectAnswer: Int) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let gameRecord = RecordGame(context: context)
        gameRecord.category = category
        gameRecord.countQuestions = Int16(countQuestions)
        gameRecord.countCorrectAnswer = Int16(countCorrectAnswer)
        gameRecord.date = Date()
        gameRecord.completedQuestions = Int16(completedQuestions)
        
        CoreDataManager.shared.saveContext()
    }
}
