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
	
	//Alarm sound selected
	var alarmSoundSelectedObj:SoundInfoObj?;
	
	internal var showBlur:Bool = true;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		AddAlarmView.selfView = self;
		
		//ModalView
		modalView.view.backgroundColor = UIColor.whiteColor();
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#1C6A94");
		navigationCtrl.navigationBar.tintColor = UIColor.whiteColor();
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("addAlarm");
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Languages.$("generalClose"), style: .Plain, target: self, action: "viewCloseAction");
		modalView.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Languages.$("generalAdd"), style: .Plain, target: self, action: "addAlarmToDevice");
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
				createCell(2, cellID: "alarmSound")
			],
			[ /* section 4 */
				createCell(3, cellID: "alarmRepeatSetting")
			]
		];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA"); //modalView.view.backgroundColor;
		
		//set subview size
		alarmSoundListView.view.frame = CGRectMake(
			0, 0, modalView.view.frame.width, modalView.view.frame.height );
		
	}
	
	//set sound element from other view
	internal func setSoundElement(sInfo:SoundInfoObj) {
		(getElementFromTable("alarmSound") as! UILabel).text = sInfo.soundLangName;
		alarmSoundSelectedObj = sInfo;
	}
	
	//add alarm evt
	func addAlarmToDevice() {
		
		var repeatArray:Array<Bool> = [];
		var listArray:Array<UISingleSegmentControl> = (getElementFromTable("alarmRepeatSetting") as! Array<UISingleSegmentControl>);
		
		repeatArray += [ listArray[6].selectedSegmentIndex == 0 ? true : false ]; //Sunday is first at array
		for (var i:Int = 0; i < listArray.count-1; ++i) { //add repeat arr. starts from mon to sat
			repeatArray += [ listArray[i].selectedSegmentIndex==0 ? true : false ];
		}
		
		///Add alarm to system
		AlarmManager.addAlarm((getElementFromTable("alarmDatePicker") as! UIDatePicker).date,
			alarmTitle: (getElementFromTable("alarmName") as! UITextField).text!,
			gameID: 0, /* dummy data */
			soundFile: alarmSoundSelectedObj!,
			repeatArr: repeatArray);
		
		//added successfully. close view
		viewCloseAction();
		
	}
	
	//cell touchevent
	internal func cellFunc(cellID:String) {
		switch(cellID) {
			case "alarmSound":
				//TODO error pushviewcontroller
				
				/*if(navigationCtrl.viewControllers.count == 2) {
					print("finishing existing stack"); //<- 이거 안됨
					//navigationCtrl.popToRootViewControllerAnimated(true);
					navigationCtrl.popViewControllerAnimated(true);
					alarmSoundListView.dismissViewControllerAnimated(false, completion: nil);
					alarmSoundListView = AlarmSoundListView();
					//navigationCtrl.
				} else {
					
				}*/
				navigationCtrl.pushViewController(self.alarmSoundListView, animated: true);
					
				break
			default: break;
		}
		print("cell", cellID);
	}
	
	//for default setting at view opening
	internal func getElementFromTable(cellID:String, isSubElement:Bool = false)->AnyObject? {
		//let anyobjectOfTable:AnyObject?;
		for (var i:Int = 0; i < tableCells.count; ++i) {
			if (tableCells[i].cellID == cellID) {
				return isSubElement ? tableCells[i].cellSubElement! : tableCells[i].cellElement!;
			}
		}
		return nil;
	}
	
	func setupModalView(frame:CGRect) {
		modalView.view.frame = frame;
		//alarmSoundListView.view.frame = frame;
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		if (showBlur) {
			ViewController.viewSelf?.showHideBlurview(false);
		}
		self.dismissViewControllerAnimated(true, completion: nil);
	}
	
	///// for table func
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 4;
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
			case 3:
				return 102;
			default:
				break;
		}
		
		if #available(iOS 8.0, *) {
			return UITableViewAutomaticDimension;
		} else {
			return 45;
		}
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 12;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0;
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
					default: break;
				}
				
				tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
				
				tCell.cellElement = tSettingLabel;
				tSettingLabel.text = Languages.$("generalDefault");
				tCell.addSubview(tLabel); tCell.addSubview(tSettingLabel);
				break;
			case 3: //segment sel
				let tSegSel:UITouchableSegmentControl = UITouchableSegmentControl( /* 매일 주중 주말 */
					items: [ Languages.$("alarmRepeatFreqEveryday"), Languages.$("alarmRepeatFreqWeekday"), Languages.$("alarmRepeatFreqWeekend") ]);
				//tSegSel.selectedSegmentIndex = -1;
				tSegSel.frame = CGRectMake( (self.modalView.view.frame.width / 8), 12, (self.modalView.view.frame.width * 0.75 ), 36 );
				var tSegSingleArray:Array<UISingleSegmentControl> = []; //월~일
				tSegSingleArray += [ UISingleSegmentControl(items: [Languages.$("alarmRepeatMon")] ) ];
				tSegSingleArray += [ UISingleSegmentControl(items: [Languages.$("alarmRepeatTue")] ) ];
				tSegSingleArray += [ UISingleSegmentControl(items: [Languages.$("alarmRepeatWed")] ) ];
				tSegSingleArray += [ UISingleSegmentControl(items: [Languages.$("alarmRepeatThu")] ) ];
				tSegSingleArray += [ UISingleSegmentControl(items: [Languages.$("alarmRepeatFri")] ) ];
				tSegSingleArray += [ UISingleSegmentControl(items: [Languages.$("alarmRepeatSat")] ) ];
				tSegSingleArray += [ UISingleSegmentControl(items: [Languages.$("alarmRepeatSun")] ) ];
				
				for (var i:Int = 0; i < tSegSingleArray.count; ++i) { //고정크기 32.
					tSegSingleArray[i].segmentID = i;
					tSegSingleArray[i].touchFunc = segTouchEventHandler;
					tSegSingleArray[i].setFrame( ((self.modalView.view.frame.width - (34.6 * CGFloat(7))) / 2) + (34.6 * CGFloat(i)) , y: 58);
					tCell.addSubview(tSegSingleArray[i]);
				}
				
				tSegSel.touchFunc = dayControllerSegmentTouchHandler;
				
				tCell.cellElement = tSegSingleArray;
				tCell.cellSubElement = tSegSel; //for tab init
					
				tCell.addSubview(tSegSel);
				break;
			
			default:
				return tCell; //return empty cell
		}
		
		/*
		let tLabel:UILabel = UILabel();
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRectMake(16, 0, self.modalView.frame.width * 0.75, CGFloat(45));
		tCell.addSubview(tLabel);
		tLabel.text = name;
		tLabel.font = UIFont.systemFontOfSize(16);
		*/
		
		tableCells += [tCell];
		return tCell;
	}
	
	//segment(top) touch
	func dayControllerSegmentTouchHandler ( segmentElement:UITouchableSegmentControl ) {
		print("daycontroller touching");
		
		var listPointer:Array<UISingleSegmentControl> = (getElementFromTable("alarmRepeatSetting") as! Array<UISingleSegmentControl>);
		switch(segmentElement.selectedSegmentIndex) {
			case 0: //every
				for (var i:Int = 0; i < listPointer.count; ++i) {
					listPointer[i].selectedSegmentIndex = 0; //all on
				}
				break;
			case 1: //week
				listPointer[0].selectedSegmentIndex = 0; listPointer[1].selectedSegmentIndex = 0;
				listPointer[2].selectedSegmentIndex = 0; listPointer[3].selectedSegmentIndex = 0; listPointer[4].selectedSegmentIndex = 0;
				listPointer[5].selectedSegmentIndex = -1; listPointer[6].selectedSegmentIndex = -1;
				
				break;
			case 2: //weekend
				listPointer[0].selectedSegmentIndex = -1; listPointer[1].selectedSegmentIndex = -1;
				listPointer[2].selectedSegmentIndex = -1; listPointer[3].selectedSegmentIndex = -1; listPointer[4].selectedSegmentIndex = -1;
				listPointer[5].selectedSegmentIndex = 0; listPointer[6].selectedSegmentIndex = 0;
				break;
			default: break;
		}
		
	}
	
	//segments touch
	func segTouchEventHandler( segmentElement:UISingleSegmentControl ) {
		print(segmentElement.segmentID, "state", segmentElement.selectedSegmentIndex);
		//월~금만 선택된 경우 주중, 모두 선택된 경우 매일, 토,일만 선택된 경우 주말, 그 외에 선택해제
		var listPointer:Array<UISingleSegmentControl> = (getElementFromTable("alarmRepeatSetting") as! Array<UISingleSegmentControl>);
		let dayPointer:UITouchableSegmentControl = getElementFromTable("alarmRepeatSetting", isSubElement: true) as! UITouchableSegmentControl;
		if (listPointer[0].selectedSegmentIndex == 0 &&
			listPointer[1].selectedSegmentIndex == 0 &&
			listPointer[2].selectedSegmentIndex == 0 &&
			listPointer[3].selectedSegmentIndex == 0 &&
			listPointer[4].selectedSegmentIndex == 0 &&
			listPointer[5].selectedSegmentIndex == 0 &&
			listPointer[6].selectedSegmentIndex == 0) { //everyday
				dayPointer.selectedSegmentIndex = 0;
		} else if (listPointer[0].selectedSegmentIndex == 0 &&
			listPointer[1].selectedSegmentIndex == 0 &&
			listPointer[2].selectedSegmentIndex == 0 &&
			listPointer[3].selectedSegmentIndex == 0 &&
			listPointer[4].selectedSegmentIndex == 0 &&
			listPointer[5].selectedSegmentIndex == -1 &&
			listPointer[6].selectedSegmentIndex == -1) { //weekday
				dayPointer.selectedSegmentIndex = 1;
		} else if (listPointer[0].selectedSegmentIndex == -1 &&
			listPointer[1].selectedSegmentIndex == -1 &&
			listPointer[2].selectedSegmentIndex == -1 &&
			listPointer[3].selectedSegmentIndex == -1 &&
			listPointer[4].selectedSegmentIndex == -1 &&
			listPointer[5].selectedSegmentIndex == 0 &&
			listPointer[6].selectedSegmentIndex == 0) { //weekend
				dayPointer.selectedSegmentIndex = 2;
		} else {
			dayPointer.selectedSegmentIndex = -1; //unselected
		}
		
	}
	
	//clear all components
	internal func clearComponents() {
		(self.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = NSDate(); //date to current
		self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
		(self.getElementFromTable("alarmName") as! UITextField).text = ""; //empty alarm name
		self.setSoundElement(UPAlarmSoundLists.list[0]); //default - first element of soundlist
		self.resetAlarmRepeatCell();
	}
	
	//UITextfield del
	func textFieldShouldReturn(textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	//Alarm element reset func
	internal func resetAlarmRepeatCell() {
		var listArray:Array<UISingleSegmentControl> = (getElementFromTable("alarmRepeatSetting") as! Array<UISingleSegmentControl>);
		for (var i:Int = 0; i < listArray.count; ++i) {
			listArray[i].selectedSegmentIndex = -1;
		}
		(getElementFromTable("alarmRepeatSetting", isSubElement: true) as! UITouchableSegmentControl).selectedSegmentIndex = -1;
		
	}
	
	
}