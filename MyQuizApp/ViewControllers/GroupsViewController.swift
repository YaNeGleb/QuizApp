//
//  GroupsViewController.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 20.07.2023.
//

import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(category: String)
}


class GroupsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - Properties
    weak var delegate: CategorySelectionDelegate?
    
    var categories: [Category] = []
    
    var selectedIndexPath: IndexPath?
    
    var selectedItemIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: "SelectedItemIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SelectedItemIndex")
        }
    }
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let buttonCellNib = UINib(nibName: "ButtonCell", bundle: nil)
        collectionView.register(buttonCellNib, forCellWithReuseIdentifier: "ButtonCell")
        
        collectionView.reloadData()
        
    }
}


// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension GroupsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = categories[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
        cell.categoryLabel.text = category.name
        cell.countQuestionsLabel.text = "Вопросов: \(category.questions.count)"
        
        
        if indexPath.item == selectedItemIndex {
            cell.isSelectedCell = true
        } else {
            cell.isSelectedCell = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItemIndex = indexPath.item
        collectionView.reloadData()
        
        let selectedCategory = categories[indexPath.item]
        delegate?.didSelectCategory(category: selectedCategory.name)
        
        UserDefaults.standard.set(selectedItemIndex, forKey: "SelectedItemIndex")
        UserDefaults.standard.set(selectedCategory.name, forKey: "SelectedCategory")
    }
    
}
