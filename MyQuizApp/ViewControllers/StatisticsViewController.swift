//
//  StatisticsViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 03.08.2023.
//

import UIKit
import CoreData

class StatisticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStatisticsForLastSevenDays()
        
    }

    func loadStatisticsForLastSevenDays() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let calendar = Calendar.current
        let endDate = Date().endOfDay
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) else { return }
        
        var data: [Int] = Array(repeating: 0, count: 7)
        var dates: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        
        for i in 0..<7 {
            guard let currentDate = calendar.date(byAdding: .day, value: i, to: startDate) else { continue }
            let dateString = dateFormatter.string(from: currentDate)
            dates.append(dateString)
            
            let fetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", currentDate.startOfDay as NSDate, currentDate.endOfDay as NSDate)
            
            do {
                let results = try context.fetch(fetchRequest)
                let sumCompletedQuestions = results.reduce(0) { $0 + Int($1.statisticToOne?.completedQuestions ?? 0) }
                data[i] = sumCompletedQuestions
            } catch {
                print("Ошибка при получении данных: \(error)")
            }
        }
        
        print("Статистика за последние 7 дней: \(data)")
        
        // Здесь вызывайте метод для отрисовки диаграммы, передавая полученные массивы с данными и датами
        drawBarChart(data: data, dates: dates)
    }
    

    func drawBarChart(data: [Int], dates: [String]) {
        title = "Статистика"
        view.backgroundColor = .systemGroupedBackground
        
        let chartDescriptionLabel = UILabel(frame: CGRect(x: 40, y: 100, width: view.bounds.width - 80, height: 45))
        chartDescriptionLabel.numberOfLines = 0
        chartDescriptionLabel.text = "Статистика пройденных вопросов за последние 7 дней"
        chartDescriptionLabel.textAlignment = .center
        chartDescriptionLabel.textColor = .black
        chartDescriptionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        view.addSubview(chartDescriptionLabel)

        let chartView = UIView(frame: CGRect(x: 40, y: chartDescriptionLabel.frame.maxY + 10, width: view.bounds.width - 80, height: 250))
        chartView.backgroundColor = .white
        chartView.layer.cornerRadius = 15
        view.addSubview(chartView)

        let barWidth = (chartView.bounds.width - CGFloat(data.count + 1) * 10) / CGFloat(data.count)

        guard !data.isEmpty, let maxValue = data.max() else {
            return
        }

        for (index, value) in data.enumerated() {
            let barHeight = max(20, (CGFloat(value) / CGFloat(maxValue)) * (chartView.bounds.height - 10))

            let barView = UIView(frame: CGRect(x: CGFloat(index + 1) * 10 + CGFloat(index) * barWidth, y: chartView.bounds.height, width: barWidth, height: 0))
            barView.backgroundColor = .blue
            barView.layer.cornerRadius = 8
            chartView.addSubview(barView)

            let label = UILabel(frame: CGRect(x: barView.frame.origin.x, y: barView.frame.origin.y - 20, width: barWidth, height: 20))
            label.text = "\(value)"
            label.textAlignment = .center
            label.textColor = .white
            label.alpha = 0
            chartView.addSubview(label)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM"

            let dateLabel = UILabel(frame: CGRect(x: barView.frame.origin.x, y: chartView.bounds.height + 5, width: barWidth, height: 20))
            dateLabel.text = dates[index]
            dateLabel.textAlignment = .center
            dateLabel.textColor = .black
            dateLabel.font = UIFont.systemFont(ofSize: 12)
            dateLabel.alpha = 0
            chartView.addSubview(dateLabel)

            UIView.animate(withDuration: 1.0, delay: Double(index) * 0.2, options: .curveEaseInOut, animations: {
                barView.frame.origin.y = chartView.bounds.height - barHeight
                barView.frame.size.height = barHeight
                label.alpha = 1
                dateLabel.alpha = 1
            }, completion: nil)
        }

        let totalQuestions = data.reduce(0, +)
        let totalLabel = UILabel(frame: CGRect(x: 0, y: chartView.frame.maxY + 30, width: view.bounds.width, height: 30))
        totalLabel.text = "Пройденных вопросов: \(totalQuestions)"
        totalLabel.textAlignment = .center
        totalLabel.textColor = .black
        totalLabel.font = UIFont.boldSystemFont(ofSize: 17)
        view.addSubview(totalLabel)

        let averageQuestions = totalQuestions / data.count
        let averageLabel = UILabel(frame: CGRect(x: 0, y: totalLabel.frame.maxY + 10, width: view.bounds.width, height: 30))
        averageLabel.text = "Среднее количество вопросов в день: \(averageQuestions)"
        averageLabel.textAlignment = .center
        averageLabel.textColor = .black
        view.addSubview(averageLabel)
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
