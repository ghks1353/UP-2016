//
//  AlarmListView.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 Project UP. All rights reserved.
//


import Foundation
import UIKit

class AlarmListView:UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate {
	
	//for access
	static var selfView:AlarmListView?;
	static var alarmListInited:Bool = false;
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
	//Alarm guide label and image
	var alarmAddGuideImageView:UIImageView = UIImageView();
	var alarmAddGuideText:UILabel = UILabel();
	var alarmAddIfEmptyButton:UIButton = UIButton();
	
    //Table for menu
    internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Plain);
    var tablesArray:Array<AnyObject> = [];
	var alarmsCell:Array<AlarmListCell> = [];
	
	//Alarm-add view
	var modalAlarmAddView:AddAlarmView = GlobalSubView.alarmAddView;
	
	//List delete confirm alert
	var listConfirmAction:UIAlertController = UIAlertController();
	var alarmTargetID:Int = 0; //target del id(tmp)
	var alarmTargetIndexPath:NSIndexPath?; // = NSIndexPath(); //to delete animation/optimization
	
	internal var modalAddViewCalled:Bool = false;
	
	//위쪽에서 내려오는 알람 메시지를 위한 뷰
	var upAlarmMessageView:UIView = UIView(); var upAlarmMessageText:UILabel = UILabel();
	
    override func viewDidLoad() {
        super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		AlarmListView.selfView = self;
		
        //ModalView
        modalView.view.backgroundColor = UIColor.whiteColor();
		modalView.view.frame = DeviceManager.defaultModalSizeRect;
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#535B66");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("alarmList");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(AlarmListView.viewCloseAction), forControlEvents: .TouchUpInside);
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		
		//add right items
		let navRightPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navRightPadding.width = -12; //Button right padding
		let navFuncButton:UIButton = UIButton(); //Add image into UIButton
		navFuncButton.setImage( UIImage(named: "modal-add"), forState: .Normal);
		navFuncButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navFuncButton.addTarget(self, action: #selector(AlarmListView.alarmAddAction), forControlEvents: .TouchUpInside);
		modalView.navigationItem.rightBarButtonItems = [ navRightPadding, UIBarButtonItem(customView: navFuncButton) ];
		///////// Nav items fin
		
		//Add Ctrl vw
		self.view.addSubview(navigationCtrl.view);
		
		//add table to modal
        tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
		tableView.separatorStyle = .None;
        modalView.view.addSubview(tableView);
		
		//알람이 없을 경우 나타나는 메시지에 대한 뷰
		alarmAddGuideImageView = UIImageView( image: UIImage( named: "comp-alarm-notfound.png" ) );
		alarmAddGuideImageView.frame = CGRectMake(
			modalView.view.frame.width / 2 - (102.7 / 2) /* 착시 fix */ + (3.5),
			modalView.view.frame.height / 2 - 48,
			102.7, 59.6
		);
		modalView.view.addSubview(alarmAddGuideImageView);
		
		//텍스트
		alarmAddGuideText.textColor = UIColor.grayColor();
		alarmAddGuideText.textAlignment = .Center;
		alarmAddGuideText.frame = CGRectMake(
			0, modalView.view.frame.height / 2 + 18,
			modalView.view.frame.width, 24
		);
		alarmAddGuideText.font = UIFont.systemFontOfSize(18);
		alarmAddGuideText.text = Languages.$("alarmListEmpty");
		modalView.view.addSubview(alarmAddGuideText);
		
		//추가 버튼
		alarmAddIfEmptyButton = UIButton();
		alarmAddIfEmptyButton.titleLabel!.font = UIFont.systemFontOfSize(14);
		alarmAddIfEmptyButton.setTitleColor(UPUtils.colorWithHexString("#BBBBBB"), forState: .Normal);
		alarmAddIfEmptyButton.setTitle(Languages.$("alarmListAddWhenEmpty"), forState: .Normal);
		alarmAddIfEmptyButton.frame = CGRectMake(
			modalView.view.frame.width / 2 - (80 / 2),
			modalView.view.frame.height / 2 + 64,
			80, 28
		);
		alarmAddIfEmptyButton.backgroundColor = UIColor.clearColor();
		alarmAddIfEmptyButton.layer.borderWidth = 1;
		alarmAddIfEmptyButton.layer.borderColor = UPUtils.colorWithHexString("#BBBBBB").CGColor;
		modalView.view.addSubview(alarmAddIfEmptyButton);
		
		alarmAddIfEmptyButton.addTarget(self, action: #selector(AlarmListView.alarmAddAction), forControlEvents: .TouchUpInside);
		/////////////////////
		
        //add alarm-list
		createTableList();
		
        tableView.delegate = self; tableView.dataSource = self;
        tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
		
		//Document상에서는 iOS 8부터임
		listConfirmAction = UIAlertController(title: Languages.$("alarmDeleteTitle"), message: Languages.$("alarmDeleteSure"), preferredStyle: .ActionSheet);
		//add menus
		let cancelAct:UIAlertAction = UIAlertAction(title: Languages.$("generalCancel"), style: .Cancel) { action -> Void in
			//Cancel just dismiss it
		};
		let deleteSureAct:UIAlertAction = UIAlertAction(title: Languages.$("alarmDelete"), style: .Destructive) { action -> Void in
			//delete it
			self.deleteAlarmConfirm();
			
		};
		listConfirmAction.addAction(cancelAct);
		listConfirmAction.addAction(deleteSureAct);
		
		AlarmListView.alarmListInited = true;
		
		///////
		//Upside message initial
		upAlarmMessageView.backgroundColor = UIColor.whiteColor(); //color initial
		upAlarmMessageText.textColor = UIColor.blackColor();
		
		upAlarmMessageText.text = "";
		upAlarmMessageText.textAlignment = .Center;
		upAlarmMessageView.frame = CGRectMake(0, 0, DeviceManager.scrSize!.width, 48);
		upAlarmMessageText.frame = CGRectMake(0, 12, DeviceManager.scrSize!.width, 24);
		upAlarmMessageText.font = UIFont.systemFontOfSize(16);
		upAlarmMessageView.addSubview(upAlarmMessageText);
		
		self.view.addSubview( upAlarmMessageView );
		upAlarmMessageView.hidden = true;
		///// upside message inital
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"));
		modalMaskImageView.frame = modalView.view.frame;
		modalMaskImageView.contentMode = .ScaleAspectFit; self.view.maskView = modalMaskImageView;
		
		FitModalLocationToCenter();
    }
	
	func deleteAlarmConfirm() {
		//알람 삭제 통합 function
		
		print("del start of", self.alarmTargetID);
		AlarmManager.removeAlarm(self.alarmTargetID);
		//Update table with animation
		self.alarmsCell.removeAtIndex(self.alarmTargetIndexPath!.row); self.tablesArray = [self.alarmsCell];
		self.tableView.deleteRowsAtIndexPaths([self.alarmTargetIndexPath!], withRowAnimation: UITableViewRowAnimation.Top);
		
		//chk alarm make available
		checkAlarmLimitExceed();
		checkAlarmIsEmpty(); //and check is empty
	}
	
	//iPad Alarm Delete Question
	func showAlarmDelAlert() {
		let alarmDelAlertController = UIAlertController(title: Languages.$("alarmDelete"), message: Languages.$("alarmDeleteSure"), preferredStyle: UIAlertControllerStyle.Alert);
		alarmDelAlertController.addAction(UIAlertAction(title: Languages.$("generalOK"), style: .Default, handler: { (action: UIAlertAction!) in
			//Alarm delete
			self.deleteAlarmConfirm();
		}));
		
		alarmDelAlertController.addAction(UIAlertAction(title: Languages.$("generalCancel"), style: .Default, handler: { (action: UIAlertAction!) in
			//Cancel
		}));
		presentViewController(alarmDelAlertController, animated: true, completion: nil);
		
	} //end function
	
	//iOS7 & iPad Alert fallback
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		if (buttonIndex == alertView.cancelButtonIndex) { //cancel
			print("ios7 fallback - alarm del canceled");
		} else { //ok confirm
			self.deleteAlarmConfirm();
		}
	}
	
	//iOS7 actionsheet handler
	func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
		print("actionidx", buttonIndex);
		switch(buttonIndex){
			case 0:
				//Alarm delete
				deleteAlarmConfirm();
				
				break;
			default: break;
		}
	}
	
	/////// View transition animation
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_ALARMLIST);
		
		//Check alarm limit and disable/enable button
		checkAlarmLimitExceed();
		checkAlarmIsEmpty();
	}
	
	override func viewWillDisappear(animated: Bool) {
		AnalyticsManager.untrackScreen(); //untrack to previous screen
	}
	
	override func viewDidAppear(animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRectMake(0, DeviceManager.scrSize!.height,
		                             DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.view.frame = CGRectMake(0, 0,
				DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	//table list create method
	internal func createTableList() {
		for i:Int in 0..<alarmsCell.count {
			alarmsCell[i].removeFromSuperview();
		}
		alarmsCell.removeAll();
		
		var tmpComponentPointer:NSDateComponents;
		for i:Int in 0 ..< AlarmManager.alarmsArray.count {
			tmpComponentPointer = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: AlarmManager.alarmsArray[i].alarmFireDate);
			print("Alarm adding:", AlarmManager.alarmsArray[i].alarmID,
			     ( AlarmManager.alarmsArray[i].alarmFireDate as NSDate).timeIntervalSince1970 ,
			      AlarmManager.alarmsArray[i].alarmToggle, "repeat", AlarmManager.alarmsArray[i].alarmRepeat);
			alarmsCell += [
				createAlarmList(AlarmManager.alarmsArray[i].alarmName,
					alarmMemo: AlarmManager.alarmsArray[i].alarmMemo,
					defaultState: AlarmManager.alarmsArray[i].alarmToggle,
					funcTimeHour: tmpComponentPointer.hour,
					funcTimeMin: tmpComponentPointer.minute,
					selectedGame: AlarmManager.alarmsArray[i].gameSelected,
					repeatSettings: AlarmManager.alarmsArray[i].alarmRepeat,
					uuid: AlarmManager.alarmsArray[i].alarmID)
			];
		}
		tablesArray.removeAll();
		tablesArray = [
			/*section 1*/
			alarmsCell
		];
		
		tableView.reloadData();
		tableView.reloadInputViews();
		tableView.delegate = self; tableView.dataSource = self;
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		self.view.autoresizingMask = .None;
		
	}
	
	
    /// table setup
	
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
			default:
				return "";
        }
    }
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell:AlarmListCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmListCell;
		//Show alarm edit view
		
		modalAlarmAddView.showBlur = false;
		modalAlarmAddView.modalPresentationStyle = .OverFullScreen;
		
		//find alarm object from array
		let targetAlarm:AlarmElements = AlarmManager.getAlarm(cell.alarmID)!;
		
		self.presentViewController(modalAlarmAddView, animated: false, completion: nil);
		
		print("Modifing", targetAlarm.alarmName, targetAlarm.alarmID);
		modalAlarmAddView.fillComponentsWithEditMode(cell.alarmID,
			alarmName: targetAlarm.alarmName,
			alarmMemo: targetAlarm.alarmMemo,
			alarmFireDate: targetAlarm.alarmFireDate,
			selectedGameID: targetAlarm.gameSelected,
			scaledSoundLevel: targetAlarm.alarmSoundLevel,
			selectedSoundFileName: targetAlarm.alarmSound,
			repeatInfo: targetAlarm.alarmRepeat,
			alarmDefaultToggle: targetAlarm.alarmToggle);
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);

		
	}
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tablesArray[section] as! Array<AnyObject>).count;
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 80; //UITableViewAutomaticDimension;
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
        return cell;
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0;
    }
	
	//Fallback function. DO NOT REMOVE
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	} //end func
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		//get row
		//let cell:AlarmListCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmListCell;
		
		let deleteRow:UITableViewRowAction = UITableViewRowAction(style: .Default, title: Languages.$("alarmDelete")) {
			(action:UITableViewRowAction!, childIndexPath:NSIndexPath!) -> Void in
			
			let cell:AlarmListCell = tableView.cellForRowAtIndexPath(childIndexPath) as! AlarmListCell;
			print("cell delete alarm", cell.alarmID);
			self.alarmTargetID = cell.alarmID;
			self.alarmTargetIndexPath = childIndexPath;
			
			if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
				//패드일 땐 그냥 alert로 띄움
				self.showAlarmDelAlert();
			} else {
				//폰일 때
				self.presentViewController(self.listConfirmAction, animated: true, completion: nil); //show menu
			} //end chk phone or not
			
		} //end if
		
		return [deleteRow];
	}
    
    ////////////////
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect;
		
		if (self.view.maskView != nil) {
			self.view.maskView!.frame = DeviceManager.defaultModalSizeRect;
		}
		
		//알람 텍스트 및 배경의 조절
		upAlarmMessageText.textAlignment = .Center;
		upAlarmMessageView.frame = CGRectMake(0, 0, DeviceManager.scrSize!.width, 48);
		upAlarmMessageText.frame = CGRectMake(0, 12, DeviceManager.scrSize!.width, 24);
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alarmAddAction() {
        //Show alarm-add view
		//뷰는 단 하나의 추가 뷰만 present가 가능한 관계로..
		modalAlarmAddView.showBlur = false;
		modalAlarmAddView.modalPresentationStyle = .OverFullScreen;
		
		modalAlarmAddView.FitModalLocationToCenter();
		self.presentViewController(modalAlarmAddView, animated: false, completion: nil);
		modalAlarmAddView.clearComponents();
		
    }
    
    func viewCloseAction() {
        //Close this view
		if (upAlarmMessageView.hidden == false) {
			//가리면서 사라지게
			self.upAlarmMessageView.alpha = 1;
			UIView.animateWithDuration(0.12, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
				self.upAlarmMessageView.alpha = 0;
				}, completion: {_ in
			});
		}
		
		modalAddViewCalled = false;
		ViewController.viewSelf!.showHideBlurview(false);
        self.dismissViewControllerAnimated(true, completion: nil);
    } //end func
	
	func checkAlarmLimitExceed() {
		//informationAlarmExceed
		if ( AlarmManager.alarmsArray.count >= AlarmManager.alarmMaxRegisterCount ) {
			print("Alarm over", AlarmManager.alarmMaxRegisterCount, "(current ", AlarmManager.alarmsArray.count ,")");
			modalView.navigationItem.rightBarButtonItem!.enabled = false;
		} else {
			modalView.navigationItem.rightBarButtonItem!.enabled = true;
		}
		
	} //end chk limit func
	
	func checkAlarmIsEmpty() {
		//알람이 비어있는 경우 비어있으니 추가해달라는 메시지 표시.
		if ( AlarmManager.alarmsArray.count == 0 ) {
			//뷰 표시
			alarmAddGuideText.hidden = false;
			alarmAddGuideImageView.hidden = false;
			alarmAddIfEmptyButton.hidden = false;
		} else {
			//메시지 삭제
			alarmAddGuideText.hidden = true;
			alarmAddGuideImageView.hidden = true;
			alarmAddIfEmptyButton.hidden = true;
		}
		
		
	} //end func
	
	//Switch changed-event
	func alarmSwitchChangedEventHandler(targetElement:UIAlarmIDSwitch) {
		AlarmManager.toggleAlarm(targetElement.elementID, alarmStatus: targetElement.on, isListOn: true);
		var statusChanged:Bool = false;
		
		//리스트 갱신
		var tImage:String = ""; var targetCell:AlarmListCell?;
		for i:Int in 0 ..< alarmsCell.count {
			if (alarmsCell[i].alarmID == targetElement.elementID) {
				targetCell = alarmsCell[i];
				
				if ( alarmsCell[i].alarmToggled != targetElement.on) {
					statusChanged = true;
				}
				alarmsCell[i].alarmToggled = targetElement.on; // on = true / off = false
				
				let bgFileName:String = getBackgroundFileNameFromTime(alarmsCell[i].timeHour);
				let bgFileState:String = (targetElement.on == true ? "on" : "off") + (UIDevice.currentDevice().userInterfaceIdiom == .Pad ? "-pad" : "");
				let fileUsesSmallPrefix:String = DeviceManager.usesLowQualityImage == true ? "-small" : "";
				tImage = bgFileName + "-time-" + bgFileState + fileUsesSmallPrefix + ".png";
				//alarmsCell[i].backgroundImage!.image = UIImage(named: bgFileName + "_time_" + bgFileState + fileUsesSmallPrefix + ".png");
				
				//alarmsCell[i].alarmName!.textColor = alarmsCell[i].alarmToggled ? UIColor.whiteColor() : UIColor.blackColor();
				alarmsCell[i].alarmName!.alpha = targetElement.on ? 1 : 0.8;
				alarmsCell[i].timeText!.alpha = alarmsCell[i].alarmName!.alpha;
				alarmsCell[i].timeAMPM!.alpha = alarmsCell[i].alarmName!.alpha;
				alarmsCell[i].timeRepeat!.alpha = alarmsCell[i].alarmName!.alpha;
				
				alarmsCell[i].alarmName!.textColor = targetElement.on ? UIColor.whiteColor() : UPUtils.colorWithHexString("#878787");
				alarmsCell[i].timeText!.textColor = alarmsCell[i].alarmName!.textColor;
				alarmsCell[i].timeAMPM!.textColor = alarmsCell[i].alarmName!.textColor;
				alarmsCell[i].timeRepeat!.textColor = alarmsCell[i].alarmName!.textColor;
				break;
			}
		} //end for
		
		//리스트 타임 변경 애니메이션
		if (statusChanged == true) {
			var tChangeBG:UIImageView? = UIImageView( image: targetCell!.backgroundImage!.image );
			tChangeBG!.frame = targetCell!.backgroundImage!.frame;
			tChangeBG!.contentMode = .ScaleAspectFill;
			targetCell!.addSubview(tChangeBG!); targetCell!.sendSubviewToBack(tChangeBG!);
			targetCell!.backgroundImage!.frame = CGRectMake(0, 80 /* 초기값 위로 */, self.modalView.view.frame.width, 80);
			targetCell!.backgroundImage!.image = UIImage( named: tImage ); //new img
			//구조: 애니메이션용 프레임이 기존 위치에서 위로 올라감, 기존 프레임이 아래에서 올라옴
			
			UIView.animateWithDuration(0.56, delay: 0,
									   usingSpringWithDamping: 1, initialSpringVelocity: 1,
									   options: .CurveEaseIn, animations: {
				tChangeBG!.frame = CGRectMake(0, -80 /* 아래로 */, self.modalView.view.frame.width, 80);
				targetCell!.backgroundImage!.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 80);
										
				
			}) { _ in
				//완료 시 변경용 뷰 삭제
				tChangeBG!.removeFromSuperview();
				tChangeBG!.image = nil; //GC
				tChangeBG = nil; //gc
			}
		}
		
	}
	
	//get str from time
	func getBackgroundFileNameFromTime(timeHour:Int)->String {
		if (timeHour >= 22 || timeHour < 6) {
			return "d";
		} else if (timeHour >= 6 && timeHour < 11) {
			return "a";
		} else if (timeHour >= 11 && timeHour < 18) {
			return "b";
		} else if (timeHour >= 18 && timeHour <= 21) {
			return "c";
		}
		return "a";
	}
	
	//Tableview cell view create
	func createAlarmList(name:String, alarmMemo:String, defaultState:Bool, funcTimeHour:Int, funcTimeMin:Int, selectedGame:Int, repeatSettings:Array<Bool>, uuid:Int ) -> AlarmListCell {
		var timeHour:Int = funcTimeHour;
		let timeMin:Int = funcTimeMin;
		
		let tCell:AlarmListCell = AlarmListCell();
		let tLabel:UILabel = UILabel(); let tLabelTime:UILabel = UILabel();
		let tTimeBackground:UIImageView = UIImageView();
		
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 80 );
		tCell.backgroundColor = UIColor.whiteColor();
		tTimeBackground.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 80);
		tCell.addSubview(tTimeBackground);
		
		//온오프 시 애니메이션 효과를 주기 위해 마스크를 씌울거임.
		let maskLayer:CAShapeLayer = CAShapeLayer();
		let maskRect:CGRect = CGRectMake(0, 0, self.modalView.view.frame.width * 2, 80 ); //삭제버튼까지 나와야하므로 마스크 2배
		let path:CGPathRef = CGPathCreateWithRect(maskRect, nil);
		maskLayer.path = path;
		tCell.layer.mask = maskLayer;
		
		let tSwitch:UIAlarmIDSwitch = UIAlarmIDSwitch();
		//let tGameImage:UIButton = UIButton(); let tGameImageBackground:UIImageView = UIImageView();
		let tAMPMLabel:UILabel = UILabel(); let tRepeatLabel:UILabel = UILabel();
		
		tCell.alarmID = uuid; tCell.timeHour = timeHour; tCell.timeMinute = timeMin;
		tCell.alarmToggled = defaultState;
		tSwitch.elementID = uuid;
		
		let tTimeImgName:String = (defaultState == true ? "on" : "off") + (UIDevice.currentDevice().userInterfaceIdiom == .Pad ? "-pad" : "");
		print("lis timgname is => " + tTimeImgName);
		let bgFileName:String = getBackgroundFileNameFromTime(timeHour);
		let fileUsesSmallPrefix:String = DeviceManager.usesLowQualityImage == true ? "-small" : "";
		tTimeBackground.image = UIImage(named: bgFileName + "-time-" + tTimeImgName + fileUsesSmallPrefix + ".png");
		tTimeBackground.contentMode = .ScaleAspectFill;
		
		tLabel.frame = CGRectMake(15, 50, self.modalView.view.frame.width * 0.7, 24); //알람 이름
		tLabelTime.frame = CGRectMake(12, 4, 0, 0); //현재 시간
		tLabel.textAlignment = .Left;
		
		if (DeviceManager.is24HourMode == false) {
			//오전 오후 모드면
			timeHour = timeHour > 12 ? timeHour - 12 : (timeHour == 0 ? 12 : timeHour);
			tAMPMLabel.hidden = false;
		} else {
			//24시 모드면
			tAMPMLabel.hidden = true;
		}
		
		var timeHourStr:String = String(timeHour);
		if (timeHourStr.characters.count == 1) {
			timeHourStr = "0" + timeHourStr;
		}
		var timeMinStr:String = String(timeMin);
		if (timeMinStr.characters.count == 1) {
			timeMinStr = "0" + timeMinStr;
		}
		let timeStr:String = timeHourStr + ":" + timeMinStr; tLabelTime.text = timeStr;
		
		//12시간제인 경우 오전오후 표기
		tAMPMLabel.text = funcTimeHour >= 12 && funcTimeHour <= 23 ? Languages.$("generalPM") : Languages.$("generalAM");
		//반복설정에 따른 반복표기
		tRepeatLabel.text = AlarmManager.fetchRepeatLabel(repeatSettings, loadType: 1);
		
		tLabelTime.numberOfLines = 0;
		tLabelTime.textAlignment = .Center;
		
		tLabelTime.font = UIFont(name: "SFUIDisplay-Ultralight", size: 41);
		
		tLabelTime.adjustsFontSizeToFitWidth = true;
		tLabelTime.sizeToFit();
		
		tAMPMLabel.frame = CGRectMake(  tLabelTime.frame.width + 16, 8, 60, 24 ); //오전 오후 인디케이터. (12시간만 해당)
		tRepeatLabel.frame = CGRectMake(  tLabelTime.frame.width + 16, 25, 60, 24 ); //반복 인디케이터.
		tAMPMLabel.textAlignment = .Left; tRepeatLabel.textAlignment = .Left;
		
		//알람명 표시.
		tLabel.text = name;
		
		tLabel.font = UIFont.systemFontOfSize(16);
		tAMPMLabel.font = UIFont.boldSystemFontOfSize(15); tRepeatLabel.font = UIFont.systemFontOfSize(15);
		
		//On일때 알파 1
		tLabel.textColor = defaultState ? UIColor.whiteColor() : UPUtils.colorWithHexString("#878787");
		tLabel.alpha = defaultState ? 1 : 0.8; tLabelTime.alpha = tLabel.alpha;
		tAMPMLabel.alpha = tLabel.alpha; tRepeatLabel.alpha = tLabel.alpha;
		
		tLabelTime.textColor = tLabel.textColor; tAMPMLabel.textColor = tLabel.textColor;
		tRepeatLabel.textColor = tLabel.textColor;
		
		
		tSwitch.frame.origin.x = self.modalView.view.frame.width - tSwitch.frame.width - CGFloat(16);
		tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
		tSwitch.on = defaultState; tCell.addSubview(tSwitch);
		
		tCell.addSubview(tLabel); tCell.addSubview(tLabelTime); tCell.addSubview(tAMPMLabel); tCell.addSubview(tRepeatLabel);
		
		//스위치 변경 이벤트
		tSwitch.addTarget(self, action: #selector(AlarmListView.alarmSwitchChangedEventHandler(_:)), forControlEvents: UIControlEvents.ValueChanged);
		
		
		tCell.backgroundImage = tTimeBackground;
		tCell.alarmName = tLabel; tCell.timeText = tLabelTime;
		tCell.timeAMPM = tAMPMLabel; tCell.timeRepeat = tRepeatLabel;
		
		return tCell;
	}
	
	////////////////////////////
	//notify on scr
	func showMessageOnView( message:String, backgroundColorHex:String, textColorHex:String ) {
		if (upAlarmMessageView.hidden == false) {
			//몇초 뒤 나타나게 함.
			UPUtils.setTimeout(2.5, block: {_ in
				self.showMessageOnView( message, backgroundColorHex: backgroundColorHex, textColorHex: textColorHex );
			});
			return;
		}
		
		//이 부분은 메인 뷰 컨트롤러에도 나오게끔 만듬
		ViewController.viewSelf!.showMessageOnView(message, backgroundColorHex: backgroundColorHex, textColorHex: textColorHex);
		
		self.upAlarmMessageView.alpha = 1;
		
		self.view.bringSubviewToFront(upAlarmMessageView);
		upAlarmMessageView.hidden = false;
		upAlarmMessageView.backgroundColor = UPUtils.colorWithHexString(backgroundColorHex);
		upAlarmMessageText.textColor = UPUtils.colorWithHexString(textColorHex)
		upAlarmMessageText.text = message;
		
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade); //statusbar hidden
		self.upAlarmMessageView.frame = CGRectMake(0, -self.upAlarmMessageView.frame.height, self.upAlarmMessageView.frame.width, self.upAlarmMessageView.frame.height);
		
		//Message animation
		UIView.animateWithDuration(0.32, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
			self.upAlarmMessageView.frame = CGRectMake(0, 0, self.upAlarmMessageView.frame.width, self.upAlarmMessageView.frame.height);
			}, completion: {_ in
		});
		
		//animation fin.
		UIView.animateWithDuration(0.32, delay: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
			self.upAlarmMessageView.frame = CGRectMake(0, -self.upAlarmMessageView.frame.height, self.upAlarmMessageView.frame.width, self.upAlarmMessageView.frame.height);
			}, completion: {_ in
				self.upAlarmMessageView.hidden = true;
				UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade);
		});
	} //end func
	
}
