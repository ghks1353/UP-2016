//
//  AddAlarmView.swift
//  	
//
//  Created by ExFl on 2016. 1. 31..
//  Copyright © 2016년 Project UP. All rights reserved.
//


import Foundation
import UIKit

class AddAlarmView:UIModalView, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
	
	//클래스 외부접근을 위함
	static var selfView:AddAlarmView?
	
	//Table for view
	var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped)
	var tablesArray:Array<Array<AnyObject>> = []
	var tableCells:Array<AlarmSettingsCell> = []
	
	//Subview for select
	var alarmSoundListView:AlarmSoundListView = GlobalSubView.alarmSoundListView
	var alarmGameListView:AlarmGameListView = GlobalSubView.alarmGameListView
	var alarmRepeatSelectListView:AlarmRepeatSettingsView = GlobalSubView.alarmRepeatSettingsView
	//Current sound level
	var alarmCurrentSoundLevel:Int = 0
	//Alarm sound selected
	var alarmSoundSelectedObj:SoundInfoObj = SoundInfoObj(soundName: "", fileName: "")
	//Game selected
	var gameSelectedID:Int = -1
	
	//Default alarm status (default: true)
	var alarmDefaultStatus:Bool = true
	var editingAlarmID:Int = -1
	
	var currentRepeatMode:Array<Bool> = [false, false, false, false, false, false, false]
	
	var isAlarmEditMode:Bool = false
	var confirmed:Bool = false //편집 혹은 확인을 누를 경우임.
	
	//////////////
	var addedAlarmWithExiting:Bool = false
	var parentIsMainView:Bool = false
	
	//알람 셋업 fullscreen 가이드
	var upAlarmFullGuide:AlarmSetupGuideView = GlobalSubView.alarmSetupGuideView
	
	override func viewDidLoad() {
		super.viewDidLoad( LanguagesManager.$("alarmSettings"), barColor: UPUtils.colorWithHexString("#4F3317"), showOverlayGuideButton: true )
		AddAlarmView.selfView = self
		
		//add right button [Add alarm]
		let navRightPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		navRightPadding.width = -12 //Button right padding
		let navFuncButton:UIButton = UIButton() //Add image into UIButton
		navFuncButton.setImage( UIImage(named: "modal-check"), for: UIControlState())
		navFuncButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45) //Image frame size
		navFuncButton.addTarget(self, action: #selector(self.addAlarmToDevice), for: .touchUpInside)
		modalView.navigationItem.rightBarButtonItems = [ navRightPadding, UIBarButtonItem(customView: navFuncButton) ]
		/////////////////////// Nav items fin
		
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: modalView.view.frame.width, height: modalView.view.frame.height)
		modalView.view.addSubview(tableView)
		
		//add table cells (options)
		tablesArray = [
			[ /* sec 1 */
				createGameSelectionCell()
			],
			[ /* section 2 */
				createCell(0, cellID: "alarmName"),
				createCell(0, cellID: "alarmMemo")
			],
			[ /* section 3 */
				createCell(2, cellID: "alarmSound"),
				createCell(2, cellID: "alarmRepeatSetting")
			],
			[ /* section 4 */
				createCell(1, cellID: "alarmDatePicker")
			]
		] ///////////////////////////////////////////////
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
		
		//set subview size
		setSubviewSize()
	} //end init func
	
	override func overlayGuideShowHandler(_ gst:UIGestureRecognizer ) {
		//알람 셋업 가이드 표시 시.
		upAlarmFullGuide.modalPresentationStyle = .overFullScreen
		self.present( upAlarmFullGuide, animated: true, completion: nil )
	} //end func
	
	//////////////////
	internal func setSubviewSize() {
		alarmSoundListView.view.frame = CGRect(
			x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height )
		alarmGameListView.view.frame = CGRect(
			x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height )
		alarmRepeatSelectListView.view.frame = CGRect(
			x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height )
	} //end func
	
	/////// View transition animation
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
		addedAlarmWithExiting = false
		parentIsMainView = false
		
		//알람 메모 사용기능 시 사용 (실험실)
		//이건 단순히 hidden 상태만 조정하는거임
		DataManager.initDefaults()
		let tmpOption:Bool = DataManager.nsDefaults.bool(forKey: DataManager.EXPERIMENTS_USE_MEMO_KEY)
		let alarmsCellArr:Array<AlarmSettingsCell> = tablesArray[1] as! Array<AlarmSettingsCell>
		if (tmpOption == true) { /* 메모 사용 시 */
			alarmsCellArr[1].isHidden = false
		} else { //메모 사용 안함.
			alarmsCellArr[1].isHidden = true
		}
		tableView.reloadData()
	} /// end func
	
	override func viewAppearedCompleteHandler() {
		if (self.presentingViewController is AlarmListView) {
			(self.presentingViewController as! AlarmListView).tableView.isHidden = true
		}
	} ///////////////////////////////
	
	//set sound element from other view
	internal func setSoundElement(_ sInfo:SoundInfoObj) {
		(getElementFromTable("alarmSound") as! UILabel).text = sInfo.soundLangName
		alarmSoundSelectedObj = sInfo
	}
	
	//set game id from other view
	internal func setGameElement(_ gameID:Int) {
		var gameName:String = ""
		let tArray:Array<AlarmSettingsCell> = tablesArray[0] as! Array<AlarmSettingsCell>
		
		switch(gameID) {
			case -1: //RANDOM
				//랜덤은 게임선택으로 하고, 설명을 랜덤으로 하죠
				(getElementFromTable("alarmGame") as! UILabel).text = LanguagesManager.$("alarmGameSelect")
				(getElementFromTable("alarmGame", isSubElement: true) as! UILabel).text = LanguagesManager.$("alarmGameRandom")
				
				getImageViewFromTable("alarmGame")!.image = UIImage(named: "game-thumb-random.png")
				tArray[0].backgroundColor = UPUtils.colorWithHexString("#333333")
				break
			default:
				gameName = GameManager.list[gameID].gameLangName;
				(getElementFromTable("alarmGame") as! UILabel).text = gameName //LanguagesManager.$("alarmGameSelect");
				(getElementFromTable("alarmGame", isSubElement: true) as! UILabel).text = LanguagesManager.$("alarmGameSelect")
				
				getImageViewFromTable("alarmGame")!.image = UIImage(named: GameManager.list[gameID].gameThumbFileName + ".png")
				tArray[0].backgroundColor = GameManager.list[gameID].gameBackgroundUIColor
				break
		} //end switch
		
		gameSelectedID = gameID
	} ////////// end func
	
	//add alarm evt
	func addAlarmToDevice() {
		confirmed = true
		
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
				alarmID: -1)
		} else {
			//Edit alarm
			AlarmManager.editAlarm(editingAlarmID,
				funcDate: (getElementFromTable("alarmDatePicker") as! UIDatePicker).date,
				alarmTitle: (getElementFromTable("alarmName") as! UITextField).text!,
				alarmMemo: (getElementFromTable("alarmMemo") as! UITextField).text!,
				gameID: gameSelectedID,
				soundLevel: alarmCurrentSoundLevel,
				soundFile: alarmSoundSelectedObj,
				repeatArr: currentRepeatMode, toggleStatus: alarmDefaultStatus)
		} //end if [isEditMode]
		
		//added successfully. close view
		viewCloseAction( true )
	} //end func
	
	//for default setting at view opening
	func getElementFromTable(_ cellID:String, isSubElement:Bool = false)->AnyObject? {
		//let anyobjectOfTable:AnyObject?;
		for i:Int in 0 ..< tableCells.count {
			if (tableCells[i].cellID == cellID) {
				return isSubElement ? tableCells[i].cellSubElement! : tableCells[i].cellElement!
			}
		}
		return nil
	} //end func
	
	//위 함수의 이미지 버전
	func getImageViewFromTable(_ cellID:String)->UIImageView? {
		for i:Int in 0 ..< tableCells.count {
			if (tableCells[i].cellID == cellID) {
				return tableCells[i].cellImageViewElement!
			}
		}
		return nil
	} //end func
	
	override func viewDisappearedCompleteHandler() {
		if (DataManager.getSavedDataBool( DataManager.settingsKeys.fullscreenAlarmGuideFlag ) == false && addedAlarmWithExiting == true) {
			GlobalSubView.alarmSetupGuideView.modalPresentationStyle = .overFullScreen
			if (parentIsMainView == true) {
				//메인에서 present
				ViewController.selfView!.present(GlobalSubView.alarmSetupGuideView, animated: true, completion: nil)
			} else {
				//리스트에서 present
				AlarmListView.selfView!.present(GlobalSubView.alarmSetupGuideView, animated: true, completion: nil)
			} //end if
		} //end if
		
	} //end func
	
	override func viewCloseAction() {
		viewCloseAction(false)
	} //end func
	func viewCloseAction(_ addedAlarm:Bool = false) {
		//if parent is main or not
		if (self.presentingViewController is ViewController) {
			ViewController.selfView!.showHideBlurview(false)
			
			//Add alarm alert to main
			if (confirmed == true) {
				ViewController.selfView!.showMessageOnView(LanguagesManager.$(isAlarmEditMode == true ? "informationAlarmEdited" : "informationAlarmAdded"), backgroundColorHex: "219421", textColorHex: "FFFFFF")
			}
			parentIsMainView = true
		} else {
			//Check alarm make/ornot
			(self.presentingViewController as! AlarmListView).checkAlarmLimitExceed()
			(self.presentingViewController as! AlarmListView).checkAlarmIsEmpty() //and chk list is empty or not
			
			//Add alarm alert to list
			if (confirmed == true) {
				(self.presentingViewController as! AlarmListView).showMessageOnView(LanguagesManager.$(isAlarmEditMode == true ? "informationAlarmEdited" : "informationAlarmAdded"), backgroundColorHex: "219421", textColorHex: "FFFFFF")
			}
			
			//list tableview visible
			(self.presentingViewController as! AlarmListView).tableView.isHidden = false
			//show guide again
			(self.presentingViewController as! AlarmListView).fadeInGuideButton( false )
		} //end if
		
		//if playing sound, stop it
		alarmSoundListView.stopSound()
		
		addedAlarmWithExiting = addedAlarm
		
		super.viewCloseAction()
	} //// end func
	
	///// for table func
	func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	} //end func (define sections num)
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			default:
				return ""
		} //end switch
	} //end func
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] ).count
	} //end func
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		//print("progressing section", indexPath.section);
		switch((indexPath as NSIndexPath).section){
			case 0:
				return 95
			case 3:
				return 200
			default:
				break
		} //end switch [index section]
		
		let cellArr:Array<AlarmSettingsCell> = tablesArray[(indexPath as NSIndexPath).section] as! Array<AlarmSettingsCell>;
		let cell:AlarmSettingsCell = cellArr[(indexPath as NSIndexPath).row]
		
		if (cell.isHidden == true) {
			return 0
		} //end if
		
		return UITableViewAutomaticDimension
	} //end func
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] )[(indexPath as NSIndexPath).row] as! UITableViewCell
		return cell
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch(section){
			case 0:
				return 0.00001
			default:
				break
		} //end switch [section]
		return 8
	} //end func
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 4
	} //end func [footer section height]
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellID:String = (tableView.cellForRow(at: indexPath) as! AlarmSettingsCell).cellID
		switch(cellID) {
			case "alarmGame": //게임 선택 뷰
				self.alarmGameListView.selectCell( gameSelectedID )
				navigationCtrl.pushViewController(self.alarmGameListView, animated: true)
				break
			case "alarmSound": //알람 사운드 선택 뷰				self.alarmSoundListView.setSelectedCell( alarmSoundSelectedObj )
				self.alarmSoundListView.soundSliderPointer!.value = Float(alarmCurrentSoundLevel) / 100 //0~1 scale
				self.alarmSoundListView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) //scroll to top
				navigationCtrl.pushViewController(self.alarmSoundListView, animated: true)
				break
			case "alarmRepeatSetting": //알람 반복 선택 뷰
				self.alarmRepeatSelectListView.setSelectedCell( currentRepeatMode )
				navigationCtrl.pushViewController(self.alarmRepeatSelectListView, animated: true)
				break
			default: break
		} //end switch
		
		tableView.deselectRow(at: indexPath, animated: true)
	} //end switch [CellID]
	
	//Create cell, game selection
	func createGameSelectionCell() -> AlarmSettingsCell {
		let tCell:AlarmSettingsCell = AlarmSettingsCell()
		tCell.backgroundColor = UPUtils.colorWithHexString("#333333")
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 95)
		
		//Random game
		//let gameImgName:String = "game-thumb-random.png";
		let tGameThumbnailsPictureBackground:UIImageView = UIImageView(image: UIImage(named: "game-thumb-background.png"))
		tGameThumbnailsPictureBackground.frame = CGRect(x: 14, y: 14, width: 66, height: 66)
		tCell.addSubview(tGameThumbnailsPictureBackground)
		
		let tGameThumbnailsPicture:UIImageView = UIImageView()
		tGameThumbnailsPicture.frame = tGameThumbnailsPictureBackground.frame
		tCell.addSubview(tGameThumbnailsPicture)
		
		///////
		let tGameSubjectLabel:UILabel = UILabel() //게임 제목
		tGameSubjectLabel.frame = CGRect(x: 92, y: 22, width: tableView.frame.width * 0.6, height: 28)
		tGameSubjectLabel.font = UIFont.systemFont(ofSize: 22)
		tGameSubjectLabel.text = ""
		tGameSubjectLabel.textColor = UIColor.white
		
		let tGameGenreLabel:UILabel = UILabel() //게임 장르
		tGameGenreLabel.frame = CGRect(x: 92, y: 49, width: tableView.frame.width * 0.6, height: 20)
		tGameGenreLabel.font = UIFont.systemFont(ofSize: 14)
		tGameGenreLabel.text = ""
		tGameGenreLabel.textColor = UIColor.white
		
		tCell.cellElement = tGameSubjectLabel
		tCell.cellSubElement = tGameGenreLabel
		tCell.cellImageViewElement = tGameThumbnailsPicture
		
		tCell.cellID = "alarmGame"
		
		tCell.accessoryType = .disclosureIndicator
		tCell.addSubview(tGameSubjectLabel); tCell.addSubview(tGameGenreLabel)
		
		tableCells += [tCell]
		return tCell
	} //end func
	
	
	//Tableview cell view create
	func createCell( _ cellType:Int, cellID:String ) -> AlarmSettingsCell {
		let tCell:AlarmSettingsCell = AlarmSettingsCell()
		tCell.cellID = cellID
		tCell.backgroundColor = UIColor.white
		tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 45) //default cell size
		
		switch( cellType ) {
			case 0: //Inputtext cell
				let alarmNameInput:UITextField = UITextField(frame: tCell.frame)
				//alarmMemo
				switch(cellID) {
					case "alarmName":
						alarmNameInput.placeholder = LanguagesManager.$("alarmTitle")
						break;
					case "alarmMemo":
						alarmNameInput.placeholder = LanguagesManager.$("alarmMemo")
						break;
					default:
						alarmNameInput.placeholder = ""
						break;
				} //end switch
				
				alarmNameInput.borderStyle = UITextBorderStyle.none
				alarmNameInput.autocorrectionType = UITextAutocorrectionType.no
				alarmNameInput.keyboardType = UIKeyboardType.default
				alarmNameInput.returnKeyType = UIReturnKeyType.done
				alarmNameInput.clearButtonMode = UITextFieldViewMode.never
				alarmNameInput.contentVerticalAlignment = UIControlContentVerticalAlignment.center
				alarmNameInput.textAlignment = .center
				alarmNameInput.delegate = self
				
				tCell.cellElement = alarmNameInput
				tCell.addSubview(alarmNameInput)
				break
			case 1: //DatePicker cell
				tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 200) //cell size to datepicker size fit
				let alarmTimePicker:UIDatePicker = UIDatePicker(frame: tCell.frame)
				alarmTimePicker.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 200)
				alarmTimePicker.datePickerMode = UIDatePickerMode.time
				alarmTimePicker.date = Date() //default => current
				//alarmTimePicker.fr
				tCell.cellElement = alarmTimePicker
				tCell.addSubview(alarmTimePicker)
				break;
			
			case 2: //Option sel label cell
				let tLabel:UILabel = UILabel(); let tSettingLabel:UILabel = UILabel();
				tSettingLabel.frame = CGRect(x: self.modalView.view.frame.width - self.modalView.view.frame.width * 0.4 - 32, y: 0, width: self.modalView.view.frame.width * 0.4, height: 45);
				tSettingLabel.textAlignment = .right;
				tLabel.font = UIFont.systemFont(ofSize: 16); tSettingLabel.font = tLabel.font;
				tSettingLabel.textColor = UPUtils.colorWithHexString("#999999");
				
				//아이콘 표시 관련
				let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
				tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3);
				switch(cellID) { //특정 조건으로 아이콘 구분
					case "alarmGame": tIconFileStr = "comp-icons-settings-newgames"; break;
					case "alarmSound": tIconFileStr = "comp-icons-alarm-music"; break;
					case "alarmRepeatSetting": tIconFileStr = "comp-icons-alarm-repeat"; break;
						
					default: tIconFileStr = "comp-icons-blank"; break;
				}; tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
				tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
				
				switch(cellID) {
					case "alarmGame":
						tLabel.text = LanguagesManager.$("alarmGame");
						break;
					case "alarmSound":
						tLabel.text = LanguagesManager.$("alarmSound");
						if (DeviceManager.defaultModalSizeRect.width < 250) {
							// 작은 화면에서 표시 못하는 세부설정 감춤
							tSettingLabel.isHidden = true;
						}
						
						break;
					case "alarmRepeatSetting":
						tLabel.text = LanguagesManager.$("alarmRepeat");
						break;
					default: break;
				}
				
				tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: self.modalView.view.frame.width * 0.4, height: 45);
				
				tCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator;
				
				tCell.cellElement = tSettingLabel;
				tSettingLabel.text = LanguagesManager.$("generalDefault");
				tCell.addSubview(tLabel); tCell.addSubview(tSettingLabel);
				break;
			
			
			default:
				return tCell; //return empty cell
		} //end switchg [CellType]
		
		tableCells += [tCell]
		return tCell
	} ///// end func
	
	//////////////////////////
	func autoSelectRepeatElement( _ repeatInfo:Array<Bool> ) {
		let settingsLabelPointer:UILabel = getElementFromTable("alarmRepeatSetting") as! UILabel
		settingsLabelPointer.text = AlarmManager.fetchRepeatLabel(repeatInfo, loadType: 0)
	}
	
	//clear all components
	func clearComponents() {
		(self.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = Date() //date to current
		(self.getElementFromTable("alarmName") as! UITextField).text = "" //empty alarm name
		(self.getElementFromTable("alarmMemo") as! UITextField).text = "" //empty alarm memo
		self.setSoundElement(SoundManager.list[0]) //default - first element of soundlist
		self.setGameElement(-1) //set default to random
		
		gameSelectedID = -1 //clear selected game id
		self.resetAlarmRepeatCell()
		
		modalView.title = LanguagesManager.$("alarmSettings") //Modal title set to alarmsettings
		
		isAlarmEditMode = false //AddMode
		alarmDefaultStatus = true //default on
		editingAlarmID = -1
		confirmed = false
		
		alarmCurrentSoundLevel = 80 //default size
		
		self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) //scroll to top
	} ///// end func
	
	//components fill for modify alarm
	func fillComponentsWithEditMode( _ alarmID:Int, alarmName:String, alarmMemo:String, alarmFireDate:Date, selectedGameID:Int, scaledSoundLevel:Int, selectedSoundFileName:String, repeatInfo:Array<Bool>, alarmDefaultToggle:Bool) {
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
		
		modalView.title = LanguagesManager.$("alarmEditTitle"); //Modal title set to alarmedit
		
		isAlarmEditMode = true; //EditMode
		alarmDefaultStatus = alarmDefaultToggle; //Default toggle status
		editingAlarmID = alarmID;
		
		alarmCurrentSoundLevel = scaledSoundLevel;
		//scaledSoundLevel
		
		self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
	}
	
	//UITextfield del
	func textFieldShouldReturn(_ textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	//Alarm element reset func
	func resetAlarmRepeatCell() {
		let resetedRepeatInfo:Array<Bool> = [false, false, false, false, false, false, false];
		autoSelectRepeatElement( resetedRepeatInfo );
		currentRepeatMode = resetedRepeatInfo;
		
		//alarmRepeatSelectListView.setSelectedCell( resetedRepeatInfo );
	}
	
	
}
