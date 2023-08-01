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
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var games: [RecordGame] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "GameHistoryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GameHistoryCell")
        fetchGameHistory()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteAllGameRecords()
    }
    
    private func deleteAllGameRecords() {
            let context = CoreDataManager.shared.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RecordGame.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                
                games.removeAll()
                tableView.reloadData()
                
                print("Все данные успешно удалены из Core Data.")
            } catch {
                print("Ошибка при удалении данных из Core Data: \(error)")
            }
        }
    
    
    func fetchGameHistory() {
        let fetchRequest: NSFetchRequest<RecordGame> = RecordGame.fetchRequest()
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

    func showGameDetails(for game: RecordGame) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let gameDetailsVC = storyboard.instantiateViewController(withIdentifier: "GameDetailsViewController") as? GameDetailsViewController {
            gameDetailsVC.selectedGame = game
            navigationController?.pushViewController(gameDetailsVC, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
}

extension GameHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGame = games[indexPath.row]
        showGameDetails(for: selectedGame)
    }
}

extension GameHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameHistoryCell", for: indexPath) as! GameHistoryCell

        let game = games[indexPath.row]

        cell.configure(with: game)

        return cell
    }
}
