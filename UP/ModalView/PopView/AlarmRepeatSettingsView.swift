//
//  AlarmRepeatSettingsView.swift
//  UP
//
//  Created by ExFl on 2016. 3. 20..
//  Copyright © 2016년 Project UP. All rights reserved.
//


import Foundation
import AVFoundation
import UIKit

class AlarmRepeatSettingsView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:AlarmRepeatSettingsView?;
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped);
	var tablesArray:Array<AnyObject> = [];
	
	//주중 평일 주말 3세그먼트
	var selSegmetDaysGroup:UISegmentedControl?;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		AlarmRepeatSettingsView.selfView = self;
		
		self.view.backgroundColor = UIColor.clear;
		
		//ModalView
		self.view.backgroundColor = UIColor.white;
		self.title = LanguagesManager.$("alarmRepeat");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), for: UIControlState());
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(AlarmGameListView.popToRootAction), for: .touchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height);
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
		tablesArray = [ alarmSoundListsTableArr as AnyObject ];
		
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
	
	override func viewWillDisappear(_ animated: Bool) {
		//돌아가기 직전에 설정값을 parent view에 저장해야 함.
		var tmpRepeatArr:Array<Bool> = [false, false, false, false, false, false, false];
		for i:Int in 1 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			tmpRepeatArr[i - 1] = (tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType == .checkmark;
		}
		
		AddAlarmView.selfView!.autoSelectRepeatElement( tmpRepeatArr );
		AddAlarmView.selfView!.currentRepeatMode = tmpRepeatArr;
		
	}
	
	//// SegmentedControl func
	func segmentIdxChanged(_ target: UISegmentedControl) {
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
			(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType = listPresetArray[i - 1] == true ? .checkmark : .none;
		}
	} //end func
	//Check auto segment status.
	func checkAutoSegmentStatus() {
		
		var repeatInfo:Array<Bool> = Array<Bool>();
		for i:Int in 1 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			repeatInfo += [(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType == .checkmark ? true : false];
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
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellObj:AlarmRepeatDayCell = tableView.cellForRow(at: indexPath) as! AlarmRepeatDayCell;
		if (cellObj.dayID == -1) {
			tableView.deselectRow(at: indexPath, animated: true);
			return; //선택 불가능 예외
		}
		
		//Check toggle
		cellObj.accessoryType = cellObj.accessoryType == .checkmark ? .none : .checkmark;
		checkAutoSegmentStatus();
		
		tableView.deselectRow(at: indexPath, animated: true);
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
		default:
			return "";
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch((indexPath as NSIndexPath).section){
			default:
				break;
		}
		
		if ((indexPath as NSIndexPath).row == 0) {
			return 54;
		}
		return UITableViewAutomaticDimension;
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] as! Array<AnyObject>)[(indexPath as NSIndexPath).row] as! UITableViewCell;
		return cell;
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.0001;
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 12;
	}
	
	//Tableview group-selection cell create
	func createDaysGroupSelectCell() -> AlarmRepeatDayCell {
		let tCell:AlarmRepeatDayCell = AlarmRepeatDayCell();
		tCell.backgroundColor = UIColor.white;
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 54); //기본 셀 사이즈보다 조금 큰 정도
		tCell.dayID = -1; //selection 예외처리
		
		let tSelection:UISegmentedControl
			= UISegmentedControl( items: [ LanguagesManager.$("alarmRepeatFreqEveryday"), LanguagesManager.$("alarmRepeatFreqWeekday"), LanguagesManager.$("alarmRepeatFreqWeekend") ] );
		tSelection.frame = CGRect( x: (tableView.frame.width / 2) - (220 / 2), y: 12, width: 220, height: 30 );
		tSelection.selectedSegmentIndex = -1; //default selected index
		tSelection.addTarget(self, action: #selector(AlarmRepeatSettingsView.segmentIdxChanged(_:)), for: .valueChanged);
		
		selSegmetDaysGroup = tSelection;
		
		tCell.addSubview(tSelection);
		return tCell;
	}
	
	//Tableview cell view create
	func createCell( _ dayID:Int ) -> AlarmRepeatDayCell {
		let tCell:AlarmRepeatDayCell = AlarmRepeatDayCell();
		tCell.backgroundColor = UIColor.white;
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45); //default cell size
		
		let tLabel:UILabel = UILabel();
		tLabel.frame = CGRect(x: 16, y: 0, width: tableView.frame.width * 0.85, height: 45);
		tLabel.font = UIFont.systemFont(ofSize: 16);
		
		switch( dayID ) { //0 = 일요일
			case 0:
				tLabel.text = LanguagesManager.$("alarmRepeatSun");
				tLabel.textColor = UIColor.red;
				break;
			case 1:
				tLabel.text = LanguagesManager.$("alarmRepeatMon"); break;
			case 2:
				tLabel.text = LanguagesManager.$("alarmRepeatTue"); break;
			case 3:
				tLabel.text = LanguagesManager.$("alarmRepeatWed"); break;
			case 4:
				tLabel.text = LanguagesManager.$("alarmRepeatThu"); break;
			case 5:
				tLabel.text = LanguagesManager.$("alarmRepeatFri"); break;
			case 6:
				tLabel.text = LanguagesManager.$("alarmRepeatSat"); break;
			
			default: break;
		}
		
		tCell.accessoryType = UITableViewCellAccessoryType.none;
		tCell.dayID = dayID;
		tCell.addSubview(tLabel);
		
		return tCell;
	}
	
	//Set selected style from other view (accessable)
	internal func setSelectedCell( _ repeatArr:Array<Bool> ) {
		for i:Int in 1 ..< (tablesArray[0] as! Array<AlarmRepeatDayCell>).count {
			if (repeatArr[i - 1] == true) {
				(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType = .checkmark;
			} else {
				(tablesArray[0] as! Array<AlarmRepeatDayCell>)[i].accessoryType = .none;
			}
		}
		
		checkAutoSegmentStatus(); //check segments
	} //end func
	
	
	
	//UITextfield del
	func textFieldShouldReturn(_ textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	
}
