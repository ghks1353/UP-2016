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

class TestersWebView:UIViewController {
	
	//클래스 외부접근을 위함
	static var selfView:TestersWebView?;
	
	var wbView:WKWebView = WKWebView();
	var wbProgress:UIProgressView = UIProgressView( progressViewStyle: .default );
	
	override func viewDidLoad() {
		super.viewDidLoad();
		TestersWebView.selfView = self;
		
		self.view.backgroundColor = UIColor.clear;
		
		//ModalView
		self.view.backgroundColor = UIColor.white;
		self.title = "BetaTest notice";
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), for: UIControlState());
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(TestersWebView.popToRootAction), for: .touchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		wbView.frame = CGRect(x: 0, y: 0,
			width: DeviceManager.defaultModalSizeRect.width,
			height: DeviceManager.defaultModalSizeRect.height);
		self.view.addSubview(wbView);
		
	}
	
	func popToRootAction() {
		//Pop to root by back button
		_ = self.navigationController?.popViewController(animated: true);
	}
	
	override func viewWillAppear(_ animated: Bool) {
		//load url
		let url:String = "https://up.avngraphic.kr/inapp/testers/";
		wbView.load(URLRequest( url: URL( string:
			url.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed )!
			)!));
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}