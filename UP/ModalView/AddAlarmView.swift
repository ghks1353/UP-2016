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
	//Current sound level
	var alarmCurrentSoundLevel:Int = 0;
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
		modalView.view.frame = DeviceGeneral.defaultModalSizeRect;
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#4F3317");
		navigationCtrl.navigationBar.tintColor = UIColor.whiteColor();
		navigationCtrl.view.frame = modalView.view.frame;
		
		modalView.title = Languages.$("alarmSettings");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(AddAlarmView.viewCloseAction), forControlEvents: .TouchUpInside);
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		
		//add right items
		let navRightPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navRightPadding.width = -12; //Button right padding
		let navFuncButton:UIButton = UIButton(); //Add image into UIButton
		navFuncButton.setImage( UIImage(named: "modal-check"), forState: .Normal);
		navFuncButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navFuncButton.addTarget(self, action: #selector(AddAlarmView.addAlarmToDevice), forControlEvents: .TouchUpInside);
		modalView.navigationItem.rightBarButtonItems = [ navRightPadding, UIBarButtonItem(customView: navFuncButton) ];
		///////// Nav items fin
		
		//modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(AddAlarmView.viewCloseAction));
		//modalView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(AddAlarmView.addAlarmToDevice));
		
		//add ctrl
		self.view.addSubview(navigationCtrl.view);
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
		modalView.view.addSubview(tableView);
		
		/*
		DataManager.initDefaults();
		let tmpOption:Bool = DataManager.nsDefaults.boolForKey(DataManager.EXPERIMENTS_USE_MEMO_KEY);
		if (tmpOption == true) { /* badge option is true? */
		setSwitchData("useAlarmMemo", value: true);
		}
