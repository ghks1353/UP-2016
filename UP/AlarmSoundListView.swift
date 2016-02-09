//
//  AlarmSoundListView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 3..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class AlarmSoundListView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:AlarmSoundListView?;
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		AlarmSoundListView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("alarmSound");
		
		//Sound list
				
		//add table to modals
		tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height);
		self.view.addSubview(tableView);
		
		//add table cells (options)
		var alarmSoundListsTableArr:Array<UITableViewCell> = [];
		for (var i:Int = 0; i < UPAlarmSoundLists.list.count; ++i) {
			alarmSoundListsTableArr += [ createCell(UPAlarmSoundLists.list[i]) ];
		}
		tablesArray = [ alarmSoundListsTableArr ];
		
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	//for default setting at view opening
	/*internal func getElementFromTable(cellID:String)->AnyObject? {
		for (var i:Int = 0; i < tableCells.count; ++i) {
			if (tableCells[i].cellID == cellID) {
				return tableCells[i].cellElement!;
			}
		}
		return nil;
	}*/
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	///// for table func
	func cellFunc( cellSoundInfoObj:SoundInfoObj ) {
		AddAlarmView.selfView!.setSoundElement(cellSoundInfoObj);
		AddAlarmView.selfView!.navigationCtrl.popToRootViewControllerAnimated(true);

		
		
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//let cellObj:AlarmSoundListCell = tableView.cellForRowAtIndexPath(indexPath) as! AlarmSoundListCell;
		
		
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
		return 12;
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
		tLabel.frame = CGRectMake(16, 0, tableView.frame.width * 0.9, 45);
		tLabel.font = UIFont.systemFontOfSize(16);
		tLabel.text = soundObj.soundLangName;
		
		tCell.soundInfoObject = soundObj;
		
		tCell.accessoryType = UITableViewCellAccessoryType.Checkmark;
		//tCell.selectionStyle = .None;
		
		tCell.addSubview(tLabel);
		return tCell;
	}
	
	//UITextfield del
	func textFieldShouldReturn(textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	
}