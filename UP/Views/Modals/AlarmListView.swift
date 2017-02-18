//
//  AlarmListView.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 Project UP. All rights reserved.
//


import Foundation
import UIKit

class AlarmListView:UIModalView, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate {
	
	//for access
	static var selfView:AlarmListView?
	static var alarmListInited:Bool = false
	
	//Alarm guide label and image
	var alarmAddGuideImageView:UIImageView = UIImageView()
	var alarmAddGuideText:UILabel = UILabel()
	var alarmAddIfEmptyButton:UIButton = UIButton()
	
    //Table for menu
    internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.plain)
    var tablesArray:Array<AnyObject> = []
	var alarmsCell:Array<AlarmListCell> = []
	
	//Alarm-add view
	var modalAlarmAddView:AddAlarmView = GlobalSubView.alarmAddView
	
	//List delete confirm alert
	var listConfirmAction:UIAlertController = UIAlertController()
	var alarmTargetID:Int = 0 //target del id(tmp)
	var alarmTargetIndexPath:IndexPath? // = NSIndexPath(); //to delete animation/optimization
	
	internal var modalAddViewCalled:Bool = false
	
	//위쪽에서 내려오는 알람 메시지를 위한 뷰
	var upAlarmMessageView:UIView = UIView()
	var upAlarmMessageText:UILabel = UILabel()
	
	//화면 레이어 가이드
	var upLayerGuide:AlarmListOverlayGuideView = AlarmListOverlayGuideView()
	
    override func viewDidLoad() {
		super.viewDidLoad( LanguagesManager.$("alarmList"), barColor: UPUtils.colorWithHexString("#535B66"), showOverlayGuideButton: true )
		AlarmListView.selfView = self
		
		//Add [Alarm add] button in navigation controller
		let navRightPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		navRightPadding.width = -12 //Button right padding
		let navFuncButton:UIButton = UIButton() //Add image into UIButton
		navFuncButton.setImage( UIImage(named: "modal-add"), for: UIControlState())
		navFuncButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45) //Image frame size
		navFuncButton.addTarget(self, action: #selector(self.alarmAddAction), for: .touchUpInside)
		modalView.navigationItem.rightBarButtonItems = [ navRightPadding, UIBarButtonItem(customView: navFuncButton) ]
		/////////////////////////////////////////// Nav items fin
		
		//add table to modal
        tableView.frame = CGRect(x: 0, y: 0, width: modalView.view.frame.width, height: modalView.view.frame.height)
		tableView.separatorStyle = .none
        modalView.view.addSubview(tableView)
		
		//알람이 없을 경우 나타나는 메시지에 대한 뷰
		alarmAddGuideImageView = UIImageView( image: UIImage( named: "comp-alarm-notfound.png" ) )
		alarmAddGuideImageView.frame = CGRect(
			x: modalView.view.frame.width / 2 - (102.7 / 2) /* 착시 fix */ + (3.5),
			y: modalView.view.frame.height / 2 - 48,
			width: 102.7, height: 59.6
		)
		modalView.view.addSubview(alarmAddGuideImageView)
		
		//텍스트
		alarmAddGuideText.textColor = UIColor.gray
		alarmAddGuideText.textAlignment = .center;
		alarmAddGuideText.frame = CGRect(
			x: 0, y: modalView.view.frame.height / 2 + 18,
			width: modalView.view.frame.width, height: 24
		)
		alarmAddGuideText.font = UIFont.systemFont(ofSize: 18)
		alarmAddGuideText.text = LanguagesManager.$("alarmListEmpty")
		modalView.view.addSubview(alarmAddGuideText)
		
		//추가 버튼
		alarmAddIfEmptyButton = UIButton()
		alarmAddIfEmptyButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
		alarmAddIfEmptyButton.setTitleColor(UPUtils.colorWithHexString("#BBBBBB"), for: UIControlState())
		alarmAddIfEmptyButton.setTitle(LanguagesManager.$("alarmListAddWhenEmpty"), for: UIControlState())
		alarmAddIfEmptyButton.frame = CGRect(
			x: modalView.view.frame.width / 2 - (80 / 2),
			y: modalView.view.frame.height / 2 + 64,
			width: 80, height: 28
		)
		alarmAddIfEmptyButton.backgroundColor = UIColor.clear
		alarmAddIfEmptyButton.layer.borderWidth = 1
		alarmAddIfEmptyButton.layer.borderColor = UPUtils.colorWithHexString("#BBBBBB").cgColor
		modalView.view.addSubview(alarmAddIfEmptyButton)
		
		alarmAddIfEmptyButton.addTarget(self, action: #selector(self.alarmAddAction), for: .touchUpInside)
		/////////////////////
		
        tableView.delegate = self
		tableView.dataSource = self
        tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
		
		//Document상에서는 iOS 8부터임
		listConfirmAction = UIAlertController(title: LanguagesManager.$("alarmDeleteTitle"), message: LanguagesManager.$("alarmDeleteSure"), preferredStyle: .actionSheet)
		//add menus
		let cancelAct:UIAlertAction = UIAlertAction(title: LanguagesManager.$("generalCancel"), style: .cancel) { action -> Void in
			//Cancel just dismiss it
		}
		let deleteSureAct:UIAlertAction = UIAlertAction(title: LanguagesManager.$("alarmDelete"), style: .destructive) { action -> Void in
			//delete it
			self.deleteAlarmConfirm()
		}
		listConfirmAction.addAction(cancelAct)
		listConfirmAction.addAction(deleteSureAct)
		
		///////
		//Upside message initial
		upAlarmMessageView.backgroundColor = UIColor.white //color initial
		upAlarmMessageText.textColor = UIColor.black
		
		upAlarmMessageText.text = ""
		upAlarmMessageText.textAlignment = .center
		upAlarmMessageView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: 48)
		upAlarmMessageText.frame = CGRect(x: 0, y: 12, width: DeviceManager.scrSize!.width, height: 24)
		upAlarmMessageText.font = UIFont.systemFont(ofSize: 16)
		upAlarmMessageView.addSubview(upAlarmMessageText)
		
		self.view.addSubview( upAlarmMessageView )
		upAlarmMessageView.isHidden = true
		///// upside message inital
		////////////////////////////////////
		
		upLayerGuide.modalNavHeight = navigationCtrl.navigationBar.frame.size.height
		
		AlarmListView.alarmListInited = true
    } //end init func
	
	////////////////////
	func deleteAlarmConfirm() {
		//알람 삭제 통합 function
		
		print("del start of", self.alarmTargetID)
		AlarmManager.removeAlarm(self.alarmTargetID)
		
		//Update table with animation
		self.alarmsCell.remove(at: (self.alarmTargetIndexPath! as NSIndexPath).row)
		self.tablesArray = [self.alarmsCell as AnyObject]
		self.tableView.deleteRows(at: [self.alarmTargetIndexPath!], with: UITableViewRowAnimation.top)
		
		//chk alarm make available
		checkAlarmLimitExceed()
		checkAlarmIsEmpty() //and check is empty
	} //end func
	//iPad Alarm Delete Question
	func showAlarmDelAlert() {
		let alarmDelAlertController = UIAlertController(title: LanguagesManager.$("alarmDelete"), message: LanguagesManager.$("alarmDeleteSure"), preferredStyle: UIAlertControllerStyle.alert)
		alarmDelAlertController.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
			//Alarm delete
			self.deleteAlarmConfirm()
		}))
		
		alarmDelAlertController.addAction(UIAlertAction(title: LanguagesManager.$("generalCancel"), style: .default, handler: { (action: UIAlertAction!) in
			//Cancel
		}))
		present(alarmDelAlertController, animated: true, completion: nil)
	} //end function
	
	//iOS7 & iPad Alert fallback
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		if (buttonIndex == alertView.cancelButtonIndex) { //cancel
			print("ios7 fallback - alarm del canceled")
		} else { //ok confirm
			self.deleteAlarmConfirm()
		}
	}
	
	//iOS7 actionsheet handler
	func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
		//print("actionidx", buttonIndex)
		switch(buttonIndex){
			case 0:
				//Alarm delete
				deleteAlarmConfirm()
				break
			default: break
		} //end switch [buttonIndex]
	} //end func
	
	
	/////// View transition animation
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
		//Check alarm limit and disable/enable button
		checkAlarmLimitExceed()
		checkAlarmIsEmpty()
		
		//add alarm-list
		createTableList()
	} //end func
	
	override func viewAppearedCompleteHandler( ) {
		//알람 리스트 가이드 표시
		if (DataManager.getSavedDataBool( DataManager.settingsKeys.overlayGuideAlarmListFlag ) == false) {
			overlayGuideShowHandler( nil )
		} //end if [check alarmlist overlay guide flag]
	} ///////////////////////////////
	
	override func overlayGuideShowHandler(_ gst:UIGestureRecognizer?) {
		upLayerGuide.modalPresentationStyle = .overFullScreen
		self.present(upLayerGuide, animated: true, completion: nil)
	} //end func
	
	//table list create method
	func createTableList() {
		for i:Int in 0..<alarmsCell.count {
			alarmsCell[i].removeFromSuperview()
		}
		alarmsCell.removeAll()
		
		print("creating table list... count:", AlarmManager.alarmsArray.count )
		var tmpComponentPointer:DateComponents
		for i:Int in 0 ..< AlarmManager.alarmsArray.count {
			tmpComponentPointer = Calendar.current.dateComponents([.hour, .minute], from: AlarmManager.alarmsArray[i].alarmFireDate as Date)
			print("Alarm adding:", AlarmManager.alarmsArray[i].alarmID,
			     ( AlarmManager.alarmsArray[i].alarmFireDate as Date).timeIntervalSince1970 ,
			      AlarmManager.alarmsArray[i].alarmToggle, "repeat", AlarmManager.alarmsArray[i].alarmRepeat)
			alarmsCell += [
				createAlarmList(AlarmManager.alarmsArray[i].alarmName,
					alarmMemo: AlarmManager.alarmsArray[i].alarmMemo,
					defaultState: AlarmManager.alarmsArray[i].alarmToggle,
					funcTimeHour: tmpComponentPointer.hour!,
					funcTimeMin: tmpComponentPointer.minute!,
					selectedGame: AlarmManager.alarmsArray[i].gameSelected,
					repeatSettings: AlarmManager.alarmsArray[i].alarmRepeat,
					uuid: AlarmManager.alarmsArray[i].alarmID)
			]
		}
		tablesArray.removeAll()
		tablesArray = [
			/*section 1*/
			alarmsCell as AnyObject
		]
		
		tableView.reloadData()
		tableView.reloadInputViews()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false
		self.view.autoresizingMask = UIViewAutoresizing()
	} //end func
	
	
	/////////////////////////////////////////
    /// table delegate setup
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
			default:
				return ""
        }
    }
	
	///////////////////////////
	///// 알람수정 (터치시)
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell:AlarmListCell = tableView.cellForRow(at: indexPath) as! AlarmListCell
		//Show alarm edit view
		
		modalAlarmAddView.modalPresentationStyle = .overFullScreen
		
		//find alarm object from array
		let targetAlarm:AlarmElements = AlarmManager.getAlarm(cell.alarmID)!
		self.present(modalAlarmAddView, animated: false, completion: nil)
		
		fadeOutGuideButton()
		let isCustomSound:Bool = targetAlarm.alarmSoundURLString == "" ? false : true
		let tSoundData:SoundData = SoundManager.findSoundObjectWithFileName(isCustomSound ? targetAlarm.alarmSoundURLString : targetAlarm.alarmSound, isCustomSound: isCustomSound)!
		
		print("[AlarmListView] Modifing", targetAlarm.alarmName, targetAlarm.alarmID)
		modalAlarmAddView.fillComponentsWithEditMode(cell.alarmID,
			alarmName: targetAlarm.alarmName,
			alarmMemo: targetAlarm.alarmMemo,
			alarmFireDate: targetAlarm.alarmFireDate,
			selectedGameID: targetAlarm.gameSelected,
			scaledSoundLevel: targetAlarm.alarmSoundLevel,
			soundData: tSoundData,
			repeatInfo: targetAlarm.alarmRepeat,
			alarmDefaultToggle: targetAlarm.alarmToggle)
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tablesArray[section] as! Array<AnyObject>).count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 80 //UITableViewAutomaticDimension;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] as! Array<AnyObject>)[(indexPath as NSIndexPath).row] as! UITableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
	
	//Fallback function. DO NOT REMOVE
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
	} //end func
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		//get row
		let deleteRow:UITableViewRowAction = UITableViewRowAction(style: .default, title: LanguagesManager.$("alarmDelete")) {
			(action:UITableViewRowAction!, childIndexPath:IndexPath!) -> Void in
			
			let cell:AlarmListCell = tableView.cellForRow(at: childIndexPath) as! AlarmListCell
			print("cell delete alarm", cell.alarmID)
			self.alarmTargetID = cell.alarmID
			self.alarmTargetIndexPath = childIndexPath
			
			if (UIDevice.current.userInterfaceIdiom == .pad) {
				//패드일 땐 그냥 alert로 띄움
				self.showAlarmDelAlert()
			} else {
				//폰일 때
				self.present(self.listConfirmAction, animated: true, completion: nil) //show menu
			} //end chk phone or not
			
		} //end if
		
		return [deleteRow]
	} // end func
    /////////////////////////////////////////////////////////
	
	// Frame resize
	override func FitModalLocationToCenter() {
		super.FitModalLocationToCenter()
		upLayerGuide.fitFrames()
		
		//알람 텍스트 및 배경의 조절
		upAlarmMessageText.textAlignment = .center
		upAlarmMessageView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: 48)
		upAlarmMessageText.frame = CGRect(x: 0, y: 12, width: DeviceManager.scrSize!.width, height: 24)
	} //end func
	
	/////////////////////////////////////
    func alarmAddAction() {
        //Show alarm-add view
		//뷰는 단 하나의 추가 뷰만 present가 가능한 관계로..
		//알람추가뷰 열기. 일단 최대 초과하는지 체크함
		if ( AlarmManager.alarmsArray.count >= AlarmManager.alarmMaxRegisterCount ) {
			//초과하므로, 열 수 없음
			let alarmCantAddAlert = UIAlertController(title: LanguagesManager.$("generalAlert"), message: LanguagesManager.$("informationAlarmExceed"), preferredStyle: UIAlertControllerStyle.alert);
			alarmCantAddAlert.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
				//Nothing do
			}));
			present(alarmCantAddAlert, animated: true, completion: nil)
		} else {
			modalAlarmAddView.modalPresentationStyle = .overFullScreen
			
			modalAlarmAddView.FitModalLocationToCenter()
			self.present(modalAlarmAddView, animated: false, completion: nil)
			modalAlarmAddView.clearComponents()
			
			fadeOutGuideButton()
		} //end if [alarm limit]
    } //end func
    
	override func viewCloseAction() {
		if (upAlarmMessageView.isHidden == false) {
			//바로 가려야 함
			upAlarmMessageView.alpha = 0
		}
		modalAddViewCalled = false
		
		super.viewCloseAction()
    } //end func
	
	////////////////////////////////
	func checkAlarmLimitExceed() {
		//informationAlarmExceed
		if ( AlarmManager.alarmsArray.count >= AlarmManager.alarmMaxRegisterCount ) {
			print("Alarm over", AlarmManager.alarmMaxRegisterCount, "(current ", AlarmManager.alarmsArray.count ,")")
			modalView.navigationItem.rightBarButtonItem!.isEnabled = false
		} else {
			modalView.navigationItem.rightBarButtonItem!.isEnabled = true
		}
		
	} //end chk limit func
	
	func checkAlarmIsEmpty() {
		//알람이 비어있는 경우 비어있으니 추가해달라는 메시지 표시.
		if ( AlarmManager.alarmsArray.count == 0 ) {
			//뷰 표시
			alarmAddGuideText.isHidden = false
			alarmAddGuideImageView.isHidden = false
			alarmAddIfEmptyButton.isHidden = false
		} else {
			//메시지 삭제
			alarmAddGuideText.isHidden = true
			alarmAddGuideImageView.isHidden = true
			alarmAddIfEmptyButton.isHidden = true
		} //end if [alarm is empty]
	} //end func
	
	//Switch changed-event
	func alarmSwitchChangedEventHandler(_ targetElement:UIAlarmIDSwitch) {
		AlarmManager.toggleAlarm(targetElement.elementID, alarmStatus: targetElement.isOn, isListOn: true)
		var statusChanged:Bool = false
		
		//리스트 갱신
		var tImage:String = ""
		var targetCell:AlarmListCell?
		for i:Int in 0 ..< alarmsCell.count {
			if (alarmsCell[i].alarmID == targetElement.elementID) {
				targetCell = alarmsCell[i]
				
				if ( alarmsCell[i].alarmToggled != targetElement.isOn) {
					statusChanged = true
				}
				alarmsCell[i].alarmToggled = targetElement.isOn // on = true / off = false
				
				let bgFileName:String = getBackground(alarmsCell[i].timeHour)
				let switchStatus:String = (targetElement.isOn ? ThemeManager.ThemePresets.On : ThemeManager.ThemePresets.Off)
				var fileUsesSmallPrefix:String = ""
				if (UIDevice.current.userInterfaceIdiom == .pad) {
					fileUsesSmallPrefix = ThemeManager.ThemePresets.iPad
				} else if ( DeviceManager.usesLowQualityImage == true ) {
					fileUsesSmallPrefix = ThemeManager.ThemePresets.LDPI
				} //end if
				
				tImage = ThemeManager.getAssetPresets(themeGroup: .Background, themeID: ThemeManager.legacyDefaultTheme) + ThemeManager.getName(bgFileName + fileUsesSmallPrefix + switchStatus)
				
				alarmsCell[i].alarmName!.alpha = targetElement.isOn ? 1 : 0.8
				alarmsCell[i].timeText!.alpha = alarmsCell[i].alarmName!.alpha
				alarmsCell[i].timeAMPM!.alpha = alarmsCell[i].alarmName!.alpha
				alarmsCell[i].timeRepeat!.alpha = alarmsCell[i].alarmName!.alpha
				
				alarmsCell[i].alarmName!.textColor = targetElement.isOn ? UIColor.white : UPUtils.colorWithHexString("#878787")
				alarmsCell[i].timeText!.textColor = alarmsCell[i].alarmName!.textColor
				alarmsCell[i].timeAMPM!.textColor = alarmsCell[i].alarmName!.textColor
				alarmsCell[i].timeRepeat!.textColor = alarmsCell[i].alarmName!.textColor
				break
			} //end if [alarm id matches]
		} //end for
		
		//리스트 타임 변경 애니메이션
		if (statusChanged == true) {
			var tChangeBG:UIImageView? = UIImageView( image: targetCell!.backgroundImage!.image )
			tChangeBG!.frame = targetCell!.backgroundImage!.frame
			tChangeBG!.contentMode = .scaleAspectFill
			targetCell!.addSubview(tChangeBG!); targetCell!.sendSubview(toBack: tChangeBG!)
			targetCell!.backgroundImage!.frame = CGRect(x: 0, y: 80 /* 초기값 위로 */, width: self.modalView.view.frame.width, height: 80)
			targetCell!.backgroundImage!.image = UIImage( named: tImage ) //new img
			
			//구조: 애니메이션용 프레임이 기존 위치에서 위로 올라감, 기존 프레임이 아래에서 올라옴
			UIView.animate(withDuration: 0.56, delay: 0,
									   usingSpringWithDamping: 1, initialSpringVelocity: 1,
									   options: .curveEaseIn, animations: {
				tChangeBG!.frame = CGRect(x: 0, y: -80 /* 아래로 */, width: self.modalView.view.frame.width, height: 80)
				targetCell!.backgroundImage!.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 80)
			}) { _ in
				//완료 시 변경용 뷰 삭제
				tChangeBG!.removeFromSuperview()
				tChangeBG!.image = nil //GC
				tChangeBG = nil //gc
			} //end animate block
		} //end if [statusChanged]
	} //end func
	
	//get str from time
	func getBackground(_ timeHour:Int ) -> String {
		if (timeHour >= 22 || timeHour < 6) {
			return ThemeManager.ThemeFileNames.BackgroundAlarmNight
		} else if (timeHour >= 6 && timeHour < 11) {
			return ThemeManager.ThemeFileNames.BackgroundAlarmMorning
		} else if (timeHour >= 11 && timeHour < 18) {
			return ThemeManager.ThemeFileNames.BackgroundAlarmDaytime
		} else if (timeHour >= 18 && timeHour <= 21) {
			return ThemeManager.ThemeFileNames.BackgroundAlarmSunset
		}
		return ThemeManager.ThemeFileNames.BackgroundAlarmMorning
	} //end func
	
	///////////////////////////////
	//Tableview cell view create
	func createAlarmList(_ name:String, alarmMemo:String, defaultState:Bool, funcTimeHour:Int, funcTimeMin:Int, selectedGame:Int, repeatSettings:Array<Bool>, uuid:Int ) -> AlarmListCell {
		var timeHour:Int = funcTimeHour
		let timeMin:Int = funcTimeMin
		
		let tCell:AlarmListCell = AlarmListCell()
		let tLabel:UILabel = UILabel()
		let tLabelTime:UILabel = UILabel()
		let tTimeBackground:UIImageView = UIImageView()
		
		tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 80 )
		tCell.backgroundColor = UIColor.white
		tTimeBackground.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 80)
		tCell.addSubview(tTimeBackground)
		
		//온오프 시 애니메이션 효과를 주기 위해 마스크를 씌울거임.
		let maskLayer:CAShapeLayer = CAShapeLayer()
		let maskRect:CGRect = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width * 2, height: 80 ) //삭제버튼까지 나와야하므로 마스크 2배
		let path:CGPath = CGPath(rect: maskRect, transform: nil)
		maskLayer.path = path
		tCell.layer.mask = maskLayer
		
		let tSwitch:UIAlarmIDSwitch = UIAlarmIDSwitch()
		let tAMPMLabel:UILabel = UILabel()
		let tRepeatLabel:UILabel = UILabel()
		
		tCell.alarmID = uuid
		tCell.timeHour = timeHour
		tCell.timeMinute = timeMin
		tCell.alarmToggled = defaultState
		tSwitch.elementID = uuid
		
		let switchStatus:String = (defaultState == true ? ThemeManager.ThemePresets.On : ThemeManager.ThemePresets.Off)
		var fileUsesSmallPrefix:String = ""
		if (UIDevice.current.userInterfaceIdiom == .pad) {
			fileUsesSmallPrefix = ThemeManager.ThemePresets.iPad
		} else if ( DeviceManager.usesLowQualityImage == true ) {
			fileUsesSmallPrefix = ThemeManager.ThemePresets.LDPI
		} //end if
		
		let bgFileName:String = getBackground(timeHour)
		tTimeBackground.image = UIImage(named: ThemeManager.getAssetPresets(themeGroup: .Background, themeID: ThemeManager.legacyDefaultTheme) +  ThemeManager.getName(bgFileName + fileUsesSmallPrefix + switchStatus))
		tTimeBackground.contentMode = .scaleAspectFill
		
		tLabel.frame = CGRect(x: 15, y: 50, width: self.modalView.view.frame.width * 0.7, height: 24) //알람 이름
		tLabelTime.frame = CGRect(x: 12, y: 4, width: 0, height: 0) //현재 시간
		tLabel.textAlignment = .left
		
		if (DeviceManager.is24HourMode == false) {
			//오전 오후 모드면
			timeHour = timeHour > 12 ? timeHour - 12 : (timeHour == 0 ? 12 : timeHour)
			tAMPMLabel.isHidden = false
		} else {
			//24시 모드면
			tAMPMLabel.isHidden = true
		} //end if [24hour mode or not]
		
		var timeHourStr:String = String(timeHour)
		if (timeHourStr.characters.count == 1) {
			timeHourStr = "0" + timeHourStr
		}
		var timeMinStr:String = String(timeMin)
		if (timeMinStr.characters.count == 1) {
			timeMinStr = "0" + timeMinStr
		}
		let timeStr:String = timeHourStr + ":" + timeMinStr
		tLabelTime.text = timeStr
		
		//12시간제인 경우 오전오후 표기
		tAMPMLabel.text = funcTimeHour >= 12 && funcTimeHour <= 23 ? LanguagesManager.$("generalPM") : LanguagesManager.$("generalAM")
		//반복설정에 따른 반복표기
		tRepeatLabel.text = AlarmManager.fetchRepeatLabel(repeatSettings, loadType: 1)
		
		tLabelTime.numberOfLines = 0
		tLabelTime.textAlignment = .center
		
		tLabelTime.font = UIFont(name: "SFUIDisplay-Ultralight", size: 41)
		
		tLabelTime.adjustsFontSizeToFitWidth = true
		tLabelTime.sizeToFit()
		
		tAMPMLabel.frame = CGRect( x: tLabelTime.frame.width + 16, y: 8, width: 60, height: 24 ) //오전 오후 인디케이터. (12시간만 해당)
		tRepeatLabel.frame = CGRect( x: tLabelTime.frame.width + 16, y: 25, width: 60, height: 24 ) //반복 인디케이터.
		tAMPMLabel.textAlignment = .left
		tRepeatLabel.textAlignment = .left
		
		//알람명 표시.
		tLabel.text = name
		
		tLabel.font = UIFont.systemFont(ofSize: 16)
		tAMPMLabel.font = UIFont.boldSystemFont(ofSize: 15)
		tRepeatLabel.font = UIFont.systemFont(ofSize: 15)
		
		//On일때 알파 1
		tLabel.textColor = defaultState ? UIColor.white : UPUtils.colorWithHexString("#878787")
		tLabel.alpha = defaultState ? 1 : 0.8; tLabelTime.alpha = tLabel.alpha
		tAMPMLabel.alpha = tLabel.alpha
		tRepeatLabel.alpha = tLabel.alpha
		
		tLabelTime.textColor = tLabel.textColor
		tAMPMLabel.textColor = tLabel.textColor
		tRepeatLabel.textColor = tLabel.textColor
		
		tSwitch.frame.origin.x = self.modalView.view.frame.width - tSwitch.frame.width - CGFloat(16)
		tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2
		tSwitch.isOn = defaultState; tCell.addSubview(tSwitch)
		
		tCell.addSubview(tLabel); tCell.addSubview(tLabelTime); tCell.addSubview(tAMPMLabel); tCell.addSubview(tRepeatLabel);
		
		//스위치 변경 이벤트 (핸들러 추가)
		tSwitch.addTarget(self, action: #selector(AlarmListView.alarmSwitchChangedEventHandler(_:)), for: UIControlEvents.valueChanged)
		
		tCell.backgroundImage = tTimeBackground;
		tCell.alarmName = tLabel; tCell.timeText = tLabelTime;
		tCell.timeAMPM = tAMPMLabel; tCell.timeRepeat = tRepeatLabel;
		
		return tCell
	} //end func [add]
	
	////////////////////////////
	//notify on scr
	func showMessageOnView( _ message:String, backgroundColorHex:String, textColorHex:String ) {
		if (upAlarmMessageView.isHidden == false) {
			//몇초 뒤 나타나게 함.
			_ = UPUtils.setTimeout(2.5, block: {_ in
				self.showMessageOnView( message, backgroundColorHex: backgroundColorHex, textColorHex: textColorHex );
			});
			return
		} //end if [messageView is hidden]
		
		//이 부분은 메인 뷰 컨트롤러에도 나오게끔 만듬
		(self.presentingViewController as! ViewController).showMessageOnView(message, backgroundColorHex: backgroundColorHex, textColorHex: textColorHex)
		
		self.upAlarmMessageView.alpha = 1
		
		self.view.bringSubview(toFront: upAlarmMessageView)
		upAlarmMessageView.isHidden = false
		upAlarmMessageView.backgroundColor = UPUtils.colorWithHexString(backgroundColorHex)
		upAlarmMessageText.textColor = UPUtils.colorWithHexString(textColorHex)
		upAlarmMessageText.text = message
		
		UIApplication.shared.setStatusBarHidden(true, with: .fade) //statusbar hidden
		self.upAlarmMessageView.frame = CGRect(x: 0, y: -self.upAlarmMessageView.frame.height, width: self.upAlarmMessageView.frame.width, height: self.upAlarmMessageView.frame.height)
		
		
		//Message animation
		UIView.animate(withDuration: 0.32, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.upAlarmMessageView.frame = CGRect(x: 0, y: 0, width: self.upAlarmMessageView.frame.width, height: self.upAlarmMessageView.frame.height);
			}, completion: {_ in
		}) //end animate block
		
		//animation fin.
		UIView.animate(withDuration: 0.32, delay: 1, options: UIViewAnimationOptions.curveEaseIn, animations: {
			self.upAlarmMessageView.frame = CGRect(x: 0, y: -self.upAlarmMessageView.frame.height, width: self.upAlarmMessageView.frame.width, height: self.upAlarmMessageView.frame.height);
			}, completion: {_ in
				self.upAlarmMessageView.isHidden = true;
				UIApplication.shared.setStatusBarHidden(false, with: .fade);
		}) //end animate block
	} //end func
	
} //end class
