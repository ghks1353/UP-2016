//
//  AddAlarmView.swift
//  	
//
//  Created by ExFl on 2016. 1. 31..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//


import Foundation
import UIKit

class AddAlarmView:UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
	
	//클래스 외부접근을 위함
	static var selfView:AddAlarmView?;
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<AnyObject> = [];
	var tableCells:Array<AlarmSettingsCell> = [];
	
	//Subview for select
	var alarmSoundListView:AlarmSoundListView = GlobalSubView.alarmSoundListView; // = AlarmSoundListView();
	var alarmGameListView:AlarmGameListView = GlobalSubView.alarmGameListView; 
	var alarmRepeatSelectListView:AlarmRepeatSettingsView = GlobalSubView.alarmRepeatSettingsView;
	//Alarm sound selected
	var alarmSoundSelectedObj:SoundInfoObj = SoundInfoObj(soundName: "", fileName: "");
	//Game selected
	var gameSelectedID:Int = -1;
	
	//Default alarm status (default: true)
	var alarmDefaultStatus:Bool = true;
	var editingAlarmID:Int = -1;
	
	internal var currentRepeatMode:Array<Bool> = [false, false, false, false, false, false, false];
	
	internal var showBlur:Bool = true;
	internal var isAlarmEditMode:Bool = false;
	
	var confirmed:Bool = false; //편집 혹은 확인을 누를 경우임.
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		AddAlarmView.selfView = self;
		
		//ModalView
		modalView.view.backgroundColor = UIColor.whiteColor();
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#663300");
		navigationCtrl.navigationBar.tintColor = UIColor.whiteColor();
		navigationCtrl.view.frame = modalView.view.frame;
		
		modalView.title = Languages.$("alarmSettings");
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(AddAlarmView.viewCloseAction));
		modalView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(AddAlarmView.addAlarmToDevice));
		
		//modalView.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Languages.$("generalAdd"), style: .Plain, target: self, action: #selector(AddAlarmView.addAlarmToDevice));
		
		modalView.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor();
		modalView.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor();
		self.view.addSubview(navigationCtrl.view);
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
		modalView.view.addSubview(tableView);
		
		
		//add table cells (options)
		tablesArray = [
			[ /* section 1 */
				createCell(0, cellID: "alarmName")
			],
			[ /* section 2 */
				createCell(1, cellID: "alarmDatePicker")
			],
			[ /* section 3 */
				createCell(2, cellID: "alarmGame"),
				createCell(2, cellID: "alarmSound"),
				
				createCell(2, cellID: "alarmRepeatSetting")
			]
		];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA"); //modalView.view.backgroundColor;
		
		//set subview size
		setSubviewSize();
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		//self.view.autoresizingMask = .None;
		
		FitModalLocationToCenter();
	}
	
	
	internal func setSubviewSize() {
		alarmSoundListView.view.frame = CGRectMake(
			0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height );
		alarmGameListView.view.frame = CGRectMake(
			0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height );
		alarmRepeatSelectListView.view.frame = CGRectMake(
			0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height );
	}
	
	
	override func viewWillAppear(animated: Bool) {
		//setupModalView( DeviceGeneral.defaultModalSizeRect );
	}
	
	// iOS7 Background fallback
	/*override func viewDidAppear(animated: Bool) {
		if #available(iOS 8.0, *) {
		} else {
			modalBackground!.image = ViewController.viewSelf!.viewImage;
			removeBackgroundViews();
			self.view.addSubview(modalBackgroundBlackCover!); self.view.addSubview(modalBackground!);
			self.view.sendSubviewToBack(modalBackgroundBlackCover!); self.view.sendSubviewToBack(modalBackground!);
			if (showBlur == true) { //Animation with singie-view
				modalBackgroundBlackCover!.alpha = 0;
				UIView.animateWithDuration(0.32, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
					self.modalBackgroundBlackCover!.alpha = 0.7;
					}, completion: nil);
			} else { //No-animation with multiple view
				modalBackgroundBlackCover!.alpha = 0.7;
			}
		}
	}*/ // iOS7 Background fallback end
	
	//set sound element from other view
	internal func setSoundElement(sInfo:SoundInfoObj) {
		(getElementFromTable("alarmSound") as! UILabel).text = sInfo.soundLangName;
		alarmSoundSelectedObj = sInfo;
	}
	
	//set game id from other view
	internal func setGameElement(gameID:Int) {
		var gameName:String = "";
		switch(gameID) {
			case -1: //RANDOM
				gameName = Languages.$("alarmGameRandom");
				break;
			default:
				gameName = UPAlarmGameLists.list[gameID].gameLangName;
				break;
		}
		
		(getElementFromTable("alarmGame") as! UILabel).text = gameName;
		gameSelectedID = gameID;
	}
	
	//add alarm evt
	func addAlarmToDevice() {
		
		confirmed = true;
		
		if (isAlarmEditMode == false) {
			///Add alarm to system
			AlarmManager.addAlarm((getElementFromTable("alarmDatePicker") as! UIDatePicker).date,
				funcAlarmTitle: (getElementFromTable("alarmName") as! UITextField).text!,
				gameID: gameSelectedID,
				soundFile: alarmSoundSelectedObj,
				repeatArr: currentRepeatMode,
				insertAt: -1,
				alarmID: -1);
		} else {
			//Edit alarm
			AlarmManager.editAlarm(editingAlarmID,
				funcDate: (getElementFromTable("alarmDatePicker") as! UIDatePicker).date,
				alarmTitle: (getElementFromTable("alarmName") as! UITextField).text!,
				gameID: gameSelectedID,
				soundFile: alarmSoundSelectedObj,
				repeatArr: currentRepeatMode, toggleStatus: alarmDefaultStatus);
			
		}
		
		//if playing sound, stop it
		//alarmSoundListView.stopSound();
		
		//added successfully. close view
		viewCloseAction();
		
	}
	
	//for default setting at view opening
	internal func getElementFromTable(cellID:String, isSubElement:Bool = false)->AnyObject? {
		//let anyobjectOfTable:AnyObject?;
		for i:Int in 0 ..< tableCells.count {
			if (tableCells[i].cellID == cellID) {
				return isSubElement ? tableCells[i].cellSubElement! : tableCells[i].cellElement!;
			}
		}
		return nil;
	}
	
	func setupModalView(frame:CGRect) {
		modalView.view.frame = frame;
		setSubviewSize();
	}
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame.origin.x = DeviceGeneral.defaultModalSizeRect.minX;
		navigationCtrl.view.frame.origin.y = DeviceGeneral.defaultModalSizeRect.minY;
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		
		//if playing sound, stop it
		alarmSoundListView.stopSound();
		
		if (showBlur) {
			ViewController.viewSelf!.showHideBlurview(false);
			
			//Add alarm alert to main
			if (confirmed == true) {
				ViewController.viewSelf!.showMessageOnView(Languages.$(isAlarmEditMode == true ? "informationAlarmEdited" : "informationAlarmAdded"), backgroundColorHex: "219421", textColorHex: "FFFFFF");
			}
			
		} else {
			
			//Add alarm alert to list
			if (confirmed == true) {
				AlarmListView.selfView!.showMessageOnView(Languages.$(isAlarmEditMode == true ? "informationAlarmEdited" : "informationAlarmAdded"), backgroundColorHex: "219421", textColorHex: "FFFFFF");
			}
			
		} //end if
		
		self.dismissViewControllerAnimated(true, completion: nil);
	}
	
	///// for table func
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3; //4;
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
			case 1:
				return 200;
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
		return 8;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 4;
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cellID:String = (tableView.cellForRowAtIndexPath(indexPath) as! AlarmSettingsCell).cellID;
		switch(cellID) {
			case "alarmGame": //게임 선택 뷰
				self.alarmGameListView.selectCell( gameSelectedID );
				navigationCtrl.pushViewController(self.alarmGameListView, animated: true);
				break;
			case "alarmSound": //알람 사운드 선택 뷰
				self.alarmSoundListView.setSelectedCell( alarmSoundSelectedObj );
				navigationCtrl.pushViewController(self.alarmSoundListView, animated: true);
				break
			case "alarmRepeatSetting": //알람 반복 선택 뷰
				self.alarmRepeatSelectListView.setSelectedCell( currentRepeatMode );
				navigationCtrl.pushViewController(self.alarmRepeatSelectListView, animated: true);
				
				
				break;
			default: break;
		} //end switch
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	
	//Tableview cell view create
	func createCell( cellType:Int, cellID:String ) -> AlarmSettingsCell {
		let tCell:AlarmSettingsCell = AlarmSettingsCell();
		tCell.cellID = cellID;
		tCell.backgroundColor = UIColor.whiteColor();
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45); //default cell size
		
		switch( cellType ) {
			case 0: //Inputtext cell
				let alarmNameInput:UITextField = UITextField(frame: tCell.frame);
				alarmNameInput.placeholder = Languages.$("alarmTitle");
				alarmNameInput.borderStyle = UITextBorderStyle.None;
				alarmNameInput.autocorrectionType = UITextAutocorrectionType.No;
				alarmNameInput.keyboardType = UIKeyboardType.Default;
				alarmNameInput.returnKeyType = UIReturnKeyType.Done;
				alarmNameInput.clearButtonMode = UITextFieldViewMode.Never;
				alarmNameInput.contentVerticalAlignment = UIControlContentVerticalAlignment.Center;
				alarmNameInput.textAlignment = .Center;
				alarmNameInput.delegate = self;
				
				tCell.cellElement = alarmNameInput;
				tCell.addSubview(alarmNameInput);
				break;
			case 1: //DatePicker cell
				tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 200); //cell size to datepicker size fit
				let alarmTimePicker:UIDatePicker = UIDatePicker(frame: tCell.frame);
				alarmTimePicker.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 200);
				alarmTimePicker.datePickerMode = UIDatePickerMode.Time;
				alarmTimePicker.date = NSDate(); //default => current
				//alarmTimePicker.fr
				tCell.cellElement = alarmTimePicker;
				tCell.addSubview(alarmTimePicker);
				break;
			
			case 2: //Option sel label cell
				let tLabel:UILabel = UILabel(); let tSettingLabel:UILabel = UILabel();
				tLabel.frame = CGRectMake(16, 0, self.modalView.view.frame.width * 0.4, 45);
				tSettingLabel.frame = CGRectMake(self.modalView.view.frame.width - self.modalView.view.frame.width * 0.5 - 32, 0, self.modalView.view.frame.width * 0.5, 45);
				tSettingLabel.textAlignment = .Right;
				tLabel.font = UIFont.systemFontOfSize(16); tSettingLabel.font = tLabel.font;
				tSettingLabel.textColor = UPUtils.colorWithHexString("#CCCCCC");
				
				switch(cellID) {
					case "alarmGame":
						tLabel.text = Languages.$("alarmGame");
						break;
					case "alarmSound":
						tLabel.text = Languages.$("alarmSound");
						break;
					case "alarmRepeatSetting":
						tLabel.text = Languages.$("alarmRepeat");
						break;
					default: break;
				}
				
				tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
				
				tCell.cellElement = tSettingLabel;
				tSettingLabel.text = Languages.$("generalDefault");
				tCell.addSubview(tLabel); tCell.addSubview(tSettingLabel);
				break;
			
			
			default:
				return tCell; //return empty cell
		}
		
		tableCells += [tCell];
		return tCell;
	}
	
	
	internal func autoSelectRepeatElement( repeatInfo:Array<Bool> ) {
		//alarmRepeatSelectListView.setSelectedCell( repeatInfo );
		
		let settingsLabelPointer:UILabel = getElementFromTable("alarmRepeatSetting") as! UILabel;
		var repeatCount:Int = 0; var repeatDayNum:Int = -1;
		for i:Int in 0 ..< repeatInfo.count {
			if (repeatInfo[i] == true) {
				repeatCount += 1;
				repeatDayNum = i;
			}
		} //end for
		
		
		if (repeatCount == 7) { //everyday
				settingsLabelPointer.text = Languages.$("alarmRepeatFreqEveryday");
		} else if (repeatInfo[0] == false && repeatInfo[1] == true && repeatInfo[2] == true &&
			repeatInfo[3] == true && repeatInfo[4] == true && repeatInfo[5] == true && repeatInfo[6] == false) { //weekday
				settingsLabelPointer.text = Languages.$("alarmRepeatFreqWeekday");
		} else if (repeatInfo[0] == true && repeatInfo[1] == false && repeatInfo[2] == false && repeatInfo[3] == false &&
			repeatInfo[4] == false && repeatInfo[5] == false && repeatInfo[6] == true) { //weekend
				settingsLabelPointer.text = Languages.$("alarmRepeatFreqWeekend");
		} else if (repeatInfo[0] == false && repeatInfo[1] == false && repeatInfo[2] == false && repeatInfo[3] == false &&
			repeatInfo[4] == false && repeatInfo[5] == false && repeatInfo[6] == false) {
			settingsLabelPointer.text = Languages.$("alarmRepeatFreqOnce"); //no repeats
		} else if (repeatCount == 1) { //하루만 있는 경우는, 해당 하루의 요일을 표시함
			print("rep:", repeatDayNum);
			switch(repeatDayNum) {
				case 0: settingsLabelPointer.text = Languages.$("alarmRepeatSun"); break;
				case 1: settingsLabelPointer.text = Languages.$("alarmRepeatMon"); break;
				case 2: settingsLabelPointer.text = Languages.$("alarmRepeatTue"); break;
				case 3: settingsLabelPointer.text = Languages.$("alarmRepeatWed"); break;
				case 4: settingsLabelPointer.text = Languages.$("alarmRepeatThu"); break;
				case 5: settingsLabelPointer.text = Languages.$("alarmRepeatFri"); break;
				case 6: settingsLabelPointer.text = Languages.$("alarmRepeatSat"); break;
					
				default: break;
			}
		} else {
			settingsLabelPointer.text = Languages.$("alarmRepeatFreqOn"); //unselected
		}
	}
	
	//clear all components
	internal func clearComponents() {
		(self.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = NSDate(); //date to current
		(self.getElementFromTable("alarmName") as! UITextField).text = ""; //empty alarm name
		self.setSoundElement(SoundManager.list[0]); //default - first element of soundlist
		self.setGameElement(-1); //set default to random
		
		gameSelectedID = -1; //clear selected game id
		self.resetAlarmRepeatCell();
		
		modalView.title = Languages.$("alarmSettings"); //Modal title set to alarmsettings
		//modalView.navigationItem.rightBarButtonItem!.title = Languages.$("generalAdd");
		
		isAlarmEditMode = false; //AddMode
		alarmDefaultStatus = true; //default on
		editingAlarmID = -1;
		confirmed = false;
		
		self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
	}
	
	//components fill for modify alarm
	internal func fillComponentsWithEditMode( alarmID:Int, alarmName:String, alarmFireDate:NSDate, selectedGameID:Int, selectedSoundFileName:String, repeatInfo:Array<Bool>, alarmDefaultToggle:Bool) {
		//set alarm name
		(self.getElementFromTable("alarmName") as! UITextField).text = alarmName;
		(self.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = alarmFireDate; //uipicker
		self.setSoundElement(SoundManager.findSoundObjectWithFileName(selectedSoundFileName)); //set sound
		self.setGameElement(selectedGameID); //set game
		self.resetAlarmRepeatCell();
		
		//set alarm repeat element
		autoSelectRepeatElement( repeatInfo );
		currentRepeatMode = repeatInfo;
		
		//alarmRepeatSelectListView.setSelectedCell( currentRepeatMode );
		
		gameSelectedID = selectedGameID;
		confirmed = false;
		
		modalView.title = Languages.$("alarmEditTitle"); //Modal title set to alarmedit
		//modalView.navigationItem.rightBarButtonItem!.title = Languages.$("generalComplete");
		
		isAlarmEditMode = true; //EditMode
		alarmDefaultStatus = alarmDefaultToggle; //Default toggle status
		editingAlarmID = alarmID;
		
		self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
	}
	
	//UITextfield del
	func textFieldShouldReturn(textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	//Alarm element reset func
	internal func resetAlarmRepeatCell() {
		let resetedRepeatInfo:Array<Bool> = [false, false, false, false, false, false, false];
		autoSelectRepeatElement( resetedRepeatInfo );
		currentRepeatMode = resetedRepeatInfo;
		
		//alarmRepeatSelectListView.setSelectedCell( resetedRepeatInfo );
	}
	
	
}