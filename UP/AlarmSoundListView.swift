//
//  AlarmSoundListView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 3..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
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
	
	override func viewDidLoad() {
		super.viewDidLoad();
		AlarmSoundListView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("alarmSound");
		
		//Sound list
				
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		
		//add table cells (options)
		var alarmSoundListsTableArr:Array<AlarmSoundListCell> = [];
		for (var i:Int = 0; i < UPAlarmSoundLists.list.count; ++i) {
			alarmSoundListsTableArr += [ createCell(UPAlarmSoundLists.list[i]) ];
		}
		tablesArray = [ alarmSoundListsTableArr ];
		
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cellObj:AlarmSoundListCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmSoundListCell;
		AddAlarmView.selfView!.setSoundElement(cellObj.soundInfoObject!);
		
		for (var i:Int = 0; i < (tablesArray[0] as! Array<AlarmSoundListCell>).count; ++i) {
			(tablesArray[0] as! Array<AlarmSoundListCell>)[i].accessoryType = .None;
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
		switch(indexPath.section){
			default:
				break;
		}
		
		if #available(iOS 8.0, *) {
			return UITableViewAutomaticDimension;
		} else {
			return 45;
		}
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 0.0001;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 0;
	}
	
	
	//Tableview cell view create
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
		for (var i:Int = 0; i < (tablesArray[0] as! Array<AlarmSoundListCell>).count; ++i) {
			if ((tablesArray[0] as! Array<AlarmSoundListCell>)[i].soundInfoObject?.soundFileName == soundObj.soundFileName) {
				(tablesArray[0] as! Array<AlarmSoundListCell>)[i].accessoryType = .Checkmark;
			} else {
				(tablesArray[0] as! Array<AlarmSoundListCell>)[i].accessoryType = .None;
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