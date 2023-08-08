//
//  StatisticsViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 03.08.2023.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController {
    // MARK: - Properties
    var totalQuestions = 0
    var averageQuestions = 0
    var favoriteCategory = ""
    var countCorrectAsnwers = 0
    
    private var chartView = UIView()
    private var generalStatisticLabel = UILabel()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStatisticsForLastSevenDays()
    }
    
    
    // MARK: - Load Statistics
    func loadStatisticsForLastSevenDays() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        // Calculate start and end dates for the last seven days
        let calendar = Calendar.current
        let endDate = Date().endOfDay
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) else { return }
        
        var data: [Int] = Array(repeating: 0, count: 7)
        var dates: [String] = []
        var countCorrectAnswers: [Int] = Array(repeating: 0, count: 7)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        
        // Fetch statistics data for each day and populate the data and dates arrays
        for i in 0..<7 {
            guard let currentDate = calendar.date(byAdding: .day, value: i, to: startDate) else { continue }
            let dateString = dateFormatter.string(from: currentDate)
            dates.append(dateString)
            
            data[i] = fetchCompletedQuestionsCount(for: currentDate, in: context)
            countCorrectAnswers[i] = fetchCountCorectAnswers(for: currentDate, in: context)
            
        }
        countCorrectAsnwers = countCorrectAnswers.reduce(0, +)
        totalQuestions = data.reduce(0, +)
        favoriteCategory = getFavoriteCategory() ?? "Нет данных"
        averageQuestions = totalQuestions / data.count
        
        drawBarChart(data: data, dates: dates)
    }
    
    // MARK: - Data Fetching
    private func fetchCompletedQuestionsCount(for date: Date, in context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", date.startOfDay as NSDate, date.endOfDay as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            let sumCompletedQuestions = results.reduce(0) { $0 + Int($1.statisticToOne?.completedQuestions ?? 0) }
            return sumCompletedQuestions
        } catch {
            print("Ошибка при получении данных: \(error)")
            return 0
        }
    }
    
    private func fetchCountCorectAnswers(for date: Date, in context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", date.startOfDay as NSDate, date.endOfDay as NSDate)
        
        do {
            let results = try context.fetch(fetchRequest)
            let sumCorrectAnswers = results.reduce(0) { $0 + Int($1.statisticToOne?.correctAnswers ?? 0) }
            return sumCorrectAnswers
        } catch {
            print("Ошибка при получении данных: \(error)")
            return 0
        }
    }
    
    func getFavoriteCategory() -> String? {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let lastDay = results.first {
                if let statistics = lastDay.statisticToOne, let favoriteCategory = statistics.favoriteCategory {
                    return favoriteCategory
                }
            }
        } catch {
            print("Ошибка при получении объектов Day: \(error)")
        }
        
        return nil
    }
    
    
    // MARK: - Chart Drawing
    private func drawBarChart(data: [Int], dates: [String]) {
        setupView()
        setupChartView(data: data, dates: dates)
        setupGeneralStatisticLabel()
        setupCollectionView()
        setupTrashButton()
    }
    
    private func setupChartView(data: [Int], dates: [String]) {
        chartView = UIView(frame: CGRect(x: 40, y: 155, width: view.bounds.width - 80, height: 250))
        chartView.backgroundColor = .white
        chartView.layer.cornerRadius = 15
        view.addSubview(chartView)
        
        guard !data.isEmpty, let maxValue = data.max() else {
            return
        }
        
        let barWidth = (chartView.bounds.width - CGFloat(data.count + 1) * 10) / CGFloat(data.count)
        
        for (index, value) in data.enumerated() {
            let barHeight = max(20, (CGFloat(value) / CGFloat(maxValue)) * (chartView.bounds.height - 10))
            
            let barView = UIView(frame: CGRect(x: CGFloat(index + 1) * 10 + CGFloat(index) * barWidth, y: chartView.bounds.height, width: barWidth, height: 0))
            setBarColor(for: barView, value: value)
            barView.layer.cornerRadius = 8
            chartView.addSubview(barView)
            
            let label = UILabel(frame: CGRect(x: barView.frame.origin.x, y: barView.frame.origin.y - 20, width: barWidth, height: 20))
            label.text = "\(value)"
            label.textAlignment = .center
            label.textColor = .white
            label.alpha = 0
            chartView.addSubview(label)
            
            let dateLabel = UILabel(frame: CGRect(x: barView.frame.origin.x, y: chartView.bounds.height + 5, width: barWidth, height: 20))
            dateLabel.text = dates[index]
            dateLabel.textAlignment = .center
            dateLabel.textColor = .black
            dateLabel.font = UIFont.systemFont(ofSize: 12)
            dateLabel.alpha = 0
            chartView.addSubview(dateLabel)
            
            UIView.animate(withDuration: 1.0, delay: Double(index) * 0.2, options: .curveEaseInOut, animations: {
                barView.frame.origin.y = self.chartView.bounds.height - barHeight
                barView.frame.size.height = barHeight
                label.alpha = 1
                dateLabel.alpha = 1
            }, completion: nil)
        }
    }
    
    private func setBarColor(for barView: UIView, value: Int) {
        switch value {
        case 0..<5:
            barView.backgroundColor = .systemRed
        case 5..<10:
            barView.backgroundColor = .systemOrange
        case 10..<20:
            barView.backgroundColor = .systemYellow
        case 20...:
            barView.backgroundColor = .systemGreen
        default:
            barView.backgroundColor = .systemBlue
        }
    }
    
    
    // MARK: - View Setup
    private func setupView() {
        title = "Статистика"
        view.backgroundColor = .systemGroupedBackground
        
        let chartDescriptionLabel = UILabel(frame: CGRect(x: 40, y: 100, width: view.bounds.width - 80, height: 45))
        chartDescriptionLabel.numberOfLines = 0
        chartDescriptionLabel.text = "Статистика пройденных вопросов за последние 7 дней"
        chartDescriptionLabel.textAlignment = .center
        chartDescriptionLabel.textColor = .black
        chartDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(chartDescriptionLabel)
    }
    
    private func setupGeneralStatisticLabel() {
        generalStatisticLabel = UILabel(frame: CGRect(x: 40, y: chartView.frame.maxY + 30, width: view.bounds.width - 80, height: 45))
        generalStatisticLabel.numberOfLines = 0
        generalStatisticLabel.text = "Общая статистика за 7 дней"
        generalStatisticLabel.textAlignment = .center
        generalStatisticLabel.textColor = UIColor.black
        generalStatisticLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(generalStatisticLabel)
    }
    
    private func setupCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect(x: 40, y: generalStatisticLabel.frame.maxY + 10, width: view.bounds.width - 80, height: 250), collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.systemGroupedBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        let statisticCellNib = UINib(nibName: "StatisticCell", bundle: nil)
        collectionView.register(statisticCellNib, forCellWithReuseIdentifier: "StatisticCell")
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
    }
    
    private func setupTrashButton() {
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteData(_:)))
        navigationItem.rightBarButtonItem = trashButton
    }
    
    // MARK: - Button Actions
    @objc private func deleteData(_ sender: UIBarButtonItem) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Day.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            
            loadStatisticsForLastSevenDays()
        } catch {
            print("Error deleting data: \(error)")
        }
    }
    
    
    
}


extension StatisticsViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatisticCell", for: indexPath) as! StatisticCell
        switch indexPath.row {
        case 0:
            cell.configure(title: "Пройдено вопросов за неделю:", value: "\(totalQuestions)")
        case 1:
            cell.configure(title: "Среднее количество вопросов в день:", value: "\(averageQuestions)")
            
        case 2:
            cell.configure(title: "Любимая категория:", value: "\(favoriteCategory)")
            
        case 3:
            cell.configure(title: "Правильных вопросов за неделю:", value: "\(countCorrectAsnwers)")
            
        default:
            break
        }
        return cell
    }
    
    
}
    // MARK: - Extenstions
extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.width
        let cellWidth = (collectionViewWidth - 10) / 2
        let cellHeight: CGFloat = 120
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
