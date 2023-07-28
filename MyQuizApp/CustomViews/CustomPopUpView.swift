//
//  CustomPopUpView.swift
//  MyQuizApp
//
//  Created by Zabroda Gleb on 21.07.2023.
//

import UIKit

class CustomPopUpView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var backView: UIView!
    
    // MARK: - Properties
    var vc: UIViewController!
    var view: UIView!
    var overlayView: UIView!
    
    private let viewCornerRadius: CGFloat = 15.0
    private let buttonCornerRadius: CGFloat = 8.0
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    init(frame: CGRect, inView: UIViewController) {
        super.init(frame: frame)
        vc = inView
        overlayView = UIView(frame: vc.view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        vc.view.addSubview(self)
        vc.view.addSubview(overlayView)
        xibSetup()
        self.center = vc.view.center

    }
    
    // MARK: - XIB Setup
    func xibSetup() {
        view = loadNibView()
        customView.frame = bounds
        customView.layer.cornerRadius = viewCornerRadius
        doneButton.layer.cornerRadius = buttonCornerRadius
        addSubview(view)
    }
    
    // MARK: - Load XIB View
    func loadNibView() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CustomPopUpView", bundle: bundle)
        let view = nib.instantiate(withOwner: self).first as! UIView
        return view
    }
    
    // MARK: - Show Custom PopUp View
    func show(helpText: String) {
            UIView.animate(withDuration: 0.3) {
                self.overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            }

            // Make the view visible without resizing
            self.alpha = 0.0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                self.alpha = 1.0 // Make the view visible
            }, completion: nil)

            titleLabel.text = helpText
        }
    
    // MARK: - Hide Custom PopUp View
    func hide() {
            // Animation for smooth hiding shading and custom view
            UIView.animate(withDuration: 0.3, animations: {
                self.overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.0) // Убираем затемнение
                self.alpha = 0.0
            }, completion: { _ in
                // At the end of the animation, remove the blackout and custom view
                self.overlayView?.removeFromSuperview()
                self.removeFromSuperview()
            })
        }

    // MARK: - IBAction
    @IBAction func doneButtonTapped(_ sender: Any) {
        hide()
    }
    
    
    
}
