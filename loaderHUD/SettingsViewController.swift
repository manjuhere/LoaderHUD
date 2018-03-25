//
//  SettingsViewController.swift
//  loaderHUD
//
//  Created by Manjunath Chandrashekar on 25/03/18.
//  Copyright © 2018 Manjunath Chandrashekar. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    // MARK: - Font Properties
    @IBOutlet weak var fontPicker: UIPickerView!
    var fonts : [String] =  {
        var fonts = [String]()
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            let names = UIFont.fontNames(forFamilyName: familyName)
            for name in names {
                fonts.append(name)
            }
        }
        return fonts
    }()
    
    // MARK: - Color Properties
    @IBOutlet weak var statusTextButton: UIButton!
    @IBOutlet weak var spinnerButton: UIButton!
    @IBOutlet weak var HUDButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!

    
    // MARK: - Image Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.popVC))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let selectedFont = UserDefaults.standard.value(forKey: "StatusFont") as? String {
                self.fontPicker.selectRow(self.fonts.index(of: selectedFont)!, inComponent: 0, animated: true)
            }
            for type in ColorPickerType.all() {
                if let color = UserDefaults.standard.color(forKey: String(describing: type)) {
                    switch type {
                    case .statusColor:
                        self.statusTextButton.backgroundColor =  color
                    case .spinnerColor:
                        self.spinnerButton.backgroundColor =  color
                    case .hudColor:
                        self.HUDButton.backgroundColor =  color
                    case .backgroundColor:
                        self.backgroundButton.backgroundColor =  color
                    }
                }
            }
        }
    }
    
    @IBAction func showColorPicker(_ sender: UIButton) {
        if let colorPickerVC = self.storyboard?.instantiateViewController(withIdentifier: "ColorPickerViewController") as? ColorPickerViewController {
            switch sender.tag {
            case 1:
                colorPickerVC.colorPickerType = .statusColor
            case 2:
                colorPickerVC.colorPickerType = .spinnerColor
            case 3:
                colorPickerVC.colorPickerType = .hudColor
            case 4:
                colorPickerVC.colorPickerType = .backgroundColor
            default:
                print("Undefined tag")
            }
            colorPickerVC.delegate = self
            self.definesPresentationContext = true
            colorPickerVC.modalPresentationStyle = .overFullScreen
            self.present(colorPickerVC, animated: true)
        }
    }
    
    @objc
    func popVC() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popViewController(animated: false)
    }
    
}

extension UserDefaults {
    func color(forKey key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(_ color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)
    }
}

extension SettingsViewController : ColorPickerDelegate {
    func selectedColor(_ color: UIColor, for type: ColorPickerType) {
        switch type {
        case .statusColor:
            statusTextButton.backgroundColor =  color
        case .spinnerColor:
            spinnerButton.backgroundColor =  color
        case .hudColor:
            HUDButton.backgroundColor =  color
        case .backgroundColor:
            backgroundButton.backgroundColor =  color
        }
        UserDefaults.standard.setColor(color, forKey: String(describing: type))
    }
    
}

extension SettingsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fonts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.darkText
        pickerLabel.text = fonts[row]
        pickerLabel.font = UIFont(name: fonts[row], size: 17)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.set(fonts[row], forKey: "StatusFont")
    }
}