*/
		
		//add table cells (options)
		tablesArray = [
			[ /* section 1 */
				createCell(0, cellID: "alarmName"),
				createCell(0, cellID: "alarmMemo")
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
		
		//SET MASK for dot eff
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"));
		modalMaskImageView.frame = modalView.view.frame;
		modalMaskImageView.contentMode = .ScaleAspectFit; self.view.maskView = modalMaskImageView;
		
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
	
	
	/////// View transition animation
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//알람 메모 사용기능 시 사용 (실험실)
		//이건 단순히 hidden 상태만 조정하는거임
		DataManager.initDefaults();
		let tmpOption:Bool = DataManager.nsDefaults.boolForKey(DataManager.EXPERIMENTS_USE_MEMO_KEY);
		let alarmsCellArr:Array<AlarmSettingsCell> = tablesArray[0] as! Array<AlarmSettingsCell>;
		if (tmpOption == true) { /* 메모 사용 시 */
			alarmsCellArr[1].hidden = false;
		} else { //메모 사용 안함.
			alarmsCellArr[1].hidden = true;
		}
		tableView.reloadData();
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_ALARMADD);
	}
	
	override func viewWillDisappear(animated: Bool) {
		AnalyticsManager.untrackScreen(); //untrack to previous screen
	}
	
	override func viewDidAppear(animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRectMake(0, DeviceGeneral.scrSize!.height,
		                             DeviceGeneral.scrSize!.width, DeviceGeneral.scrSize!.height);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.view.frame = CGRectMake(0, 0,
				DeviceGeneral.scrSize!.width, DeviceGeneral.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	
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
				funcAlarmMemo: (getElementFromTable("alarmMemo") as! UITextField).text!,
				gameID: gameSelectedID,
				alarmLevel: alarmCurrentSoundLevel,
				soundFile: alarmSoundSelectedObj,
				repeatArr: currentRepeatMode,
				insertAt: -1,
				alarmID: -1);
		} else {
			//Edit alarm
			AlarmManager.editAlarm(editingAlarmID,
				funcDate: (getElementFromTable("alarmDatePicker") as! UIDatePicker).date,
				alarmTitle: (getElementFromTable("alarmName") as! UITextField).text!,
				alarmMemo: (getElementFromTable("alarmMemo") as! UITextField).text!,
				gameID: gameSelectedID,
				soundLevel: alarmCurrentSoundLevel,
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
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceGeneral.defaultModalSizeRect;
		
		if (self.view.maskView != nil) {
			self.view.maskView!.frame = DeviceGeneral.defaultModalSizeRect;
		}
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
			//Check alarm make/ornot
			AlarmListView.selfView!.checkAlarmLimitExceed();
			AlarmListView.selfView!.checkAlarmIsEmpty(); //and chk list is empty or not
			
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
		
		let cellArr:Array<AlarmSettingsCell> = tablesArray[indexPath.section] as! Array<AlarmSettingsCell>;
		let cell:AlarmSettingsCell = cellArr[indexPath.row];
		
		if (cell.hidden == true) {
			return 0;
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
				self.alarmSoundListView.soundSliderPointer!.value = Float(alarmCurrentSoundLevel) / 100; //0~1 scale
				self.alarmSoundListView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
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
				//alarmMemo
				switch(cellID) {
					case "alarmName":
						alarmNameInput.placeholder = Languages.$("alarmTitle");
						break;
					case "alarmMemo":
						alarmNameInput.placeholder = Languages.$("alarmMemo");
						break;
					default:
						alarmNameInput.placeholder = "";
						break;
				} //end switch
				
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
				tSettingLabel.frame = CGRectMake(self.modalView.view.frame.width - self.modalView.view.frame.width * 0.4 - 32, 0, self.modalView.view.frame.width * 0.4, 45);
				tSettingLabel.textAlignment = .Right;
				tLabel.font = UIFont.systemFontOfSize(16); tSettingLabel.font = tLabel.font;
				tSettingLabel.textColor = UPUtils.colorWithHexString("#999999");
				
				//아이콘 표시 관련
				let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
				tIconImg.frame = CGRectMake(12, 6, 31.3, 31.3);
				switch(cellID) { //특정 조건으로 아이콘 구분
					case "alarmGame": tIconFileStr = "comp-icons-settings-newgames"; break;
					default: tIconFileStr = "comp-icons-blank"; break;
				}; tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
				tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
				
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
				
				tLabel.frame = CGRectMake(tIconWPadding, 0, self.modalView.view.frame.width * 0.4, 45);
				
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
		let settingsLabelPointer:UILabel = getElementFromTable("alarmRepeatSetting") as! UILabel;
		settingsLabelPointer.text = AlarmManager.fetchRepeatLabel(repeatInfo, loadType: 0);
	}
	
	//clear all components
	internal func clearComponents() {
		(self.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = NSDate(); //date to current
		(self.getElementFromTable("alarmName") as! UITextField).text = ""; //empty alarm name
		(self.getElementFromTable("alarmMemo") as! UITextField).text = ""; //empty alarm memo
		self.setSoundElement(SoundManager.list[0]); //default - first element of soundlist
		self.setGameElement(-1); //set default to random
		
		gameSelectedID = -1; //clear selected game id
		self.resetAlarmRepeatCell();
		
		modalView.title = Languages.$("alarmSettings"); //Modal title set to alarmsettings
		
		isAlarmEditMode = false; //AddMode
		alarmDefaultStatus = true; //default on
		editingAlarmID = -1;
		confirmed = false;
		
		alarmCurrentSoundLevel = 80; //default size
		
		self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
	}
	
	//components fill for modify alarm
	internal func fillComponentsWithEditMode( alarmID:Int, alarmName:String, alarmMemo:String, alarmFireDate:NSDate, selectedGameID:Int, scaledSoundLevel:Int, selectedSoundFileName:String, repeatInfo:Array<Bool>, alarmDefaultToggle:Bool) {
		//set alarm name
		(self.getElementFromTable("alarmName") as! UITextField).text = alarmName;
		(self.getElementFromTable("alarmMemo") as! UITextField).text = alarmMemo;
		(self.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = alarmFireDate; //uipicker
		self.setSoundElement(SoundManager.findSoundObjectWithFileName(selectedSoundFileName)!); //set sound
		self.setGameElement(selectedGameID); //set game
		self.resetAlarmRepeatCell();
		
		//set alarm repeat element
		autoSelectRepeatElement( repeatInfo );
		currentRepeatMode = repeatInfo;
		
		//alarmRepeatSelectListView.setSelectedCell( currentRepeatMode );
		
		gameSelectedID = selectedGameID;
		confirmed = false;
		
		modalView.title = Languages.$("alarmEditTitle"); //Modal title set to alarmedit
		
		isAlarmEditMode = true; //EditMode
		alarmDefaultStatus = alarmDefaultToggle; //Default toggle status
		editingAlarmID = alarmID;
		
		alarmCurrentSoundLevel = scaledSoundLevel;
		//scaledSoundLevel
		
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