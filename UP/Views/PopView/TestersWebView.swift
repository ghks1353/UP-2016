//
//  TestersWebView.swift
//  UP
//
//  Created by ExFl on 2016. 9. 11..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;
import WebKit;

class TestersWebView:UIModalPopView {
	
	//클래스 외부접근을 위함
	static var selfView:TestersWebView?
	
	var wbView:WKWebView = WKWebView()
	var wbProgress:UIProgressView = UIProgressView( progressViewStyle: .bar )
	
	override func viewDidLoad() {
		super.viewDidLoad( title: "UP Testers" )
		TestersWebView.selfView = self
		
		wbView.frame = CGRect(x: 0, y: 0,
			width: DeviceManager.defaultModalSizeRect.width,
			height: DeviceManager.defaultModalSizeRect.height)
		self.view.addSubview(wbView)
		
		//add progressbar for show loading states
		wbProgress.center = CGPoint(
			x: DeviceManager.defaultModalSizeRect.width / 2,
			y: DeviceManager.defaultModalSizeRect.height / 2 + self.navigationController!.navigationBar.frame.size.height / 2
		)
		self.view.addSubview(wbProgress)
		
		wbView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
		wbView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
	} ///////// end func
	
	override func viewWillAppear(_ animated: Bool) {
		//load url
		clearWebCache()
		
		let url:String = "https://up.avngraphic.kr/inapp/testers/"
		wbView.load(URLRequest( url: URL( string:
			url.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed )!
			)!))
	} //end func
	
	//EventListener for Progressbar
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if (keyPath == nil) {
			return
		}
		
		switch(keyPath!) {
			//Title change event
			case "title":
				self.title = wbView.title
				break;
			//Progressbar event
			case "estimatedProgress":
				wbProgress.progress = Float(wbView.estimatedProgress)
				
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
	} ////end func
	
}
