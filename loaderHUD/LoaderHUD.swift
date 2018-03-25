//
//  LoaderHUD.swift
//
//  Created by Manjunath Chandrashekar on 04/12/17.
//  Copyright © 2017 Manjunath Chandrashekar. All rights reserved.
//

import Foundation
import UIKit

class LoaderHUD : UIView {
	
	// MARK: - Properties
	var statusFont	: UIFont
	var statusColor	: UIColor
	var spinnerColor: UIColor
	var hudColor	: UIColor
	var imageSuccess: UIImage
	var imageError	: UIImage
	
	// MARK: - Property Methods
	static func statusFont(font: UIFont) 		{ self.shared.statusFont = font 		}
	static func statusColor(color: UIColor) 	{ self.shared.statusColor = color 		}
	static func spinnerColor(color: UIColor) 	{ self.shared.spinnerColor = color 		}
	static func hudColor(color: UIColor) 		{ self.shared.hudColor = color 			}
	static func backgroundColor(color: UIColor) { self.shared.backgroundColor = color 	}
	static func imageSuccess(image: UIImage) 	{ self.shared.imageSuccess = image 		}
	static func imageError(image: UIImage) 		{ self.shared.imageError = image 		}

	private var myWindow	: UIWindow?
	private var imageView	: UIImageView?
	private var toolbarHUD	: UIToolbar?
	private var spinner		: UIActivityIndicatorView?
	private var labelStatus	: UILabel?
	private var viewBackground: UIView?


	// MARK: - Init Methods
	static let shared: LoaderHUD = {
		return LoaderHUD()
	}()
	
