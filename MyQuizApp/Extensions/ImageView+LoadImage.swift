//
//  LoadImageView.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 20.07.2023.
//

import UIKit

extension UIImageView {
    func loadImage(fromURL url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self, let data = data, error == nil else {
                print("Ошибка загрузки изображения: \(error?.localizedDescription ?? "")")
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}
