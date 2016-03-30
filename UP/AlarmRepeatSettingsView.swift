//
//  AlarmRepeatSettingsView.swift
//  UP
//
//  Created by ExFl on 2016. 3. 20..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//


import Foundation
import AVFoundation
import UIKit

class AlarmRepeatSettingsView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:AlarmRepeatSettingsView?;
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		AlarmRepeatSettingsView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("alarmRepeat");
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		
		print("Adding repeat table cells");
		//add table cells (options)
		var alarmSoundListsTableArr:Array<AlarmRepeatDayCell> = [];
		//일~토 추가
		for i in 0...6 {
			alarmSoundListsTableArr += [ createCell(i) ];
		} //end for
		tablesArray = [ alarmSoundListsTableArr ];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillDisappear(animated: Bool) {
		//돌아가기 직전에 설정값을 parent view에 저장해야 함.
		var tmpRepeatArr:Array<Bool> = [false, false, false, false, false, false, false];
		for i:Int in 0 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			tmpRepeatArr[i] = (tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType == .Checkmark;
		}
		
		AddAlarmView.selfView!.autoSelectRepeatElement( tmpRepeatArr );
		AddAlarmView.selfView!.currentRepeatMode = tmpRepeatArr;
		
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cellObj:AlarmRepeatDayCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmRepeatDayCell;
		
		//Check toggle
		cellObj.accessoryType = cellObj.accessoryType == .Checkmark ? .None : .Checkmark;
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
		default:
			return "";
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch(indexPath.section){
		default:
			break;
		}
		
		return UITableViewAutomaticDimension;
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.0001;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0;
	}
	
	
	//Tableview cell view create
	func createCell( dayID:Int ) -> AlarmRepeatDayCell {
		let tCell:AlarmRepeatDayCell = AlarmRepeatDayCell();
		tCell.backgroundColor = UIColor.whiteColor();
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 45); //default cell size
		
		let tLabel:UILabel = UILabel();
		tLabel.frame = CGRectMake(16, 0, tableView.frame.width * 0.85, 45);
		tLabel.font = UIFont.systemFontOfSize(16);
		
		switch( dayID ) { //0 = 일요일
			case 0:
				tLabel.text = Languages.$("alarmRepeatSun");
				tLabel.textColor = UIColor.redColor();
				break;
			case 1:
				tLabel.text = Languages.$("alarmRepeatMon"); break;
			case 2:
				tLabel.text = Languages.$("alarmRepeatTue"); break;
			case 3:
				tLabel.text = Languages.$("alarmRepeatWed"); break;
			case 4:
				tLabel.text = Languages.$("alarmRepeatThu"); break;
			case 5:
				tLabel.text = Languages.$("alarmRepeatFri"); break;
			case 6:
				tLabel.text = Languages.$("alarmRepeatSat"); break;
			
			default: break;
		}
		
		tCell.accessoryType = UITableViewCellAccessoryType.None;
		tCell.dayID = dayID;
		tCell.addSubview(tLabel);
		
		return tCell;
	}
	
	//Set selected style from other view (accessable)
	internal func setSelectedCell( repeatArr:Array<Bool> ) {
		for i:Int in 0 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			if (repeatArr[i] == true) {
				(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType = .Checkmark;
			} else {
				(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType = .None;
			}
		}
	} //end func
	
	
	
	//UITextfield del
	func textFieldShouldReturn(textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	
}