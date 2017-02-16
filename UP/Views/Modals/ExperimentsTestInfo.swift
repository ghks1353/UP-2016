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
import FirebaseInstanceID;

class ExperimentsTestInfo:UIViewController {
	
	//클래스 외부접근을 위함
	static var selfView:ExperimentsTestInfo?
	
	var infoScrollView:UIScrollView = UIScrollView()
	
	var infoLabel:UILabel = UILabel()
	var infoCopyButton:UIButton = UIButton()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		ExperimentsTestInfo.selfView = self
		
		self.view.backgroundColor = UIColor.clear
		
		//ModalView
		self.view.backgroundColor = UIColor.white
		self.title = "Debug info"
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), for: UIControlState());
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(self.popToRootAction), for: .touchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		infoScrollView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height);
		
		infoLabel.frame = CGRect(x: 12, y: 8, width: infoScrollView.frame.width - 24, height: 0);
		infoLabel.numberOfLines = 0; infoLabel.lineBreakMode = .byCharWrapping;
		infoLabel.textColor = UPUtils.colorWithHexString("#000000"); infoLabel.textAlignment = .left;
		infoLabel.font = UIFont.systemFont(ofSize: 10);
		infoLabel.text = "";
		
		infoScrollView.addSubview(infoLabel);
		infoScrollView.addSubview(infoCopyButton);
		
		infoCopyButton.setTitle("Copy to clipboard", for: UIControlState());
		infoCopyButton.setTitleColor(UPUtils.colorWithHexString("#2994FF"), for: UIControlState());
		infoCopyButton.setTitleColor(UPUtils.colorWithHexString("#0057AD"), for: .highlighted);
		infoCopyButton.titleLabel!.font = UIFont.systemFont(ofSize: 16);
		infoCopyButton.addTarget(self, action: #selector(ExperimentsTestInfo.copyInformationFunc), for: .touchUpInside);
		
		self.view.addSubview(infoScrollView);
		
		//refreshInformationStatus();
	}
	
	func refreshInformationStatus() {
		ALDManager.buildLevel()
		
		//info fill
		var informationStr:String = ""
		informationStr += "System\n"
		informationStr += "OS: iOS " + String(UIDevice.current.systemVersion) + "\n"
		informationStr += "Device: " + String( UIDevice.current.model ) + "\n"
		
		informationStr += "App Lang: " + String(LanguagesManager.currentLocaleCode) + "\n"
		informationStr += "Sys Lang: " + String(describing: (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!) + "\n"
		
		informationStr += "App version: " + String((Bundle.main.infoDictionary?["CFBundleVersion"])! as! String) + "\n"
		
		//Auto-Level Design
		informationStr += "\nALD Result\n"
		informationStr += "LvMul: " + String( ALDManager.generatedLevelMultiply ) + "\n"
		informationStr += "TimeMul: " + String( ALDManager.generatedTimeMultiply ) + "\n"
		
		informationStr += "\nAlarms\n"
		informationStr += "Current alarm len: " + String(AlarmManager.alarmsArray.count) + "\n"
		informationStr += "Sys max alarm len: " + String(AlarmManager.alarmMaxRegisterCount) + "\n"
		
		let nextfieInSeconds:Int = AlarmManager.getNextAlarmFireInSeconds()
		let nextAlarmLeft:Int = nextfieInSeconds == -1 ? -1 : (nextfieInSeconds - Int(Date().timeIntervalSince1970))
		
		informationStr += "Next alarm in: " + String(nextAlarmLeft) + "s\n"
		informationStr += "Alarms list start::\n"
		
		for i:Int in 0 ..< AlarmManager.alarmsArray.count {
			var repeatinfo:String = ""
			for j:Int in 0 ..< AlarmManager.alarmsArray[i].alarmRepeat.count {
				repeatinfo += AlarmManager.alarmsArray[i].alarmRepeat[j] == false ? "0" : "1"
			}
			informationStr += String(AlarmManager.alarmsArray[i].alarmID) + "(" + AlarmManager.alarmsArray[i].alarmName + "): TIME " + String(describing: AlarmManager.alarmsArray[i].alarmFireDate) + ", REP " + repeatinfo + ", SND " + String(AlarmManager.alarmsArray[i].alarmSoundLevel) + ", ON: " + String(AlarmManager.alarmsArray[i].alarmToggle) + "\n"
		}
		informationStr += "Alarms list end::\n"
		
		informationStr += "\nStatistics\n"
		
		let alarmsDataLen:Int = DataManager.getAlarmGraphData(3, dataPointSelection: 0)!.count
		let gamesDataLen:Int = DataManager.getAlarmGraphData(3, dataPointSelection: 3)!.count
		
		informationStr += "Alarms data len: " + String(alarmsDataLen) + "\n"
		informationStr += "Games data len: " + String(gamesDataLen) + "\n"
		
		informationStr += "\nAdvertisement\n"
		informationStr += "ADID: " + ASIdentifierManager.shared().advertisingIdentifier.uuidString + "\n"
		informationStr += "UnityAds version: " + String(UnityAds.getVersion()) + "\n"
		informationStr += "UnityAds inited: " + String(UnityAds.isInitialized()) + "\n"
		informationStr += "UnityAds testmode: " + String(UnityAds.getDebugMode()) + "\n"
		
		informationStr += "\nFirebase\n"
		
		let fBaseToken:String? = FIRInstanceID.instanceID().token();
		if (fBaseToken == nil) {
			//FIR inst is null
			informationStr += "FIR InstID: null\n"
		} else {
			informationStr += "FIR InstID: " + fBaseToken! + "\n"
		}
		
		infoLabel.text = informationStr
		infoLabel.sizeToFit()
		
		infoCopyButton.frame = CGRect(x: 0, y: infoLabel.frame.maxY, width: DeviceManager.defaultModalSizeRect.width, height: 42 )
		
		//컨텐츠 크기 설정
		infoScrollView.contentSize = CGSize(width: DeviceManager.defaultModalSizeRect.width, height: max(DeviceManager.defaultModalSizeRect.height - (self.navigationController?.navigationBar.frame.size.height)!, infoCopyButton.frame.maxY + 20))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		refreshInformationStatus();
	}
	
	func popToRootAction() {
		//Pop to root by back button
		_ = self.navigationController?.popViewController(animated: true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	////////////////
	
	func copyInformationFunc() {
		UIPasteboard.general.string = infoLabel.text;
		
		let aCtrl = UIAlertController(title: LanguagesManager.$("generalAlert"), message: "Copied!", preferredStyle: UIAlertControllerStyle.alert);
		aCtrl.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
		}));
		present(aCtrl, animated: true, completion: nil);
	}
	
	
	
}
