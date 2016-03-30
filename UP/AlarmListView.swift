//
//  AlarmListView.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
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
	
    //Table for menu
    internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Plain);
    var tablesArray:Array<AnyObject> = [];
	var alarmsCell:Array<AlarmListCell> = [];
	
	//Alarm-add view
	var modalAlarmAddView:AddAlarmView = GlobalSubView.alarmAddView;
	
	//List delete confirm alert
	var listConfirmAction:AnyObject?; //Fallback of iOS7
	var alarmTargetID:Int = 0; //target del id(tmp)
	var alarmTargetIndexPath:NSIndexPath?; // = NSIndexPath(); //to delete animation/optimization
	
	//Background for iOS7 fallback
	//var modalBackground:UIImageView?; var modalBackgroundBlackCover:UIView?;
	internal var modalAddViewCalled:Bool = false;
	
	//위쪽에서 내려오는 알람 메시지를 위한 뷰
	var upAlarmMessageView:UIView = UIView(); var upAlarmMessageText:UILabel = UILabel();
	
    override func viewDidLoad() {
        super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		AlarmListView.selfView = self;
		
        //ModalView
        modalView.view.backgroundColor = UIColor.whiteColor();
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#6C798C");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("alarmList");
		
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(AlarmListView.viewCloseAction));
		modalView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(AlarmListView.alarmAddAction));
		
		modalView.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor();
		modalView.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor();
		self.view.addSubview(navigationCtrl.view);
		
		
        //add table to modal
        tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
		tableView.separatorStyle = .None;
		
        modalView.view.addSubview(tableView);
        
        //add alarm-list
		//todo- 이 리스트가 새로고침되어 다시 만들어질 수 있도록 유연하게 만들 필요가 있음
		createTableList();
		
        tableView.delegate = self; tableView.dataSource = self;
        tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
		//tableView.setEditing(true, animated: true);
		//alertaction
		//if #available(iOS 8.2, *) { //ios8.2 or above only..!!
		
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
		listConfirmAction!.addAction(cancelAct);
		listConfirmAction!.addAction(deleteSureAct);
			
			//let cellSelectRec:
			
		/*} else { //ios7 or older uses actionsheet
			listConfirmAction = UIActionSheet(title: Languages.$("alarmDeleteSure"), delegate: self, cancelButtonTitle: Languages.$("generalCancel"), destructiveButtonTitle: Languages.$("alarmDelete"));
			//list long press action for iOS7
			let longPressRec:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(AlarmListView.tableCellLongPressAction(_:)));
			longPressRec.allowableMovement = 15; longPressRec.minimumPressDuration = 0.8;
			self.tableView.addGestureRecognizer(longPressRec);
		}*/
		
		AlarmListView.alarmListInited = true;
		
		//Upside message initial
		upAlarmMessageView.backgroundColor = UIColor.whiteColor(); //color initial
		upAlarmMessageText.textColor = UIColor.blackColor();
		
		upAlarmMessageText.text = "";
		upAlarmMessageText.textAlignment = .Center;
		upAlarmMessageView.frame = CGRectMake(0, 0, DeviceGeneral.scrSize!.width, 48);
		upAlarmMessageText.frame = CGRectMake(0, 12, DeviceGeneral.scrSize!.width, 24);
		upAlarmMessageText.font = UIFont.systemFontOfSize(16);
		upAlarmMessageView.addSubview(upAlarmMessageText);
		
		self.view.addSubview( upAlarmMessageView );
		upAlarmMessageView.hidden = true;
		///// upside message inital
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		//self.view.autoresizingMask = .None;
		
		FitModalLocationToCenter();
    }
	
	func deleteAlarmConfirm() {
		//알람 삭제 통합 function
		
		print("del start of", self.alarmTargetID);
		AlarmManager.removeAlarm(self.alarmTargetID);
		//Update table with animation
		self.alarmsCell.removeAtIndex(self.alarmTargetIndexPath!.row); self.tablesArray = [self.alarmsCell];
		self.tableView.deleteRowsAtIndexPaths([self.alarmTargetIndexPath!], withRowAnimation: UITableViewRowAnimation.Top);
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
	
	//iOS7 longpress-del handler
	func tableCellLongPressAction(sender:UILongPressGestureRecognizer) {
		let point: CGPoint = sender.locationInView(tableView);
		let indexPath = tableView.indexPathForRowAtPoint(point);
		
		if let indexPath = indexPath {
			if sender.state == UIGestureRecognizerState.Began {
				let cell:AlarmListCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmListCell;
				print("Cell long pressed:", cell.alarmID);
				alarmTargetID = cell.alarmID;
				alarmTargetIndexPath = indexPath;
				
				if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
					//패드일 땐 그냥 alert로 띄움
					showAlarmDelAlert();
				} else {
					(listConfirmAction as! UIActionSheet).showInView(self.view);
				}
				
			}
		}
		
	}
	
	// iOS7 Background fallback
	override func viewDidAppear(animated: Bool) {
		
	} // iOS7 Background fallback end
	
	//table list create method
	internal func createTableList() {
		for i:Int in 0..<alarmsCell.count {
			alarmsCell[i].removeFromSuperview();
		}
		alarmsCell.removeAll();
		
		var tmpComponentPointer:NSDateComponents;
		for i:Int in 0 ..< AlarmManager.alarmsArray.count {
			tmpComponentPointer = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: AlarmManager.alarmsArray[i].alarmFireDate);
			print("Alarm adding:", AlarmManager.alarmsArray[i].alarmID, AlarmManager.alarmsArray[i].alarmToggle, "repeat", AlarmManager.alarmsArray[i].alarmRepeat);
			alarmsCell += [
				createAlarmList(AlarmManager.alarmsArray[i].alarmName,
					defaultState: AlarmManager.alarmsArray[i].alarmToggle,
					timeHour: tmpComponentPointer.hour,
					timeMin: tmpComponentPointer.minute,
					selectedGame: AlarmManager.alarmsArray[i].gameSelected,
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
		
		self.presentViewController(modalAlarmAddView, animated: true, completion: nil);
		
		print("Modifing", targetAlarm.alarmName, targetAlarm.alarmID);
		modalAlarmAddView.fillComponentsWithEditMode(cell.alarmID,
			alarmName: targetAlarm.alarmName,
			alarmFireDate: targetAlarm.alarmFireDate,
			selectedGameID: targetAlarm.gameSelected,
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
	
	/*
	@available(iOS 8.0, *)
	
	
	@available(iOS 8.0, *)
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}*/
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
	}
	
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
				self.presentViewController(self.listConfirmAction as! UIAlertController, animated: true, completion: nil); //show menu
			} //end chk phone or not
			
		} //end if
		
		return [deleteRow];
	}
    
    ////////////////
    
	func setupModalView(frame:CGRect) {
		modalView.view.frame = frame;
	}
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame.origin.x = DeviceGeneral.defaultModalSizeRect.minX;
		navigationCtrl.view.frame.origin.y = DeviceGeneral.defaultModalSizeRect.minY;
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
		self.presentViewController(modalAlarmAddView, animated: true, completion: nil);
		modalAlarmAddView.clearComponents();
		
    }
    
    func viewCloseAction() {
        //Close this view
		modalAddViewCalled = false;
		ViewController.viewSelf!.showHideBlurview(false);
        self.dismissViewControllerAnimated(true, completion: nil);
    }
	
	//Switch changed-event
	func alarmSwitchChangedEventHandler(targetElement:UIAlarmIDSwitch) {
		AlarmManager.toggleAlarm(targetElement.elementID, alarmStatus: targetElement.on, isListOn: true);
		
		//리스트 갱신
		for i:Int in 0 ..< alarmsCell.count {
			if (alarmsCell[i].alarmID == targetElement.elementID) {
				let bgFileName:String = getBackgroundFileNameFromTime(alarmsCell[i].timeHour);
				let bgFileState:String = targetElement.on == true ? "on" : "off";
				let fileUsesSmallPrefix:String = DeviceGeneral.usesLowQualityImage == true ? "_small" : "";
				alarmsCell[i].backgroundImage!.image = UIImage(named: bgFileName + "_time_" + bgFileState + fileUsesSmallPrefix + ".png");
				
				alarmsCell[i].alarmName!.textColor = (bgFileName == "a" || bgFileName == "b") ?
					(targetElement.on ? UIColor.blackColor() : UIColor.whiteColor()) : (targetElement.on ? UIColor.whiteColor() : UIColor.blackColor());
				alarmsCell[i].timeText!.textColor = alarmsCell[i].alarmName!.textColor;
				
				break;
			}
		} //end for
	}
	
	//get str from time
	func getBackgroundFileNameFromTime(timeHour:Int)->String {
		if (timeHour >= 0 && timeHour < 6) {
			return "d";
		} else if (timeHour >= 6 && timeHour < 12) {
			return "a";
		} else if (timeHour >= 12 && timeHour < 18) {
			return "b";
		} else if (timeHour >= 18 && timeHour <= 23) {
			return "c";
		}
		return "a";
	}
	
	//Tableview cell view create
	func createAlarmList(name:String, defaultState:Bool, timeHour:Int, timeMin:Int, selectedGame:Int, uuid:Int ) -> AlarmListCell {
		//TODO-func 16.1.31 PM 11:50
		let tCell:AlarmListCell = AlarmListCell();
		let tLabel:UILabel = UILabel(); let tLabelTime:UILabel = UILabel();
		let tSwitch:UIAlarmIDSwitch = UIAlarmIDSwitch();
		let tGameImage:UIImageView = UIImageView(); let tGameImageBackground:UIImageView = UIImageView();
		let tTimeBackground:UIImageView = UIImageView();
		
		tCell.alarmID = uuid;
		tCell.timeHour = timeHour; tCell.timeMinute = timeMin;
		tSwitch.elementID = uuid;
		
		let tTimeImgName:String = defaultState == true ? "on" : "off";
		let bgFileName:String = getBackgroundFileNameFromTime(timeHour);
		let fileUsesSmallPrefix:String = DeviceGeneral.usesLowQualityImage == true ? "_small" : "";
		tTimeBackground.image = UIImage(named: bgFileName + "_time_" + tTimeImgName + fileUsesSmallPrefix + ".png");
		
		tLabel.frame = CGRectMake((self.modalView.view.frame.width * 0.5) * 0.55, 0, self.modalView.view.frame.width * 0.45, 40); //알람 이름
		tLabelTime.frame = CGRectMake((self.modalView.view.frame.width * 0.5) * 0.45, 20, self.modalView.view.frame.width * 0.55, 72); //현재 시간
		tLabel.textAlignment = .Center; tLabelTime.textAlignment = .Center;
		
		//On일때 흰색 폰트로
		tLabel.textColor = (bgFileName == "a" || bgFileName == "b") ?
			(defaultState ? UIColor.blackColor() : UIColor.whiteColor()) : (defaultState ? UIColor.whiteColor() : UIColor.blackColor());
		tLabelTime.textColor = tLabel.textColor;
		
		
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 80 );
		tCell.backgroundColor = UIColor.whiteColor();
		
		tTimeBackground.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 80);
		tCell.addSubview(tTimeBackground);
		
		tSwitch.frame.origin.x = self.modalView.view.frame.width - tSwitch.frame.width - CGFloat(10);
		tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
		tSwitch.on = defaultState;
		
		tCell.addSubview(tLabel); tCell.addSubview(tLabelTime);
		tCell.addSubview(tSwitch);
		
		tLabel.text = name; tLabel.font = UIFont.systemFontOfSize(17);
		
		//이미지는 게임마다 따로분류
		tGameImageBackground.image = UIImage(named: "game-thumb-background.png");
		switch(selectedGame) {
			case -1:
				tGameImage.image = UIImage(named: "game-thumb-random.png");
				break;
			case 0:
				tGameImage.image = UIImage(named: "game-thumb-jumpup.png");
				break;
			default:
				tGameImage.image = UIImage(named: "game-thumb-sample.png");
				break;
		}
		tGameImage.frame = CGRectMake(12, 12, 56, 56);
		tGameImageBackground.frame = tGameImage.frame;
		
		tCell.addSubview(tGameImageBackground); tCell.addSubview(tGameImage);
		
		//시간은 별도의 글씨체(ios내장)를 사용함
		/*var timeHourStr:String = String(timeHour);
		if (timeHourStr.characters.count == 1) {
			timeHourStr = "0" + timeHourStr;
		}*/
		var timeMinStr:String = String(timeMin);
		if (timeMinStr.characters.count == 1) {
			timeMinStr = "0" + timeMinStr;
		}
		
		let timeStr:String = String(timeHour) + ":" + timeMinStr;
		tLabelTime.text = timeStr;
		
		if #available(iOS 9.0, *) {
			tLabelTime.font = UIFont.systemFontOfSize(44, weight: UIFontWeightThin); //iOS9 uses San fransisco font
			tLabelTime.frame = CGRectMake((self.modalView.view.frame.width * 0.5) * 0.45, 20, self.modalView.view.frame.width * 0.55, 66.5);
		} else {
			tLabelTime.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 44);
		}
		//NanumBarunGothicUltraLight
		//tLabelTime.font =   UIFont(name: "NanumBarunGothic", size: 44);
		//tCell.selectionStyle = UITableViewCellSelectionStyle.None;
		//NSLog("Available fonts: %@", UIFont.familyNames());
		
		//스위치 변경 이벤트
		tSwitch.addTarget(self, action: #selector(AlarmListView.alarmSwitchChangedEventHandler(_:)), forControlEvents: UIControlEvents.ValueChanged);
		
		tCell.backgroundImage = tTimeBackground;
		tCell.alarmName = tLabel;
		tCell.timeText = tLabelTime;
		
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