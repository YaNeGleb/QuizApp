//
//  DataManager.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 17.07.2023.
//

import Foundation

struct DataManager {
    static func loadCategoriesFromJSON() -> [Category] {
        var categories: [Category] = []
        
        if let url = Bundle.main.url(forResource: "jsonTest1", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let quizData = try JSONDecoder().decode(QuizData.self, from: data)
                let categoriesData = quizData.categories // Получаем массив данных категорий из JSON
                
                for categoryData in categoriesData {
                    let category = Category(name: categoryData.name, questions: categoryData.questions)
                    categories.append(category)
                }
            } catch {
                print("Ошибка парсинга JSON: \(error)")
            }
        }
        return categories
    }
}
