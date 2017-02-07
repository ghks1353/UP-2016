//
//  UIModalView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 7..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class UIModalView:UIViewController {
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController()
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController()
	
	//Mask view
	var maskUIView:UIView = UIView()
	let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"))
	let upLayerGuideMaskView:UIImageView = UIImageView()
	var maskToMainViewController:Bool = true
	
	//LayerGuide show button
	var upLayerGuideShowButton:UIImageView = UIImageView()
	
	func viewDidLoad( _ title:String, barColor:UIColor, maskToView:Bool = false, showOverlayGuideButton:Bool = false ) {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.clear
		
		//ModalView
		modalView.view.backgroundColor = UIColor.white
		modalView.view.frame = DeviceManager.defaultModalSizeRect
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
		navigationCtrl = UINavigationController.init(rootViewController: modalView)
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
		navigationCtrl.navigationBar.barTintColor = barColor
		navigationCtrl.view.frame = modalView.view.frame
		modalView.title = title
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		navLeftPadding.width = -12 //Button left padding
		let navCloseButton:UIButton = UIButton() //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), for: UIControlState())
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45) //Image frame size
		navCloseButton.addTarget(self, action: #selector(self.viewCloseAction), for: .touchUpInside)
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ]
		///////// Nav items fin
		self.view.addSubview(navigationCtrl.view)
		
		//SET MASK for dot eff
		modalMaskImageView.frame = CGRect(x: 0, y: 0, width: navigationCtrl.view.frame.width, height: navigationCtrl.view.frame.height)
		modalMaskImageView.contentMode = .scaleAspectFit
		
		if (maskToView) {
			maskUIView.addSubview(modalMaskImageView)
			self.view.mask = maskUIView
		} else {
			navigationCtrl.view.mask = modalMaskImageView
		}
		maskToMainViewController = maskToView
		
		/////////////////////
		
		////////// 모달 밖에 배치하는 리소스
		upLayerGuideShowButton.image = UIImage( named: "comp-showguide-icon.png" )
		self.view.addSubview(upLayerGuideShowButton)
		
		if (showOverlayGuideButton == false) {
			upLayerGuideShowButton.isHidden = true
		} else {
			upLayerGuideShowButton.alpha = 0
			
			//오버레이 도움말 터치 Handler
			let tGesture = UITapGestureRecognizer(target:self, action: #selector(self.overlayGuideShowHandler(_:)))
			upLayerGuideShowButton.isUserInteractionEnabled = true
			upLayerGuideShowButton.addGestureRecognizer(tGesture)
		}
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false
		FitModalLocationToCenter()
	}
	
	/////// View transition animation
	override func viewWillAppear(_ animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0
		
		//잘 안되면 없앨것.
		FitModalLocationToCenter()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
	}
	override func viewDidAppear(_ animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
		                         width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
			self.view.frame = CGRect(x: 0, y: 0,
			                         width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
			self.view.alpha = 1
		}) { _ in
			if (self.upLayerGuideShowButton.isHidden == false) {
				self.fadeInGuideButton( false )
			}
			self.viewAppearedCompleteHandler()
		} //end block [complete animation]
	} ///////////////////////////////
	//View appear animate block complete handler
	func viewAppearedCompleteHandler() {
		//used with override
	} //end func
	//View disappear block complete hanld/
	func viewDisappearedCompleteHandler() {
		//used with override
	} //end func
	func overlayGuideShowHandler(_ gst:UITapGestureRecognizer ) {
		//used with override
	} //end func
	///////////////////////
	
	//Guide show/hide
	func fadeInGuideButton( _ withDelay:Bool = true ) {
		upLayerGuideShowButton.alpha = 0
		UIView.animate(withDuration: 0.5, delay: withDelay ? 0.56 : 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.upLayerGuideShowButton.alpha = 1
		}, completion: {_ in
		})
	} //end func
	func fadeOutGuideButton( ) {
		upLayerGuideShowButton.alpha = 1
		UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.upLayerGuideShowButton.alpha = 0
		}, completion: {_ in
		})
	} //end func
	
	
	//// Fit frame
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect
		if (maskToMainViewController) {
			maskUIView.frame = DeviceManager.defaultModalSizeRect
		} else {
			modalMaskImageView.frame = CGRect(x: 0, y: 0, width: navigationCtrl.view.frame.width, height: navigationCtrl.view.frame.height)
		} //end if
		
		if (self.upLayerGuideShowButton.isHidden == false) {
			upLayerGuideShowButton.frame = CGRect( x: DeviceManager.scrSize!.width - ((50.5 + 18) * DeviceManager.maxScrRatioC), y: 34 * DeviceManager.maxScrRatioC, width: 50.5 * DeviceManager.maxScrRatioC, height: 50.5 * DeviceManager.maxScrRatioC)
		} //end if
	} //end func
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	func viewCloseAction() {
		upLayerGuideShowButton.alpha = 0
		
		if (self.presentingViewController is ViewController) {
			(self.presentingViewController as! ViewController).showHideBlurview(false)
		}
		self.dismiss(animated: true, completion: {
			self.viewDisappearedCompleteHandler()
		})
	} //end close func

	
} //end class