	required init?(coder aDecoder: NSCoder) {
		self.statusFont = UIFont.boldSystemFont(ofSize: 16)
		self.statusColor = .black	
		self.spinnerColor = .gray
		self.hudColor = UIColor.init(white: 0.0, alpha: 0.1)
        
        if UIImage.init(named: "loaderHUD-success") == nil {
            assertionFailure("Could not find default image 'loaderHUD-success' in bundle. At least provide custom image.")
        }
        self.imageSuccess = UIImage.init(named: "loaderHUD-success")!

        if UIImage.init(named: "loaderHUD-error") == nil {
            assertionFailure("Could not find default image 'loaderHUD-error' in bundle. At least provide custom image.")
        }
        self.imageError = UIImage.init(named: "loaderHUD-error")!
        
		let delegate : UIApplicationDelegate = UIApplication.shared.delegate!
		if delegate.responds(to: #selector(getter: window)) {
			myWindow = delegate.perform(#selector(getter: window)).takeRetainedValue() as? UIWindow
		} else {
			myWindow = UIApplication.shared.keyWindow
		}
		super.init(coder: aDecoder)
		self.alpha = 0;
		self.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
	}

	init() {
		self.statusFont = UIFont.boldSystemFont(ofSize: 16)
		self.statusColor = .black
		self.spinnerColor = .gray
		self.hudColor = UIColor.init(white: 0.0, alpha: 0.1)
        
        if UIImage.init(named: "loaderHUD-success") == nil {
            assertionFailure("Could not find default/fail-safe image 'loaderHUD-success' in main bundle.")
        }
        self.imageSuccess = UIImage.init(named: "loaderHUD-success")!
        
        if UIImage.init(named: "loaderHUD-error") == nil {
            assertionFailure("Could not find default/fail-safe image 'loaderHUD-error' in main bundle.")
        }
        self.imageError = UIImage.init(named: "loaderHUD-error")!

        let delegate : UIApplicationDelegate = UIApplication.shared.delegate!
		if delegate.responds(to: #selector(getter: window)) {
			myWindow = delegate.perform(#selector(getter: window)).takeRetainedValue() as? UIWindow
		} else {
			myWindow = UIApplication.shared.keyWindow
		}
		super.init(frame: UIScreen.main.bounds)
		self.alpha = 0;
		self.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
	}
	
	
	// MARK: - Display methods
	static func dismiss() {
		DispatchQueue.main.async {
			self.shared.hudHide()
		}
	}
	
	static func show(message : String? = nil, interaction : Bool = false) {
		DispatchQueue.main.async {
			self.shared.hudCreate(status: message, image: nil, spin: true, hide: false, interaction: interaction)
		}
	}

	static func showSuccess(message : String? = nil, interaction : Bool = false) {
		DispatchQueue.main.async {
			self.shared.hudCreate(status: message, image: self.shared.imageSuccess, spin: false, hide: true, interaction: interaction)
		}
	}
	
	static func showError(message : String? = nil, interaction : Bool = false) {
		DispatchQueue.main.async {
			self.shared.hudCreate(status: message, image: self.shared.imageError, spin: false, hide: true, interaction: interaction)
		}
	}
	
	private func hudCreate(status: String?, image: UIImage?, spin: Bool, hide: Bool, interaction: Bool) -> Void {
		if (toolbarHUD == nil) {
		        toolbarHUD = UIToolbar.init(frame: CGRect.zero)
				toolbarHUD?.isTranslucent = true
		        toolbarHUD?.backgroundColor = self.hudColor
		        toolbarHUD?.layer.cornerRadius = 10
		        toolbarHUD?.layer.masksToBounds = true
		        self.registerNotifications()
		}
		if (toolbarHUD?.superview == nil) {
			if (interaction == false) {
				viewBackground = UIView.init(frame: (myWindow?.frame)!)
				viewBackground?.backgroundColor = self.backgroundColor;
				myWindow?.addSubview(viewBackground!)
				viewBackground?.addSubview(toolbarHUD!)
			}
			else {
				myWindow?.addSubview(toolbarHUD!)
			}
		}
		if (spinner == nil) {
			spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
			spinner?.color = self.spinnerColor;
			spinner?.hidesWhenStopped = true;
		}
		if (spinner?.superview == nil) {
			toolbarHUD?.addSubview(spinner!)
		}
		if (imageView == nil) {
			imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 28, height: 28))
		}
		if (imageView?.superview == nil) {
			toolbarHUD?.addSubview(imageView!)
		}
		if (labelStatus == nil)
		{
			labelStatus = UILabel.init(frame: CGRect.zero)
			labelStatus?.font = self.statusFont
			labelStatus?.textColor = self.statusColor
			labelStatus?.backgroundColor = .clear
			labelStatus?.textAlignment = NSTextAlignment.center
			labelStatus?.baselineAdjustment = UIBaselineAdjustment.alignCenters
			labelStatus?.numberOfLines = 0;
		}
		if (labelStatus?.superview == nil) {
			toolbarHUD?.addSubview(labelStatus!)
		}
		labelStatus?.text = status;
		labelStatus?.isHidden = (status == nil) ? true: false;
		imageView?.image = image;
		imageView?.isHidden = (image == nil) ? true : false;
		if (spin) { spinner?.startAnimating() } else { spinner?.stopAnimating() }
		self.hudSize()
		self.hudPosition(notification: nil)
		self.hudShow()
		if (hide) {
			self.timedHide()
		}
	}
	
	private func hudSize() -> Void {
		var rectLabel: CGRect = CGRect.zero
		var widthHUD: CGFloat = 100
		var heightHUD: CGFloat = 100
		if (labelStatus?.text != nil) {
			let attributes: [NSAttributedStringKey: UIFont] = [NSAttributedStringKey.font: (labelStatus?.font)!]
			let options: NSStringDrawingOptions = [.usesFontLeading, .truncatesLastVisibleLine, .usesLineFragmentOrigin]
			rectLabel = NSString(string: (labelStatus?.text!)!)
				.boundingRect(with: CGSize.init(width: 200, height: 300),
							  options: options,
							  attributes: attributes,
							  context: nil)
			widthHUD = rectLabel.size.width + 50;
			heightHUD = rectLabel.size.height + 75;
	
			if (widthHUD < 100) { widthHUD = 100 }
			if (heightHUD < 100) { heightHUD = 100 }
	
			rectLabel.origin.x = (widthHUD - rectLabel.size.width) / 2;
			rectLabel.origin.y = (heightHUD - rectLabel.size.height) / 2 + 25;
		}
		toolbarHUD?.bounds = CGRect.init(x: 0, y: 0, width: widthHUD, height: heightHUD)
		let imageX: CGFloat = widthHUD/2
		let imageY: CGFloat = (labelStatus?.text == nil) ? heightHUD/2 : 36
		let point:CGPoint = CGPoint.init(x: imageX, y: imageY)
		imageView?.center = point
		spinner!.center = point
		labelStatus?.frame = rectLabel;
	}
	
