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

class ModalWebView:UIModalView {
	//for access
	static var selfView:ModalWebView?
	
	//WebView
	var wbView:WKWebView = WKWebView()
	var wbProgress:UIProgressView = UIProgressView( progressViewStyle: .bar )
	
	override func viewDidLoad() {
		super.viewDidLoad( "Loading", barColor: UPUtils.colorWithHexString("#333333") )
		ModalWebView.selfView = self
		
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
		
		//clear cache
		clearWebCache()
	}
	
	override func viewDisappearedCompleteHandler() {
		if (DataManager.getSavedDataBool( DataManager.settingsKeys.overlayGuideMainFlag ) == false) {
			//presentingViewController가 없기 때문에 그렇게 호출하면 안됨!!
			ViewController.selfView!.showGuideView( nil )
		} //end if
	} //end func
	
	///////////////////////////////
	
	//EventListener for Progressbar
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if (keyPath == nil) {
			return
		}
		
		switch(keyPath!) {
			case "title": //Title change event
				modalView.title = wbView.title
				break
			case "estimatedProgress": //Progressbar event
				wbProgress.progress = Float(wbView.estimatedProgress)
				
				//Progressbar hide/show animate
				if (wbView.estimatedProgress == 1) {
					wbProgress.isHidden = false
					UIView.animate(withDuration: 0.68, delay: 0, options: .curveEaseOut, animations: {
						self.wbProgress.alpha = 0
					}) { _ in
						self.wbProgress.isHidden = true
					} //end animate
				} else {
					if (wbProgress.isHidden) {
						wbProgress.isHidden = false
						self.wbProgress.alpha = 0;
						UIView.animate(withDuration: 0.48, delay: 0, options: .curveEaseOut, animations: {
							self.wbProgress.alpha = 1
						}) { _ in
						}
					}
				} //end if
				break
			default: break
		} //end switch
	} //end observe ovv
	
	func openURL(_ urlStr:String) {
		//Open URL. (https만 열림)
		let url:String = urlStr
		wbView.load(URLRequest( url: URL( string:
			url.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed )!
			)!))
	} //end func
	
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
			} //end try-catch block
			URLCache.shared.removeAllCachedResponses()
		} //end if
	} //end func
	
}
