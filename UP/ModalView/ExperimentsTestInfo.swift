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
import UnityAds;

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
		self.title = "Technical info";
		
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
		
		self.view.addSubview(infoScrollView);
		
		//refreshInformationStatus();
	}
	
	func refreshInformationStatus() {
		
		//info fill
		var informationStr:String = "";
		informationStr += "System\n";
		informationStr += "OS: iOS " + String(UIDevice.currentDevice().systemVersion) + "\n";
		informationStr += "Device: " + String( UIDevice.currentDevice().model ) + "\n";
		
		informationStr += "App Lang: " + String(Languages.currentLocaleCode) + "\n";
		informationStr += "Sys Lang: " + String(NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!) + "\n";
		
		informationStr += "App version: " + String((NSBundle.mainBundle().infoDictionary?["CFBundleVersion"])! as! String) + "\n";
		
		informationStr += "\nAlarms\n";
		informationStr += "Current alarm len: " + String(AlarmManager.alarmsArray.count) + "\n";
		informationStr += "Sys max alarm len: " + String(AlarmManager.alarmMaxRegisterCount) + "\n";
		
		let nextfieInSeconds:Int = AlarmManager.getNextAlarmFireInSeconds();
		let nextAlarmLeft:Int = nextfieInSeconds == -1 ? -1 : (nextfieInSeconds - Int(NSDate().timeIntervalSince1970));
		
		informationStr += "Next alarm in: " + String(nextAlarmLeft) + "s\n";
		informationStr += "Alarms list start::\n";
		
		for i:Int in 0 ..< AlarmManager.alarmsArray.count {
			var repeatinfo:String = "";
			for j:Int in 0 ..< AlarmManager.alarmsArray[i].alarmRepeat.count {
				repeatinfo += AlarmManager.alarmsArray[i].alarmRepeat[j] == false ? "0" : "1";
			}
			informationStr += String(AlarmManager.alarmsArray[i].alarmID) + "(" + AlarmManager.alarmsArray[i].alarmName + "): FIRE " + String(AlarmManager.alarmsArray[i].alarmFireDate) + ", REPEAT " + repeatinfo + ", SOUND " + String(AlarmManager.alarmsArray[i].alarmSoundLevel) + ", STAT: " + String(AlarmManager.alarmsArray[i].alarmToggle) + "\n";
		}
		informationStr += "Alarms list end::\n";
		
		informationStr += "\nStatistics\n";
		
		let alarmsDataLen:Int = DataManager.getAlarmGraphData(3, dataPointSelection: 0)!.count;
		let gamesDataLen:Int = DataManager.getAlarmGraphData(3, dataPointSelection: 3)!.count;
		
		informationStr += "Alarms data len: " + String(alarmsDataLen) + "\n";
		informationStr += "Games data len: " + String(gamesDataLen) + "\n";
		
		informationStr += "\nAdvertisement\n";
		informationStr += "ADID: " + ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString + "\n";
		informationStr += "UnityAds version: " + String(UnityAds.getVersion()) + "\n";
		informationStr += "UnityAds inited: " + String(UnityAds.isInitialized()) + "\n";
		informationStr += "UnityAds testmode: " + String(UnityAds.getDebugMode()) + "\n";
		
		
		infoLabel.text = informationStr;
		infoLabel.sizeToFit();
		
		//컨텐츠 크기 설정
		infoScrollView.contentSize = CGSizeMake(DeviceManager.defaultModalSizeRect.width, max(DeviceManager.defaultModalSizeRect.height - (self.navigationController?.navigationBar.frame.size.height)!, infoLabel.frame.maxY + 20));
		
		
	}
	
	override func viewWillAppear(animated: Bool) {
		refreshInformationStatus();
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
