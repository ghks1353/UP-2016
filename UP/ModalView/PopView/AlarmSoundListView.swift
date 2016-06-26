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

class AlarmSoundListView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:AlarmSoundListView?;
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<AnyObject> = [];
	
	//사운드 샘플 플레이를 위함
	internal var sampSoundPlayer:AVAudioPlayer = AVAudioPlayer();
	internal var soundLoaded:Bool = false;
	
	//슬라이더 포인터
	var soundSliderPointer:UISlider?;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		AlarmSoundListView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("alarmSound");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(AlarmSoundListView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
				
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceManager.defaultModalSizeRect.width, DeviceManager.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		
		//add table cells (options)
		var alarmSoundListsTableArr:Array<AlarmSoundListCell> = [];
		for i:Int in 0 ..< SoundManager.list.count {
			alarmSoundListsTableArr += [ createCell(SoundManager.list[i]) ];
		}
		tablesArray = [ [ /* section 1 */
			createSliderCell()
			],
			/* section 2 */
			alarmSoundListsTableArr ];
		
		//custom back button for pause sound
		navigationController?.setNavigationBarHidden(false, animated: true);
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	func popToRootAction() {
		//Pop to root by back button
		self.navigationController?.popViewControllerAnimated(true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillDisappear(animated: Bool) {
		self.stopSound();
		AddAlarmView.selfView!.alarmCurrentSoundLevel = Int(soundSliderPointer!.value * 100); //scale 0~1 to 0~100
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cellObj:AlarmSoundListCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmSoundListCell;
		if (cellObj.soundInfoObject == nil) {
			tableView.deselectRowAtIndexPath(indexPath, animated: true);
			return;
		}
		
		AddAlarmView.selfView!.setSoundElement(cellObj.soundInfoObject!);
		
		for i:Int in 0 ..< (tablesArray[1] as! Array<AlarmSoundListCell>).count {
			(tablesArray[1] as! Array<AlarmSoundListCell>)[i].accessoryType = .None;
		}
		cellObj.accessoryType = .Checkmark;
		
		if (soundLoaded) {
			sampSoundPlayer.stop();
		}
		
		print("playing", cellObj.soundInfoObject!.soundFileName);
		
		let path = NSBundle.mainBundle().pathForResource(cellObj.soundInfoObject!.soundFileName, ofType:nil)!;
		let url = NSURL(fileURLWithPath: path);
		do {
			sampSoundPlayer = try AVAudioPlayer(contentsOfURL: url);
			sampSoundPlayer.play();
		} catch { }
		
		
		soundLoaded = true;
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2;
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return Languages.$("alarmSoundLevelTitle");
			case 1:
				return Languages.$("alarmSoundSelection");
			default:
				return "";
		} //end switch
	}
	
	func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return Languages.$("alarmSoundLevelDescription");
			default:
				return "";
		} //end switch
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 45;
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 36;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		switch(section) {
			case 0:
				return 45;
			default:
				return 12;
		}
	}
	
	//Tableview cell view create
	func createSliderCell( ) -> AlarmSoundListCell {
		let tCell:AlarmSoundListCell = AlarmSoundListCell();
		tCell.backgroundColor = UIColor.whiteColor();
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 45); //default cell size
		
		let tSlider:UISlider = UISlider();
		tSlider.frame = CGRectMake(9, 0, tableView.frame.width - 18, 45);
		tSlider.value = 0;
		tSlider.minimumTrackTintColor = UPUtils.colorWithHexString("FFCC00");
		
		//let thumbImg:UIImage = UIImage(named: "comp-slider-track.png")!;
		//tSlider.setThumbImage(thumbImg, forState: UIControlState.Normal);
		//슬라이더 포인터 지정
		soundSliderPointer = tSlider;
		
		tCell.addSubview(tSlider);
		
		return tCell;
	}
	
	func createCell( soundObj:SoundInfoObj ) -> AlarmSoundListCell {
		let tCell:AlarmSoundListCell = AlarmSoundListCell();
		tCell.backgroundColor = UIColor.whiteColor();
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 45); //default cell size
		//print(tableView.frame.width);
		
		let tLabel:UILabel = UILabel();
		tLabel.frame = CGRectMake(16, 0, tableView.frame.width * 0.85, 45);
		tLabel.font = UIFont.systemFontOfSize(16);
		tLabel.text = soundObj.soundLangName;
		
		tCell.accessoryType = UITableViewCellAccessoryType.None;
		tCell.soundInfoObject = soundObj;
		
		tCell.addSubview(tLabel);
		return tCell;
	}
	
	//Set selected style from other view (accessable)
	func setSelectedCell( soundObj:SoundInfoObj ) {
		for i:Int in 0 ..< (tablesArray[1] as! Array<AlarmSoundListCell>).count {
			if ((tablesArray[1] as! Array<AlarmSoundListCell>)[i].soundInfoObject?.soundFileName == soundObj.soundFileName) {
				(tablesArray[1] as! Array<AlarmSoundListCell>)[i].accessoryType = .Checkmark;
			} else {
				(tablesArray[1] as! Array<AlarmSoundListCell>)[i].accessoryType = .None;
			}
		}
		
	}
	internal func stopSound() {
		if (soundLoaded) {
			sampSoundPlayer.stop();
		}
	}
	
	
	//UITextfield del
	func textFieldShouldReturn(textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	
}
