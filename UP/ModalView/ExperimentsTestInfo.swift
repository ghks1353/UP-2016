//
//  ExperimentsTestInfo.swift
//  UP
//
//  Created by ExFl on 2016. 8. 2..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;
import AdSupport;

class ExperimentsTestInfo:UIViewController {
	
	//클래스 외부접근을 위함
	static var selfView:ExperimentsTestInfo?;
	
	var infoScrollView:UIScrollView = UIScrollView();
	
	var infoLabel:UILabel = UILabel();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		ExperimentsTestInfo.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = "Testing info";
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(ExperimentsTestInfo.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		infoScrollView.frame = CGRectMake(0, 0, DeviceManager.defaultModalSizeRect.width, DeviceManager.defaultModalSizeRect.height);
		
		infoLabel.frame = CGRectMake(12, 8, infoScrollView.frame.width - 24, 0);
		infoLabel.numberOfLines = 0; infoLabel.lineBreakMode = .ByWordWrapping;
		infoLabel.textColor = UPUtils.colorWithHexString("#000000"); infoLabel.textAlignment = .Left;
		infoLabel.font = UIFont.systemFontOfSize(10);
		infoLabel.text = "";
		
		infoScrollView.addSubview(infoLabel);
		
		//컨텐츠 크기 설정
		infoScrollView.contentSize = CGSizeMake(DeviceManager.defaultModalSizeRect.width, max(DeviceManager.defaultModalSizeRect.height - (self.navigationController?.navigationBar.frame.size.height)!, infoLabel.frame.maxY + 20));
		
		self.view.addSubview(infoScrollView);
		
		//info fill
		var informationStr:String = "";
		informationStr = "Ads information\n";
		informationStr += "ADID: " + ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString + "\n";
		
		
		infoLabel.text = informationStr;
		infoLabel.sizeToFit();
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