    private func registerNotifications() -> Void {
        NotificationCenter.default.addObserver(self, selector: #selector(hudPosition(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hudPosition(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hudPosition(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hudPosition(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hudPosition(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

	@objc private func hudPosition(notification: NSNotification?) -> Void {
		var heightKeyboard: CGFloat = 0.0;
		if (notification != nil)
		{
			let info:[AnyHashable: Any] = notification!.userInfo!
			let keyboard:CGRect = CGRectFromString(String(describing: info[UIKeyboardFrameEndUserInfoKey]))
			if ((notification?.name == NSNotification.Name.UIKeyboardWillShow) || (notification?.name == NSNotification.Name.UIKeyboardDidShow)){
				heightKeyboard = keyboard.size.height;
			}
		}
		else  {
			heightKeyboard = self.keyboardHeight()
		}
		let screen:CGRect = UIScreen.main.bounds;
		let center:CGPoint = CGPoint.init(x: screen.size.width/2, y: (screen.size.height-heightKeyboard)/2)
        self.toolbarHUD?.center = CGPoint.init(x: center.x, y: center.y);
		if (viewBackground != nil) {
			viewBackground?.frame = (myWindow?.frame)!;
		}
	}
	
    private func keyboardHeight() -> CGFloat {
        for testWindow in UIApplication.shared.windows {
            if (testWindow.isKind(of: UIWindow.self)){
                for possibleKeyboard in testWindow.subviews {
                    if (possibleKeyboard.description.hasPrefix("<UIPeripheralHostView")) {
                        return possibleKeyboard.bounds.size.height
                    }
                    else if (possibleKeyboard.description.hasPrefix("<UIInputSetContainerView")) {
                        for hostKeyboard in possibleKeyboard.subviews {
                            if (hostKeyboard.description.hasPrefix("<UIInputSetHost")) {
                                return hostKeyboard.frame.size.height
                            }
                        }
                    }
                }
            }
        }
        return 0
    }

    private func hudShow() -> Void {
        if (self.alpha == 0) {
            self.toolbarHUD?.alpha = 0
            self.toolbarHUD?.transform = CGAffineTransform.init(scaleX: 1.4, y: 1.4)
            
            UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                self.toolbarHUD?.alpha = 1
                self.alpha = 1
                self.toolbarHUD?.transform = CGAffineTransform.init(scaleX: 1/1.4, y: 1/1.4)
            }, completion: nil)
        }
    }

	private func timedHide() -> Void {
		var strCount = 0
		if let str = labelStatus?.text {
			strCount = str.count
		} else {
			strCount = 8
		}
		let strLen: Int = strCount
		let delay: TimeInterval = Double(strLen) * 0.04 + 0.5
		DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
			self.hudHide()
		}
	}
	
	private func hudHide() -> Void{
		if (self.alpha == 1.0) {
			UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn], animations: {
				self.toolbarHUD?.transform = CGAffineTransform.init(scaleX: 0.7, y: 0.7)
				self.toolbarHUD?.alpha = 0
			}, completion: { (success) in
				self.hudDestroy()
				self.alpha = 0
			})
		}
	}

	private func hudDestroy() -> Void {
		NotificationCenter.default.removeObserver(self)
		labelStatus?.removeFromSuperview(); labelStatus = nil;
		imageView?.removeFromSuperview(); imageView = nil;
		spinner?.removeFromSuperview(); spinner = nil;
		toolbarHUD?.removeFromSuperview(); toolbarHUD = nil;
		viewBackground?.removeFromSuperview(); viewBackground = nil;
	}

}
