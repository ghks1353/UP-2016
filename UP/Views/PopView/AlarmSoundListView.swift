//
//  AlarmSoundListView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 3..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AlarmSoundListView:UIModalPopView, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:AlarmSoundListView?
	
	//Table for view
	var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped)
	var tablesArray:[[AlarmSoundListCell]] = []
	
	//사운드 샘플 플레이를 위함
	var sampSoundPlayer:AVAudioPlayer = AVAudioPlayer()
	var soundLoaded:Bool = false
	
	//슬라이더 포인터
	var soundSliderPointer:UISlider?
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("alarmSound") )
		AlarmSoundListView.selfView = self
		
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height)
		self.view.addSubview(tableView)
		
		tablesArray = [ [ /* section 1 */
			createSliderCell()
			],
			/* section 2 */
			[],
			[]
		]
		
		//custom back button for pause sound
		navigationController?.setNavigationBarHidden(false, animated: true)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
	} //end initial func
	
	func refreshCell() {
		//add table cells (options)
		var alarmSoundListsTableArr:[AlarmSoundListCell] = []
		for i:Int in 0 ..< SoundManager.list.count {
			alarmSoundListsTableArr += [ createCell(SoundManager.list[i]) ]
		} ///end for
		
		//////// Add custom-sound cells
		let customSoundsArr:[URL] = SoundManager.userSoundsURL
		var customSoundsCellArr:[AlarmSoundListCell] = []
		for i:Int in 0 ..< customSoundsArr.count {
			let tmpObj:SoundData = SoundData(soundName: "", fileName: "")
			tmpObj.soundURL = customSoundsArr[i]
			
			customSoundsCellArr += [ createCell( tmpObj ) ]
		} //end for
		
		// custom sound 없을경우 메시지.
		if (customSoundsCellArr.count == 0) {
			customSoundsCellArr += [ createCustomSoundNoExistsCell() ]
		} //end if
		
		tablesArray = [ [ /* section 1 */
			createSliderCell()
			],
			alarmSoundListsTableArr,
			customSoundsCellArr
		] //end array
		
		tableView.reloadData()
	} //end func
	
	override func viewWillAppear(_ animated: Bool) {
		//fetch my custom sounds
		SoundManager.fetchCustomSoundsList()
	} //end func
	
	override func viewWillDisappear(_ animated: Bool) {
		self.stopSound()
		
		// scale 0~1 to 0~100
		AddAlarmView.selfView!.alarmCurrentSoundLevel = Int(soundSliderPointer!.value * 100)
	} //end func
	
	override func popToRootAction() {
		
		// 음량 체크 후 적당하지 않으면 (크거나 작으면) 경고
		if ( soundSliderPointer!.value <= 0.35 ) {
			self.alert(title: LanguagesManager.$("generalWarning"), subject: LanguagesManager.$("alarmVolumeLowWarning"), promptTitle: LanguagesManager.$("generalOK"), callback: spRootHandler)
			
			return
		} else if ( soundSliderPointer!.value >= 0.75 ) {
			self.alert(title: LanguagesManager.$("generalWarning"), subject: LanguagesManager.$("alarmVolumeHighWarning"), promptTitle: LanguagesManager.$("generalOK"), callback: spRootHandler)
			
			return
		} // end if
		
		spRootHandler()
	} // end func
	
	func spRootHandler() {
		super.popToRootAction()
	} // end func
	
	/////////////////////////////
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellObj:AlarmSoundListCell = tableView.cellForRow(at: indexPath) as! AlarmSoundListCell
		if (cellObj.soundInfoObject == nil) {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		} //end if
		
		AddAlarmView.selfView!.setSoundElement(cellObj.soundInfoObject!)
		
		let alarmListCells:[AlarmSoundListCell] = tablesArray[1] + tablesArray[2]
		for i:Int in 0 ..< alarmListCells.count {
			alarmListCells[i].accessoryType = .none
		} //end for
		cellObj.accessoryType = .checkmark
		
		if (soundLoaded) {
			sampSoundPlayer.stop()
		}
		
		var sName:String = ""
		if ( cellObj.soundInfoObject!.soundFileName == "" ) {
			//Custom sound
			sName = cellObj.soundInfoObject!.soundURL!.relativePath
		} else {
			sName = cellObj.soundInfoObject!.soundFileName
			sName = Bundle.main.path(forResource: sName, ofType: nil)!
		} //end if
		
		print("[AlarmSoundListView] playing", sName)
		let url = URL(fileURLWithPath: sName)
		do {
			sampSoundPlayer = try AVAudioPlayer(contentsOf: url)
			sampSoundPlayer.play()
		} catch {
			print("[AlarmSoundListView] Sound play failed")
		} //end try-catch
		
		
		soundLoaded = true
		tableView.deselectRow(at: indexPath, animated: true)
	} ////// end func
	func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return LanguagesManager.$("alarmSoundLevelTitle")
			case 1:
				return LanguagesManager.$("alarmSoundSelection")
			case 2:
				return LanguagesManager.$("alarmCustomSound")
			default:
				return ""
		} //end switch
	}
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return LanguagesManager.$("alarmSoundLevelDescription")
			case 2:
				return LanguagesManager.$("alarmCustomSoundInformation")
			default:
				return ""
		} //end switch
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] ).count
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch(indexPath.section) {
			case 2:
				return SoundManager.userSoundsURL.count == 0 ? 90 : 45
			default:
				return 45
		} //end switch
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:AlarmSoundListCell = (tablesArray[indexPath.section] )[indexPath.row]
		return cell as UITableViewCell
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 36
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return UITableViewAutomaticDimension
		/*switch(section) {
			case 0:
				return 45
			default:
				return 12
		} //end switch*/
	} //end func
	
	/////////////////////////////////
	//Tableview cell view create
	func createCustomSoundNoExistsCell() -> AlarmSoundListCell {
		let tCell:AlarmSoundListCell = AlarmSoundListCell()
		
		tCell.backgroundColor = UIColor.white
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 90)
		
		let infoLabel:UILabel = UILabel()
		infoLabel.frame = CGRect(x: 12, y: 0, width: tCell.frame.width - 24, height: 90)
		infoLabel.font = UIFont.systemFont(ofSize: 14)
		infoLabel.textColor = UPUtils.colorWithHexString("#333333")
		infoLabel.textAlignment = .center
		infoLabel.numberOfLines = 0
		infoLabel.text = LanguagesManager.$("alarmCustomSoundNotFound")
		
		tCell.addSubview(infoLabel)
		
		return tCell
	} //end func
	
	func createSliderCell( ) -> AlarmSoundListCell {
		let tCell:AlarmSoundListCell = AlarmSoundListCell()
		tCell.backgroundColor = UIColor.white
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45) //default cell size
		
		let tSlider:UISlider = UISlider()
		tSlider.frame = CGRect(x: 9, y: 0, width: tableView.frame.width - 18, height: 45)
		tSlider.value = 0
		tSlider.minimumTrackTintColor = UPUtils.colorWithHexString("FFCC00")
		
		//let thumbImg:UIImage = UIImage(named: "comp-slider-track.png")!;
		//tSlider.setThumbImage(thumbImg, forState: UIControlState.Normal);
		//슬라이더 포인터 지정
		soundSliderPointer = tSlider
		
		tCell.addSubview(tSlider)
		
		return tCell
	}
	
	func createCell( _ soundObj:SoundData ) -> AlarmSoundListCell {
		let tCell:AlarmSoundListCell = AlarmSoundListCell()
		tCell.backgroundColor = UIColor.white
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45) //default cell size
		
		let tLabel:UILabel = UILabel()
		tLabel.frame = CGRect(x: 16, y: 0, width: tableView.frame.width * 0.85, height: 45)
		tLabel.font = UIFont.systemFont(ofSize: 16)
		
		// Custom sound일 경우, FileName표시
		if ( soundObj.soundFileName == "" ) {
			tLabel.text = soundObj.soundURL!.deletingPathExtension().lastPathComponent
		} else {
			tLabel.text = soundObj.soundLangName
		} //end if
		
		tCell.accessoryType = UITableViewCellAccessoryType.none
		tCell.soundInfoObject = soundObj
		
		tCell.addSubview(tLabel)
		return tCell
	}
	
	//Set selected style from other view (accessable)
	func setSelectedCell( _ soundObj:SoundData ) {
		let alarmListCells:[AlarmSoundListCell] = tablesArray[1] + tablesArray[2]
		
		/// Default select 0 (fallback)
		alarmListCells[0].accessoryType = .checkmark
		
		for i:Int in 0 ..< alarmListCells.count {
			if (alarmListCells[i].soundInfoObject == nil) {
				continue
			} //end if
			
			////////// sound file 이름 없을경우 custom sound 사용
			var checkStr:String = "" //리스트에서.
			var soundDataFileStr:String = "" //현재 파라메터에서.
			
			if (soundObj.soundURL != nil && alarmListCells[i].soundInfoObject!.soundURL != nil) {
				checkStr = alarmListCells[i].soundInfoObject!.soundURL!.lastPathComponent
				soundDataFileStr = soundObj.soundURL!.lastPathComponent
			} else {
				checkStr = alarmListCells[i].soundInfoObject!.soundFileName
				soundDataFileStr = soundObj.soundFileName
			} //end if
			
			if (checkStr == soundDataFileStr) {
				alarmListCells[i].accessoryType = .checkmark
			} else {
				alarmListCells[i].accessoryType = .none
			} //end if
		} //end for
	} //end func
	
	///////////////////////////
	internal func stopSound() {
		if (soundLoaded) {
			sampSoundPlayer.stop()
		} //end if
	} //end func
	
	//UITextfield del
	func textFieldShouldReturn(_ textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true)
		return false
	} //end func
} //end class
