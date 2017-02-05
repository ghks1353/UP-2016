//
//  ModalWebView.swift
//  UP
//
//  Created by ExFl on 2016. 11. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ModalWebView:UIViewController {
	
	//for access
	static var selfView:ModalWebView?
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController()
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController()
	
	//WebView
	var wbView:WKWebView = WKWebView()
	var wbProgress:UIProgressView = UIProgressView( progressViewStyle: .bar )
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.clear
		
		ModalWebView.selfView = self
		
		//ModalView
		modalView.view.backgroundColor = UIColor.white;
		modalView.view.frame = DeviceManager.defaultModalSizeRect;
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#333333");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = "Loading";
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), for: UIControlState());
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(ModalWebView.viewCloseAction), for: .touchUpInside);
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		
		///////// Nav items fin
		
		//Add Ctrl vw
		self.view.addSubview(navigationCtrl.view)
		
		//SET MASK for dot eff
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"));
		modalMaskImageView.frame = CGRect(x: 0, y: 0, width: navigationCtrl.view.frame.width, height: navigationCtrl.view.frame.height);
		modalMaskImageView.contentMode = .scaleAspectFit; navigationCtrl.view.mask = modalMaskImageView;
		
		//Add webView
		wbView.frame = CGRect(x: 0, y: 0,
		                      width: modalView.view.frame.width,
		                      height: modalView.view.frame.height)
		modalView.view.addSubview(wbView)
		
		//add progressbar for show loading states
		wbProgress.center = CGPoint(
			x: modalView.view.frame.width / 2,
			y: modalView.view.frame.height / 2 + navigationCtrl.navigationBar.frame.size.height / 2
		)
		modalView.view.addSubview(wbProgress)
		
		wbView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
		wbView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
		
		FitModalLocationToCenter()
		
		//clear cache
		clearWebCache()
		
		///////////////////////////
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false
	}
	
	////////////////
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect;
		
		if (self.view.mask != nil) {
			navigationCtrl.view.mask!.frame = CGRect(x: 0, y: 0, width: navigationCtrl.view.frame.width, height: navigationCtrl.view.frame.height);
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning();
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		
		(self.presentingViewController as! ViewController).showHideBlurview(false)
		self.dismiss(animated: true, completion: {
			//맨 처음 오버레이 가이드를 안 보았으면 닫을 때 메인 뷰에
			//오버레이 가이드 강제적으로 띄우게 호출
			
			if (DataManager.getSavedDataBool( DataManager.settingsKeys.overlayGuideMainFlag ) == false) {
				//presentingViewController가 없기 때문에 그렇게 호출하면 안됨!!
				ViewController.selfView!.showGuideView( nil )
			}
		})
	} //end func
	
	override func viewWillAppear(_ animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
		                         width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
			self.view.frame = CGRect(x: 0, y: 0,
			                         width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	//EventListener for Progressbar
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if (keyPath == nil) {
			return;
		}
		
		switch(keyPath!) {
			//Title change event
			case "title":
				modalView.title = wbView.title;
				break;
			//Progressbar event
			case "estimatedProgress":
				wbProgress.progress = Float(wbView.estimatedProgress);
				
				//Progressbar hide/show animate
				if (wbView.estimatedProgress == 1) {
					wbProgress.isHidden = false;
					UIView.animate(withDuration: 0.68, delay: 0, options: .curveEaseOut, animations: {
						self.wbProgress.alpha = 0;
					}) { _ in
						self.wbProgress.isHidden = true;
					} //end animate
				} else {
					if (wbProgress.isHidden) {
						wbProgress.isHidden = false;
						self.wbProgress.alpha = 0;
						UIView.animate(withDuration: 0.48, delay: 0, options: .curveEaseOut, animations: {
							self.wbProgress.alpha = 1;
						}) { _ in
						}
					}
				}
				break;
			default:
				
				break;
		} //end switch
	} //end observe ovv
	
	func openURL(_ urlStr:String) {
		//Open URL. (https만 열림)
		let url:String = urlStr;
		wbView.load(URLRequest( url: URL( string:
			url.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed )!
			)!));
	}
	
	func clearWebCache() {
		if #available(iOS 9.0, *) {
			let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
			let date = NSDate(timeIntervalSince1970: 0)
			WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
		} else {
			var libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, false).first!
			libraryPath += "/Cookies"
			
			do {
				try FileManager.default.removeItem(atPath: libraryPath)
			} catch {
				print("error")
			}
			URLCache.shared.removeAllCachedResponses()
		}
	}
	
}
