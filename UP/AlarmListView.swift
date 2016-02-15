//
//  AlarmListView.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//


import Foundation
import UIKit

class AlarmListView:UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate {
	
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
	
	//Background for iOS7 fallback
	var modalBackground:UIImageView?; var modalBackgroundBlackCover:UIView?;
	internal var modalAddViewCalled:Bool = false;
	
    override func viewDidLoad() {
        super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		//iOS7 fallback
		if #available(iOS 8.0, *) {
		} else {
			modalBackground = UIImageView(); modalBackgroundBlackCover = UIView();
			modalBackgroundBlackCover!.backgroundColor = UIColor.blackColor();
			modalBackgroundBlackCover!.alpha = 0.7;
			modalBackground!.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height);
			modalBackgroundBlackCover!.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height);
		} //End of iOS7 fallback
		
		
		AlarmListView.selfView = self;
		
        //ModalView
        modalView.view.backgroundColor = UIColor.whiteColor();
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#4D9429");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("alarmList");
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Languages.$("generalClose"), style: .Plain, target: self, action: "viewCloseAction");
		modalView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "alarmAddAction");
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
		
		//alertaction
		if #available(iOS 8.0, *) { //ios8 or above only..!!
			listConfirmAction = UIAlertController(title: Languages.$("alarmDeleteTitle"), message: Languages.$("alarmDeleteSure"), preferredStyle: .ActionSheet);
			//add menus
			let cancelAct:UIAlertAction = UIAlertAction(title: Languages.$("generalCancel"), style: .Cancel) { action -> Void in
				//Cancel just dismiss it
			};
			let deleteSureAct:UIAlertAction = UIAlertAction(title: Languages.$("alarmDelete"), style: .Destructive) { action -> Void in
				//delete it
				print("del start of", self.alarmTargetID);
				AlarmManager.removeAlarm(self.alarmTargetID);
				self.createTableList(); //reload list
			};
			listConfirmAction!.addAction(cancelAct);
			listConfirmAction!.addAction(deleteSureAct);
		} else { //ios7 or older uses actionsheet
			listConfirmAction = UIActionSheet(title: Languages.$("alarmDeleteSure"), delegate: self, cancelButtonTitle: Languages.$("generalCancel"), destructiveButtonTitle: Languages.$("alarmDelete"));
			//list long press action for iOS7
			let longPressRec:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "tableCellLongPressAction:");
			longPressRec.allowableMovement = 15; longPressRec.minimumPressDuration = 0.8;
			self.tableView.addGestureRecognizer(longPressRec);
		}
		
		AlarmListView.alarmListInited = true;
		
    }
	
	//iOS7 actionsheet handler
	func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
		print("actionidx", buttonIndex);
		switch(buttonIndex){
			case 0:
				//Alarm delete
				print("del start of", self.alarmTargetID);
				AlarmManager.removeAlarm(self.alarmTargetID);
				self.createTableList(); //reload list
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
				(listConfirmAction as! UIActionSheet).showInView(self.view);
			}
		}
		
	}
	
	
	// iOS7 Background fallback
	override func viewDidAppear(animated: Bool) {
		if #available(iOS 8.0, *) {
		} else {
			if (modalAddViewCalled == false) {
				modalBackground!.image = ViewController.viewSelf!.viewImage;
				modalBackgroundBlackCover!.removeFromSuperview(); modalBackground!.removeFromSuperview();
				self.view.addSubview(modalBackgroundBlackCover!); self.view.addSubview(modalBackground!);
				self.view.sendSubviewToBack(modalBackgroundBlackCover!); self.view.sendSubviewToBack(modalBackground!);
				modalBackgroundBlackCover!.alpha = 0;
				UIView.animateWithDuration(0.32, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
					self.modalBackgroundBlackCover!.alpha = 0.7;
					}, completion: nil);
			}
		}
	} // iOS7 Background fallback end
	
	//table list create method
	internal func createTableList() {
		for (var i:Int = 0; i < alarmsCell.count; ++i) {
			alarmsCell[i].removeFromSuperview();
		}
		alarmsCell.removeAll();
		
		var tmpComponentPointer:NSDateComponents;
		for (var i:Int = 0; i < AlarmManager.alarmsArray.count; ++i) {
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

	}
	
	func getGeneralModalRect() -> CGRect {
		return CGRectMake(CGFloat(50 * DeviceGeneral.scrRatio) , ((DeviceGeneral.scrSize?.height)! - CGFloat(480 * DeviceGeneral.scrRatio)) / 2 , (DeviceGeneral.scrSize?.width)! - CGFloat(100 * DeviceGeneral.scrRatio), CGFloat(480 * DeviceGeneral.scrRatio));
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
	
	@available(iOS 8.0, *)
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		//get row
		//let cell:AlarmListCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmListCell;
		
		let deleteRow:UITableViewRowAction = UITableViewRowAction(style: .Default, title: Languages.$("alarmDelete")) {
			(action:UITableViewRowAction!, childIndexPath:NSIndexPath!) -> Void in
			
			let cell:AlarmListCell = tableView.cellForRowAtIndexPath(childIndexPath) as! AlarmListCell;
			print("cell delete alarm", cell.alarmID);
			self.alarmTargetID = cell.alarmID;
			self.presentViewController(self.listConfirmAction as! UIAlertController, animated: true, completion: nil); //show menu
			
		}
		
		return [deleteRow];
	}
    
    ////////////////
    
    func setupModalView(frame:CGRect) {
        modalView.view.frame = frame;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alarmAddAction() {
        //Show alarm-add view
		//뷰는 단 하나의 추가 뷰만 present가 가능한 관계로..
		modalAlarmAddView.showBlur = false;
		
		if #available(iOS 8.0, *) {
			modalAlarmAddView.modalPresentationStyle = .OverFullScreen;
		} else {
			modalAlarmAddView.removeBackgroundViews();
			modalAddViewCalled = true;
		};
		self.presentViewController(modalAlarmAddView, animated: true, completion: nil);
		modalAlarmAddView.clearComponents();
		
    }
    
    func viewCloseAction() {
        //Close this view
		modalAddViewCalled = false;
		if (modalBackgroundBlackCover != nil) { //iOS7 Fallback (Should work on iOS7 only)
			modalBackgroundBlackCover!.removeFromSuperview(); modalBackground!.removeFromSuperview();
		}
		ViewController.viewSelf?.showHideBlurview(false);
        self.dismissViewControllerAnimated(true, completion: nil);
    }
	
	//Switch changed-event
	func alarmSwitchChangedEventHandler(targetElement:UIAlarmIDSwitch) {
		AlarmManager.toggleAlarm(targetElement.elementID, alarmStatus: targetElement.on, isListOn: true);
		
		//리스트 갱신
		for (var i:Int = 0; i < alarmsCell.count; ++i) {
			if (alarmsCell[i].alarmID == targetElement.elementID) {
				let bgFileName:String = getBackgroundFileNameFromTime(alarmsCell[i].timeHour);
				let bgFileState:String = targetElement.on == true ? "on" : "off";
				alarmsCell[i].backgroundImage!.image = UIImage(named: bgFileName + "_time_" + bgFileState + ".png");
				alarmsCell[i].alarmName!.textColor = targetElement.on ? UIColor.whiteColor() : UIColor.blackColor();
				alarmsCell[i].timeText!.textColor = targetElement.on ? UIColor.whiteColor() : UIColor.blackColor();
				
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
		
		tTimeBackground.image = UIImage(named: getBackgroundFileNameFromTime(timeHour) + "_time_" + tTimeImgName + ".png");
		
		tLabel.frame = CGRectMake((self.modalView.view.frame.width * 0.5) * 0.55, 0, self.modalView.view.frame.width * 0.45, 40); //알람 이름
		tLabelTime.frame = CGRectMake((self.modalView.view.frame.width * 0.5) * 0.45, 20, self.modalView.view.frame.width * 0.55, 72); //현재 시간
		tLabel.textAlignment = .Center; tLabelTime.textAlignment = .Center;
		
		//On일때 흰색 폰트로
		if (defaultState) {
			tLabel.textColor = UIColor.whiteColor(); tLabelTime.textColor = UIColor.whiteColor();
		} else {
			tLabel.textColor = UIColor.blackColor(); tLabelTime.textColor = UIColor.blackColor();
		}
		
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
		tLabelTime.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 44); //UIFont.systemFontSize(42);
		//tLabelTime.font = UIFont(name: "AvenirNext-UltraLight", size: 44);
		
		tCell.selectionStyle = UITableViewCellSelectionStyle.None;
		
		//스위치 변경 이벤트
		tSwitch.addTarget(self, action: Selector("alarmSwitchChangedEventHandler:"), forControlEvents: UIControlEvents.ValueChanged);
		
		tCell.backgroundImage = tTimeBackground;
		tCell.alarmName = tLabel;
		tCell.timeText = tLabelTime;
		
		return tCell;
	}

}