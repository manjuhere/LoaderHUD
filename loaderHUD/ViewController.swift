//
//  ViewController.swift
//  loaderHUD
//
//  Created by Manjunath Chandrashekar on 17/03/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var labelHUD: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = labelHUD
        self.navigationItem.titleView?.sizeToFit()
    }
    
    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        if let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromTop
            self.navigationController?.view.layer.add(transition, forKey: nil)
            _ = self.navigationController?.pushViewController(settingsVC, animated: false)
        }
    }
    @IBAction func showLoader(_ sender: UIButton) {
        let fontName = UserDefaults.standard.value(forKey: "StatusFont") as? String
        LoaderHUD.shared.statusFont = UIFont(name: fontName!, size: 17)!

        for type in ColorPickerType.all() {
            if let color = UserDefaults.standard.color(forKey: String(describing: type)) {
                switch type {
                case .statusColor:
                    LoaderHUD.shared.statusColor =  color
                case .spinnerColor:
                    LoaderHUD.shared.spinnerColor =  color
                case .hudColor:
                    LoaderHUD.shared.hudColor =  color
                case .backgroundColor:
                    LoaderHUD.shared.backgroundColor =  color
                }
            }
        }
        
        LoaderHUD.show(message: "Loading...", interaction: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            LoaderHUD.dismiss()
        }
        
    }
    
    
//    static func statusFont(font: UIFont) {}
//    static func statusColor(color: UIColor) {}
//    static func spinnerColor(color: UIColor) {}
//    static func hudColor(color: UIColor) {}
//    static func backgroundColor(color: UIColor) {}
//    static func imageSuccess(image: UIImage) {}
//    static func imageError(image: UIImage) {}

}


