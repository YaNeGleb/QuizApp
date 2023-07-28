//
//  Model.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 28.07.2023.
//

import Foundation

struct QuizData: Codable {
    let categories: [CategoryData]
}

struct CategoryData: Codable {
    let name: String
    let questions: [Question]

}

struct Question: Codable {
    let question: String
    let imageUrl: String
    let answers: [String]
    let correctAnswerIndex: Int
    let help: String

}

struct Category {
    let name: String
    var questions: [Question]
}
