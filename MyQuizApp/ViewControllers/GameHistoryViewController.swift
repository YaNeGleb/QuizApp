//
//  GameHistoryViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 29.07.2023.
//

import UIKit
import CoreData

class GameHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var games: [GameRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "GameHistoryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GameHistoryCell")
        
        fetchGameHistory()
    }
    
    func fetchGameHistory() {
        let fetchRequest: NSFetchRequest<GameRecord> = GameRecord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let context = CoreDataManager.shared.persistentContainer.viewContext
            self.games = try context.fetch(fetchRequest)
            tableView.reloadData()
            print("Игровые данные успешно загружены. Количество записей: \(games.count)")
        } catch {
            print("Ошибка при получении истории игр: \(error)")
        }
    }
}

extension GameHistoryViewController: UITableViewDelegate {}

extension GameHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameHistoryCell", for: indexPath) as! GameHistoryCell

        let game = games[indexPath.row]

        // Настройте вашу кастомную ячейку, используя данные из объекта game
        cell.configure(with: game)

        return cell
    }

}
