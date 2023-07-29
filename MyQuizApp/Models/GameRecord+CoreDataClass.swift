//
//  GameRecord+CoreDataClass.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 29.07.2023.
//
//

import Foundation
import CoreData

@objc(GameRecord)
public class GameRecord: NSManagedObject {
    static func createAndSave(in context: NSManagedObjectContext,
                                date: Date,
                                question: String,
                                category: String,
                                correctAnswer: String,
                                userAnswer: String) {
          let game = GameRecord(context: context)
          game.date = date
          game.question = question
          game.category = category
          game.correctAnswer = correctAnswer
          game.userAnswer = userAnswer
          
          do {
              try context.save()
          } catch {
              print("Ошибка при сохранении: \(error)")
          }
      }
}
