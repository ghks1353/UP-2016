//
//  IndieGamesView.swift
//  UP
//
//  Created by ExFl on 2016. 6. 25..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit;


class IndieGamesView:UIViewController {
	
	//클래스 외부접근을 위함
	static var selfView:IndieGamesView?;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		IndieGamesView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("settingsShowNewgame");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(IndieGamesView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		
	}
	
	func popToRootAction() {
		//Pop to root by back button
		self.navigationController?.popViewControllerAnimated(true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}