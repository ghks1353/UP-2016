//
//  ExperimentsAlarmsSetupView.swift
//  UP
//
//  Created by ExFl on 2016. 5. 2..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;

class ExperimentsAlarmsSetupView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	static var selfView:ExperimentsAlarmsSetupView?;
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var settingsArray:Array<SettingsElement> = [];
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		ExperimentsAlarmsSetupView.selfView = self;
		self.view.backgroundColor = .clearColor();
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = "비인가 설정 기능";
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(ExperimentsAlarmsSetupView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true;
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		print("Adding repeat table cells");
		
		tablesArray = [
			[ /* sec 1 */
				createSettingsToggle( "알람 메모 사용", defaultState: false, settingsID: "useAlarmMemo")
			] ];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	func popToRootAction() {
		//Pop to root by back button
		self.navigationController?.popViewControllerAnimated(true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		//get data from local
		DataManager.initDefaults();
		let tmpOption:Bool = DataManager.nsDefaults.boolForKey(DataManager.EXPERIMENTS_USE_MEMO_KEY);
		if (tmpOption == true) { /* badge option is true? */
			setSwitchData("useAlarmMemo", value: true);
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		////
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//let cellObj:CustomTableCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableCell;
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
		case 0:
			return "알람 기능";
		default:
			return "";
		}
	}
	func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "이 목록에 있는 기능들은 소리없이 추가되거나 삭제될 수 있습니다.";
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 45;
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 38;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 52;
	}
	
	func createCell( name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		
		tCell.cellID = menuID;
		
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRectMake(12, 6, 31.3, 31.3);
		tIconFileStr = "comp-icons-settings-experiments";
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
		tLabel.frame = CGRectMake(tIconWPadding, 0, tableView.frame.width, 45);
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 45);
		tCell.backgroundColor = UIColor.whiteColor();
		
		tCell.addSubview(tLabel);
		tLabel.text = name; tLabel.font = UIFont.systemFontOfSize(16);
		
		return tCell;
	}
	
	func setSwitchData(settingsID:String, value:Bool) {
		for i:Int in 0 ..< settingsArray.count {
			if (settingsArray[i].settingsID == settingsID) {
				(settingsArray[i].settingsElement as! UISwitch).on = true;
				print("Saved data is on:", settingsArray[i].settingsID);
				break;
			}
		} //end for
		
		//saveChasngesToSystem();
	}
	
	func saveChasngesToSystem() {
		for i:Int in 0 ..< settingsArray.count {
			switch(settingsArray[i].settingsID) {
				case "useAlarmMemo":
					DataManager.nsDefaults.setBool((settingsArray[i].settingsElement as! UISwitch).on, forKey: DataManager.EXPERIMENTS_USE_MEMO_KEY);
					break;
				default:
					break;
			}
		}
		
		DataManager.nsDefaults.synchronize();
	}
	
	func switchChangedEvent( target:UISwitch ) {
		print("switch changed. saving.");
		saveChasngesToSystem();
	}
	
	//Tableview cell view create
	func createSettingsToggle(name:String, defaultState:Bool, settingsID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel(); let tSwitch:UISwitch = UISwitch();
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRectMake(12, 6, 31.3, 31.3);
		tIconFileStr = "comp-icons-settings-experiments";
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
		let settingsObj:SettingsElement = SettingsElement();
		settingsObj.settingsID = settingsID; tCell.cellID = settingsID;
		settingsObj.settingsElement = tSwitch; //Anyobject
		
		tLabel.frame = CGRectMake(tIconWPadding, 0, tableView.frame.width * 0.6, 45);
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 45 /*CGFloat(45 * maxDeviceGeneral.scrRatio)*/ );
		tCell.backgroundColor = UIColor.whiteColor();
		
		tSwitch.frame.origin.x = tableView.frame.width - tSwitch.frame.width - 8;
		tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
		
		tCell.addSubview(tLabel); tCell.addSubview(tSwitch);
		
		tSwitch.addTarget(self, action: #selector(ExperimentsAlarmsSetupView.switchChangedEvent(_:)), forControlEvents: .ValueChanged);
		
		tLabel.text = name;
		tLabel.font = UIFont.systemFontOfSize(16);
		
		//push to settingselement
		settingsArray += [settingsObj];
		
		return tCell;
	}
	
}