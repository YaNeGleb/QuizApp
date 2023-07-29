//
//  GameRecord+CoreDataProperties.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 29.07.2023.
//
//

import Foundation
import CoreData


extension GameRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameRecord> {
        return NSFetchRequest<GameRecord>(entityName: "GameRecord")
    }

    @NSManaged public var date: Date?
    @NSManaged public var question: String?
    @NSManaged public var category: String?
    @NSManaged public var correctAnswer: String?
    @NSManaged public var userAnswer: String?

}

extension GameRecord : Identifiable {

}
