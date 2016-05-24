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
	
	//주중 평일 주말 3세그먼트
	var selSegmetDaysGroup:UISegmentedControl?;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		AlarmRepeatSettingsView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("alarmRepeat");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(AlarmGameListView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		
		print("Adding repeat table cells");
		//add table cells (options)
		var alarmSoundListsTableArr:Array<AlarmRepeatDayCell> = [];
		
		//주중~ 선택 기능 추가
		//for i:Int in 1 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count { 
		//를 하는 이유: 1번째 엘리멘트는 일~토 선택지가 아닌 3-세그먼트가 들어가기 때문임
		alarmSoundListsTableArr += [ createDaysGroupSelectCell() ];
		
		//일~토 추가
		for i in 0...6 {
			alarmSoundListsTableArr += [ createCell(i) ];
		} //end for
		tablesArray = [ alarmSoundListsTableArr ];
		
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
	
	override func viewWillDisappear(animated: Bool) {
		//돌아가기 직전에 설정값을 parent view에 저장해야 함.
		var tmpRepeatArr:Array<Bool> = [false, false, false, false, false, false, false];
		for i:Int in 1 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			tmpRepeatArr[i - 1] = (tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType == .Checkmark;
		}
		
		AddAlarmView.selfView!.autoSelectRepeatElement( tmpRepeatArr );
		AddAlarmView.selfView!.currentRepeatMode = tmpRepeatArr;
		
	}
	
	//// SegmentedControl func
	func segmentIdxChanged(target: UISegmentedControl) {
		//segment에 따라 리스트 자동선택
		var listPresetArray:Array<Bool> = [ false, false, false, false, false, false, false ];
		switch(target.selectedSegmentIndex) {
			case 0: //매일
				listPresetArray = [ true, true, true, true, true, true, true ];
				break;
			case 1: //주중
				listPresetArray = [ false, true, true, true, true, true, false ];
				break;
			case 2: //주말
				listPresetArray = [ true, false, false, false, false, false, true ];
				break;
			default: break;
		} //end switch
		
		//auto-selection
		for i:Int in 1 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType = listPresetArray[i - 1] == true ? .Checkmark : .None;
		}
	} //end func
	//Check auto segment status.
	func checkAutoSegmentStatus() {
		
		var repeatInfo:Array<Bool> = Array<Bool>();
		for i:Int in 1 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			repeatInfo += [(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType == .Checkmark ? true : false];
		}
		
		if (repeatInfo[0] == true && repeatInfo[1] == true && repeatInfo[2] == true &&
		repeatInfo[3] == true && repeatInfo[4] == true && repeatInfo[5] == true && repeatInfo[6] == true) { //everyday
			selSegmetDaysGroup!.selectedSegmentIndex = 0; //every
		} else if (repeatInfo[0] == false && repeatInfo[1] == true && repeatInfo[2] == true &&
			repeatInfo[3] == true && repeatInfo[4] == true && repeatInfo[5] == true && repeatInfo[6] == false) { //weekday
			selSegmetDaysGroup!.selectedSegmentIndex = 1; //day
		} else if (repeatInfo[0] == true && repeatInfo[1] == false && repeatInfo[2] == false && repeatInfo[3] == false &&
			repeatInfo[4] == false && repeatInfo[5] == false && repeatInfo[6] == true) { //weekend
			selSegmetDaysGroup!.selectedSegmentIndex = 2; //wend
		} else {
			//else
			selSegmetDaysGroup!.selectedSegmentIndex = -1;
		} //end if
		
		
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cellObj:AlarmRepeatDayCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmRepeatDayCell;
		if (cellObj.dayID == -1) {
			tableView.deselectRowAtIndexPath(indexPath, animated: true);
			return; //선택 불가능 예외
		}
		
		//Check toggle
		cellObj.accessoryType = cellObj.accessoryType == .Checkmark ? .None : .Checkmark;
		checkAutoSegmentStatus();
		
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
		/*let cellObj:AlarmRepeatDayCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmRepeatDayCell;
		if (cellObj.dayID == -1) {
			return 80;
		}*/
		if (indexPath.row == 0) {
			return 54;
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
		return 12;
	}
	
	//Tableview group-selection cell create
	func createDaysGroupSelectCell() -> AlarmRepeatDayCell {
		let tCell:AlarmRepeatDayCell = AlarmRepeatDayCell();
		tCell.backgroundColor = UIColor.whiteColor();
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 54); //기본 셀 사이즈보다 조금 큰 정도
		tCell.dayID = -1; //selection 예외처리
		
		let tSelection:UISegmentedControl
			= UISegmentedControl( items: [ Languages.$("alarmRepeatFreqEveryday"), Languages.$("alarmRepeatFreqWeekday"), Languages.$("alarmRepeatFreqWeekend") ] );
		tSelection.frame = CGRectMake( (tableView.frame.width / 2) - (190 / 2), 12, 190, 30 );
		tSelection.selectedSegmentIndex = -1; //default selected index
		tSelection.addTarget(self, action: #selector(AlarmRepeatSettingsView.segmentIdxChanged(_:)), forControlEvents: .ValueChanged);
		
		selSegmetDaysGroup = tSelection;
		
		tCell.addSubview(tSelection);
		return tCell;
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
		for i:Int in 1 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			if (repeatArr[i - 1] == true) {
				(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType = .Checkmark;
			} else {
				(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType = .None;
			}
		}
		
		checkAutoSegmentStatus(); //check segments
	} //end func
	
	
	
	//UITextfield del
	func textFieldShouldReturn(textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	
}