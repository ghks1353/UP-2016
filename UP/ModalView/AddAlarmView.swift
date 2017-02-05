//
//  AddAlarmView.swift
//  	
//
//  Created by ExFl on 2016. 1. 31..
//  Copyright © 2016년 Project UP. All rights reserved.
//


import Foundation
import UIKit

class AddAlarmView:UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
	
	//클래스 외부접근을 위함
	static var selfView:AddAlarmView?
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController()
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController()
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped)
	var tablesArray:Array<Array<AnyObject>> = []
	var tableCells:Array<AlarmSettingsCell> = []
	
	//Subview for select
	var alarmSoundListView:AlarmSoundListView = GlobalSubView.alarmSoundListView // = AlarmSoundListView();
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
	
	internal var currentRepeatMode:Array<Bool> = [false, false, false, false, false, false, false]
	
	internal var isAlarmEditMode:Bool = false
	
	var confirmed:Bool = false //편집 혹은 확인을 누를 경우임.
	
	//// Mask views
	var maskUIView:UIView = UIView()
	let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"))
	let modalUpperMaskView:UIView = UIView()
	
	//알람 셋업 fullscreen 가이드
	var upAlarmFullGuide:AlarmSetupGuideView = GlobalSubView.alarmSetupGuideView
	//레이어가이드 보이기 버튼
	var upLayerGuideShowButton:UIImageView = UIImageView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.clear
		
		AddAlarmView.selfView = self
		
		//ModalView
		modalView.view.backgroundColor = UIColor.white
		modalView.view.frame = DeviceManager.defaultModalSizeRect
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
		navigationCtrl = UINavigationController.init(rootViewController: modalView)
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#4F3317")
		navigationCtrl.navigationBar.tintColor = UIColor.white
		navigationCtrl.view.frame = modalView.view.frame
		
		modalView.title = LanguagesManager.$("alarmSettings")
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		navLeftPadding.width = -12 //Button left padding
		let navCloseButton:UIButton = UIButton() //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), for: UIControlState())
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45) //Image frame size
		navCloseButton.addTarget(self, action: #selector(AddAlarmView.viewCloseAction), for: .touchUpInside)
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ]
		
		//add right items
		let navRightPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		navRightPadding.width = -12 //Button right padding
		let navFuncButton:UIButton = UIButton() //Add image into UIButton
		navFuncButton.setImage( UIImage(named: "modal-check"), for: UIControlState())
		navFuncButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45) //Image frame size
		navFuncButton.addTarget(self, action: #selector(AddAlarmView.addAlarmToDevice), for: .touchUpInside)
		modalView.navigationItem.rightBarButtonItems = [ navRightPadding, UIBarButtonItem(customView: navFuncButton) ]
		///////// Nav items fin
		
		//add ctrl
		self.view.addSubview(navigationCtrl.view)
		
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
		
		////////// 모달 밖에 배치하는 리소스
		upLayerGuideShowButton.image = UIImage( named: "comp-showguide-icon.png" )
		self.view.addSubview(upLayerGuideShowButton)
		
		//SET MASK for dot eff
		modalMaskImageView.frame = modalView.view.frame
		modalMaskImageView.contentMode = .scaleAspectFit
		
		modalUpperMaskView.backgroundColor = UIColor.white
		
		maskUIView.addSubview(modalMaskImageView)
		maskUIView.addSubview(modalUpperMaskView)
		
		self.view.mask = maskUIView
		
		
		//알람 셋업 가이드 표시
		let tGesture = UITapGestureRecognizer(target:self, action: #selector(AddAlarmView.showAlarmFullGuide(_:)))
		upLayerGuideShowButton.isUserInteractionEnabled = true
		upLayerGuideShowButton.addGestureRecognizer(tGesture)
		
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false
		
		//set subview size
		setSubviewSize()
		
		FitModalLocationToCenter()
	} //end init func
	
	func showAlarmFullGuide(_ gst:UIGestureRecognizer ) {
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
		//setup bounce animation
		self.view.alpha = 0
		
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
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		//swift3에서는 void이외의 리턴되는 값이 있는 경우 사용하지 않으면 경고를 내기 때문에
		//아래처럼 임시변수를 만듬.
		//_ = AnalyticsManager.untrackScreen(); //untrack to previous screen
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
		                             width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
			self.view.frame = CGRect(x: 0, y: 0,
				width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
			if (self.presentingViewController is AlarmListView) {
				(self.presentingViewController as! AlarmListView).tableView.isHidden = true
			}
		}
		
		fadeInGuideButton()
	} ///////////////////////////////
	
	func fadeInGuideButton( _ withDelay:Bool = true ) {
		upLayerGuideShowButton.alpha = 0
		UIView.animate(withDuration: 0.5, delay: withDelay ? 0.56 : 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.upLayerGuideShowButton.alpha = 1
		}, completion: {_ in
		})
	} //end func
	func fadeOutGuideButton( ) {
		upLayerGuideShowButton.alpha = 1
		UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.upLayerGuideShowButton.alpha = 0
		}, completion: {_ in
		})
	} //end func
	
	////////////////////////////
	
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
		}
		
		gameSelectedID = gameID
	}
	
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
		
		//added successfully. close view
		viewCloseAction( true )
	} //end func
	
	//for default setting at view opening
	internal func getElementFromTable(_ cellID:String, isSubElement:Bool = false)->AnyObject? {
		//let anyobjectOfTable:AnyObject?;
		for i:Int in 0 ..< tableCells.count {
			if (tableCells[i].cellID == cellID) {
				return isSubElement ? tableCells[i].cellSubElement! : tableCells[i].cellElement!;
			}
		}
		return nil;
	}
	
	//위 함수의 이미지 버전
	internal func getImageViewFromTable(_ cellID:String)->UIImageView? {
		for i:Int in 0 ..< tableCells.count {
			if (tableCells[i].cellID == cellID) {
				return tableCells[i].cellImageViewElement!;
			}
		}
		return nil;
	}
	
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect;
		
		if (self.view.mask != nil) {
			modalMaskImageView.frame = DeviceManager.defaultModalSizeRect
			
			modalUpperMaskView.frame = CGRect( x: DeviceManager.scrSize!.width - ((50.5 + 18) * DeviceManager.maxScrRatioC), y: 34 * DeviceManager.maxScrRatioC, width: 50.5 * DeviceManager.maxScrRatioC, height: 50.5 * DeviceManager.maxScrRatioC)
		}
		
		upLayerGuideShowButton.frame = CGRect( x: DeviceManager.scrSize!.width - ((50.5 + 18) * DeviceManager.maxScrRatioC), y: 34 * DeviceManager.maxScrRatioC, width: 50.5 * DeviceManager.maxScrRatioC, height: 50.5 * DeviceManager.maxScrRatioC)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction(_ addedAlarm:Bool = false) {
		//Close this view
		
		//Hide guide
		upLayerGuideShowButton.alpha = 0
		
		//if playing sound, stop it
		alarmSoundListView.stopSound()
		
		//알람 풀 가이드를 맨 처음 띄우기 위해 dismiss complete 블럭에 검사를 위한 용도
		var parentIsMainView:Bool = false
		
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
		
		self.dismiss(animated: true, completion: {
			if (DataManager.getSavedDataBool( DataManager.settingsKeys.fullscreenAlarmGuideFlag ) == false && addedAlarm == true) {
				GlobalSubView.alarmSetupGuideView.modalPresentationStyle = .overFullScreen
				if (parentIsMainView == true) {
					//메인에서 present
					ViewController.selfView!.present(GlobalSubView.alarmSetupGuideView, animated: true, completion: nil)
				} else {
					//리스트에서 present
					AlarmListView.selfView!.present(GlobalSubView.alarmSetupGuideView, animated: true, completion: nil)
				} //end if
			}
		}) //end block
	}
	
	///// for table func
	func numberOfSections(in tableView: UITableView) -> Int {
		return 4
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			default:
				return ""
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] ).count;
		
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		//print("progressing section", indexPath.section);
		switch((indexPath as NSIndexPath).section){
			case 0:
				return 95;
			case 3:
				return 200;
			default:
				break;
		}
		
		let cellArr:Array<AlarmSettingsCell> = tablesArray[(indexPath as NSIndexPath).section] as! Array<AlarmSettingsCell>;
		let cell:AlarmSettingsCell = cellArr[(indexPath as NSIndexPath).row];
		
		if (cell.isHidden == true) {
			return 0;
		}
		
		return UITableViewAutomaticDimension;
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] )[(indexPath as NSIndexPath).row] as! UITableViewCell;
		return cell;
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch(section){
			case 0:
				return 0.00001;
			default:
				break;
		}
		return 8;
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 4;
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellID:String = (tableView.cellForRow(at: indexPath) as! AlarmSettingsCell).cellID;
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
		
		tableView.deselectRow(at: indexPath, animated: true);
	}
	
	//Create cell, game selection
	func createGameSelectionCell() -> AlarmSettingsCell {
		let tCell:AlarmSettingsCell = AlarmSettingsCell();
		tCell.backgroundColor = UPUtils.colorWithHexString("#333333");
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 95);
		
		//Random game
		//let gameImgName:String = "game-thumb-random.png";
		let tGameThumbnailsPictureBackground:UIImageView = UIImageView(image: UIImage(named: "game-thumb-background.png"));
		tGameThumbnailsPictureBackground.frame = CGRect(x: 14, y: 14, width: 66, height: 66);
		tCell.addSubview(tGameThumbnailsPictureBackground);
		
		let tGameThumbnailsPicture:UIImageView = UIImageView(); //UIImageView(image: UIImage(named: gameImgName));
		tGameThumbnailsPicture.frame = tGameThumbnailsPictureBackground.frame; tCell.addSubview(tGameThumbnailsPicture);
		
		///////
		let tGameSubjectLabel:UILabel = UILabel(); //게임 제목
		tGameSubjectLabel.frame = CGRect(x: 92, y: 22, width: tableView.frame.width * 0.6, height: 28);
		tGameSubjectLabel.font = UIFont.systemFont(ofSize: 22);
		tGameSubjectLabel.text = ""; //LanguagesManager.$("alarmGameRandom"); //Random
		tGameSubjectLabel.textColor = UIColor.white;
		
		let tGameGenreLabel:UILabel = UILabel(); //게임 장르
		tGameGenreLabel.frame = CGRect(x: 92, y: 49, width: tableView.frame.width * 0.6, height: 20);
		tGameGenreLabel.font = UIFont.systemFont(ofSize: 14);
		tGameGenreLabel.text = "";
		tGameGenreLabel.textColor = UIColor.white;
		
		tCell.cellElement = tGameSubjectLabel; tCell.cellSubElement = tGameGenreLabel;
		tCell.cellImageViewElement = tGameThumbnailsPicture;
		
		tCell.cellID = "alarmGame";
		
		tCell.accessoryType = .disclosureIndicator;
		tCell.addSubview(tGameSubjectLabel); tCell.addSubview(tGameGenreLabel);
		
		tableCells += [tCell];
		return tCell;
	}
	
	
	//Tableview cell view create
	func createCell( _ cellType:Int, cellID:String ) -> AlarmSettingsCell {
		let tCell:AlarmSettingsCell = AlarmSettingsCell();
		tCell.cellID = cellID;
		tCell.backgroundColor = UIColor.white;
		tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 45); //default cell size
		
		switch( cellType ) {
			case 0: //Inputtext cell
				let alarmNameInput:UITextField = UITextField(frame: tCell.frame);
				//alarmMemo
				switch(cellID) {
					case "alarmName":
						alarmNameInput.placeholder = LanguagesManager.$("alarmTitle");
						break;
					case "alarmMemo":
						alarmNameInput.placeholder = LanguagesManager.$("alarmMemo");
						break;
					default:
						alarmNameInput.placeholder = "";
						break;
				} //end switch
				
				alarmNameInput.borderStyle = UITextBorderStyle.none;
				alarmNameInput.autocorrectionType = UITextAutocorrectionType.no;
				alarmNameInput.keyboardType = UIKeyboardType.default;
				alarmNameInput.returnKeyType = UIReturnKeyType.done;
				alarmNameInput.clearButtonMode = UITextFieldViewMode.never;
				alarmNameInput.contentVerticalAlignment = UIControlContentVerticalAlignment.center;
				alarmNameInput.textAlignment = .center;
				alarmNameInput.delegate = self;
				
				tCell.cellElement = alarmNameInput;
				tCell.addSubview(alarmNameInput);
				break;
			case 1: //DatePicker cell
				tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 200); //cell size to datepicker size fit
				let alarmTimePicker:UIDatePicker = UIDatePicker(frame: tCell.frame);
				alarmTimePicker.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 200);
				alarmTimePicker.datePickerMode = UIDatePickerMode.time;
				alarmTimePicker.date = Date(); //default => current
				//alarmTimePicker.fr
				tCell.cellElement = alarmTimePicker;
				tCell.addSubview(alarmTimePicker);
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
		}
		
		tableCells += [tCell];
		return tCell;
	}
	
	
	internal func autoSelectRepeatElement( _ repeatInfo:Array<Bool> ) {
		let settingsLabelPointer:UILabel = getElementFromTable("alarmRepeatSetting") as! UILabel;
		settingsLabelPointer.text = AlarmManager.fetchRepeatLabel(repeatInfo, loadType: 0);
	}
	
	//clear all components
	internal func clearComponents() {
		(self.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = Date(); //date to current
		(self.getElementFromTable("alarmName") as! UITextField).text = ""; //empty alarm name
		(self.getElementFromTable("alarmMemo") as! UITextField).text = ""; //empty alarm memo
		self.setSoundElement(SoundManager.list[0]); //default - first element of soundlist
		self.setGameElement(-1); //set default to random
		
		gameSelectedID = -1; //clear selected game id
		self.resetAlarmRepeatCell();
		
		modalView.title = LanguagesManager.$("alarmSettings"); //Modal title set to alarmsettings
		
		isAlarmEditMode = false; //AddMode
		alarmDefaultStatus = true; //default on
		editingAlarmID = -1;
		confirmed = false;
		
		alarmCurrentSoundLevel = 80; //default size
		
		self.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
	}
	
	//components fill for modify alarm
	internal func fillComponentsWithEditMode( _ alarmID:Int, alarmName:String, alarmMemo:String, alarmFireDate:Date, selectedGameID:Int, scaledSoundLevel:Int, selectedSoundFileName:String, repeatInfo:Array<Bool>, alarmDefaultToggle:Bool) {
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
	internal func resetAlarmRepeatCell() {
		let resetedRepeatInfo:Array<Bool> = [false, false, false, false, false, false, false];
		autoSelectRepeatElement( resetedRepeatInfo );
		currentRepeatMode = resetedRepeatInfo;
		
		//alarmRepeatSelectListView.setSelectedCell( resetedRepeatInfo );
	}
	
	
}
