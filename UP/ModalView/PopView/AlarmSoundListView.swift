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
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped)
	var tablesArray:Array<Array<AnyObject>> = []
	
	//사운드 샘플 플레이를 위함
	internal var sampSoundPlayer:AVAudioPlayer = AVAudioPlayer()
	internal var soundLoaded:Bool = false
	
	//슬라이더 포인터
	var soundSliderPointer:UISlider?
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("alarmSound") )
		AlarmSoundListView.selfView = self
		
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height)
		self.view.addSubview(tableView)
		
		//add table cells (options)
		var alarmSoundListsTableArr:Array<AlarmSoundListCell> = []
		for i:Int in 0 ..< SoundManager.list.count {
			alarmSoundListsTableArr += [ createCell(SoundManager.list[i]) ]
		} ///end for
		tablesArray = [ [ /* section 1 */
			createSliderCell()
			],
			/* section 2 */
			alarmSoundListsTableArr
		]
		
		//custom back button for pause sound
		navigationController?.setNavigationBarHidden(false, animated: true)
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
	} //end initial func
	
	override func viewWillDisappear(_ animated: Bool) {
		self.stopSound()
		
		//scale 0~1 to 0~100
		AddAlarmView.selfView!.alarmCurrentSoundLevel = Int(soundSliderPointer!.value * 100)
	} //end func
	
	/////////////////////////////
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellObj:AlarmSoundListCell = tableView.cellForRow(at: indexPath) as! AlarmSoundListCell
		if (cellObj.soundInfoObject == nil) {
			tableView.deselectRow(at: indexPath, animated: true)
			return
		}
		
		AddAlarmView.selfView!.setSoundElement(cellObj.soundInfoObject!)
		
		for i:Int in 0 ..< (tablesArray[1] as! Array<AlarmSoundListCell>).count {
			(tablesArray[1] as! Array<AlarmSoundListCell>)[i].accessoryType = .none
		}
		cellObj.accessoryType = .checkmark
		
		if (soundLoaded) {
			sampSoundPlayer.stop()
		}
		
		print("playing", cellObj.soundInfoObject!.soundFileName)
		
		let path = Bundle.main.path(forResource: cellObj.soundInfoObject!.soundFileName, ofType:nil)!
		let url = URL(fileURLWithPath: path)
		do {
			sampSoundPlayer = try AVAudioPlayer(contentsOf: url)
			sampSoundPlayer.play()
		} catch { }
		
		
		soundLoaded = true
		tableView.deselectRow(at: indexPath, animated: true)
	} ////// end func
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return LanguagesManager.$("alarmSoundLevelTitle")
			case 1:
				return LanguagesManager.$("alarmSoundSelection")
			default:
				return ""
		} //end switch
	}
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return LanguagesManager.$("alarmSoundLevelDescription")
			default:
				return ""
		} //end switch
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] ).count
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 45
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] )[(indexPath as NSIndexPath).row] as! UITableViewCell
		return cell
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 36
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		switch(section) {
			case 0:
				return 45
			default:
				return 12
		} //end switch
	} //end func
	
	/////////////////////////////////
	//Tableview cell view create
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
		
		return tCell;
	}
	
	func createCell( _ soundObj:SoundInfoObj ) -> AlarmSoundListCell {
		let tCell:AlarmSoundListCell = AlarmSoundListCell();
		tCell.backgroundColor = UIColor.white;
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45); //default cell size
		//print(tableView.frame.width);
		
		let tLabel:UILabel = UILabel();
		tLabel.frame = CGRect(x: 16, y: 0, width: tableView.frame.width * 0.85, height: 45);
		tLabel.font = UIFont.systemFont(ofSize: 16);
		tLabel.text = soundObj.soundLangName;
		
		tCell.accessoryType = UITableViewCellAccessoryType.none;
		tCell.soundInfoObject = soundObj;
		
		tCell.addSubview(tLabel);
		return tCell;
	}
	
	//Set selected style from other view (accessable)
	func setSelectedCell( _ soundObj:SoundInfoObj ) {
		for i:Int in 0 ..< (tablesArray[1] as! Array<AlarmSoundListCell>).count {
			if ((tablesArray[1] as! Array<AlarmSoundListCell>)[i].soundInfoObject?.soundFileName == soundObj.soundFileName) {
				(tablesArray[1] as! Array<AlarmSoundListCell>)[i].accessoryType = .checkmark
			} else {
				(tablesArray[1] as! Array<AlarmSoundListCell>)[i].accessoryType = .none
			}
		}
		
	}
	
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
