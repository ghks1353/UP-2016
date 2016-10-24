//
//  ExperimentsAlarmsSetupView.swift
//  UP
//
//  Created by ExFl on 2016. 5. 2..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class ExperimentsAlarmsSetupView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	static var selfView:ExperimentsAlarmsSetupView?;
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped);
	var settingsArray:Array<SettingsElement> = [];
	var tablesArray:Array<Array<AnyObject>> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		ExperimentsAlarmsSetupView.selfView = self;
		self.view.backgroundColor = UIColor.clear;
		//ModalView
		self.view.backgroundColor = UIColor.white;
		self.title = Languages.$("settingsExperimentsAlarm");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), for: UIControlState());
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(ExperimentsAlarmsSetupView.popToRootAction), for: .touchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true;
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		print("Adding repeat table cells");
		
		tablesArray = [
			[ /* sec 1 */
				createSettingsToggle( Languages.$("settingsAlarmMemo"), defaultState: false, settingsID: "useAlarmMemo"),
				createSettingsToggle( Languages.$("settingsNoLieDown"), defaultState: false, settingsID: "usNoLieDown")
			] ];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	func popToRootAction() {
		//Pop to root by back button
		_ = self.navigationController?.popViewController(animated: true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		//get data from local
		DataManager.initDefaults();
		var tmpOption:Bool = DataManager.nsDefaults.bool(forKey: DataManager.EXPERIMENTS_USE_MEMO_KEY);
		if (tmpOption == true) { /* badge option is true? */
			setSwitchData("useAlarmMemo", value: true);
		}
		
		//alarm liedown func
		tmpOption = DataManager.nsDefaults.bool(forKey: DataManager.EXPERIMENTS_USE_NOLIEDOWN_KEY);
		if (tmpOption == true) {
			setSwitchData("usNoLieDown", value: true);
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		////
	}
	
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//let cellObj:CustomTableCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableCell;
		
		tableView.deselectRow(at: indexPath, animated: true);
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
		case 0:
			return Languages.$("settingsExperimentsAlarm");
		default:
			return "";
		}
	}
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "";
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] ).count;
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 45;
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] )[(indexPath as NSIndexPath).row] as! UITableViewCell;
		return cell;
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 38;
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 20;
	}
	
	func createCell( _ name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		var tIconFileStr:String = "";
		
		tCell.cellID = menuID;
		switch(menuID) {
			case "useAlarmMemo": tIconFileStr = "comp-icons-settings-memo"; break;
			case "usNoLieDown": tIconFileStr = "comp-icons-settings-wakeuponly"; break;
			default: tIconFileStr = "comp-icons-settings-experiments"; break;
		};
		
		let tIconImg:UIImageView = UIImageView(); var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3);
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
		tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: tableView.frame.width, height: 45);
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45);
		tCell.backgroundColor = UIColor.white;
		
		tCell.addSubview(tLabel);
		tLabel.text = name; tLabel.font = UIFont.systemFont(ofSize: 16);
		
		return tCell;
	}
	
	func setSwitchData(_ settingsID:String, value:Bool) {
		for i:Int in 0 ..< settingsArray.count {
			if (settingsArray[i].settingsID == settingsID) {
				(settingsArray[i].settingsElement as! UISwitch).isOn = true;
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
					DataManager.nsDefaults.set((settingsArray[i].settingsElement as! UISwitch).isOn, forKey: DataManager.EXPERIMENTS_USE_MEMO_KEY);
					break;
				case "usNoLieDown":
					DataManager.nsDefaults.set((settingsArray[i].settingsElement as! UISwitch).isOn, forKey: DataManager.EXPERIMENTS_USE_NOLIEDOWN_KEY);
					break;
				default:
					break;
			}
		}
		
		DataManager.save();
	}
	
	func switchChangedEvent( _ target:UISwitch ) {
		print("switch changed. saving.");
		saveChasngesToSystem();
	}
	
	//Tableview cell view create
	func createSettingsToggle(_ name:String, defaultState:Bool, settingsID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel(); let tSwitch:UISwitch = UISwitch();
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3);
		
		switch(settingsID) {
			case "useAlarmMemo": tIconFileStr = "comp-icons-settings-memo"; break;
			case "usNoLieDown": tIconFileStr = "comp-icons-settings-wakeuponly"; break;
			default: tIconFileStr = "comp-icons-settings-experiments"; break;
		};
		
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
		let settingsObj:SettingsElement = SettingsElement();
		settingsObj.settingsID = settingsID; tCell.cellID = settingsID;
		settingsObj.settingsElement = tSwitch; //Anyobject
		
		tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: tableView.frame.width * 0.6, height: 45);
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45 /*CGFloat(45 * maxDeviceGeneral.scrRatio)*/ );
		tCell.backgroundColor = UIColor.white;
		
		tSwitch.frame.origin.x = tableView.frame.width - tSwitch.frame.width - 8;
		tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
		
		tCell.addSubview(tLabel); tCell.addSubview(tSwitch);
		
		tSwitch.addTarget(self, action: #selector(ExperimentsAlarmsSetupView.switchChangedEvent(_:)), for: .valueChanged);
		
		tLabel.text = name;
		tLabel.font = UIFont.systemFont(ofSize: 16);
		
		//push to settingselement
		settingsArray += [settingsObj];
		
		return tCell;
	}
	
}
