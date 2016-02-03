//
//  AddAlarmView.swift
//  	
//
//  Created by ExFl on 2016. 1. 31..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//


import Foundation
import UIKit

class AddAlarmView:UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate  {
	
	//클래스 외부접근을 위함
	static var selfView:AddAlarmView?;
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	//var navigationCtrl:UINavigationController = UINavigationController();
	var navigation:UINavigationBar = UINavigationBar();
	
	//Table for view
	var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<AnyObject> = [];
	var tableCells:Array<AlarmSettingsCell> = [];
	
	internal var showBlur:Bool = true;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		AddAlarmView.selfView = self;
		
		//ModalView
		modalView.view.backgroundColor = colorWithHexString("#FAFAFA");
		self.view.addSubview(modalView.view);
		
		
		//Modal components in...
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		let naviItems:UINavigationItem = UINavigationItem();
		navigation.barTintColor = colorWithHexString("#1C6A94");
		navigation.titleTextAttributes = titleDict as? [String : AnyObject];
		naviItems.rightBarButtonItem = UIBarButtonItem(title: Languages.$("generalClose"), style: .Plain, target: self, action: "viewCloseAction");
		naviItems.rightBarButtonItem?.tintColor = colorWithHexString("#FFFFFF");
		naviItems.leftBarButtonItem?.tintColor = colorWithHexString("#FFFFFF");
		naviItems.title = Languages.$("addAlarm");
		navigation.items = [naviItems];
		navigation.frame = CGRectMake(0, 0, modalView.view.frame.width, 42);
		//navigation.delegate = modalView;
		//modalView.present
		modalView.view.addSubview(navigation);
		

		//add table to modals
		tableView.frame = CGRectMake(0, 42, modalView.view.frame.width, modalView.view.frame.height - 42);
		tableView.rowHeight = UITableViewAutomaticDimension;
		modalView.view.addSubview(tableView);
		
		//add table cells (options)
		tablesArray = [
			[ /* section 1 */
				createCell(0, cellID: "alarmName")
			],
			[ /* section 2 */
				createCell(1, cellID: "alarmDatePicker")
			],
			[ /* section 3 */
				createCell(2, cellID: "alarmGame"),
				createCell(2, cellID: "alarmSound")
			]
		];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = modalView.view.backgroundColor;
		
	}
	
	//cell touchevent
	internal func cellFunc(cellID:String) {
		switch(cellID) {
			case "alarmSound":
				//TODO for Segue (Navigationbar segue)
				
				break
			default: break;
		}
		print("cell", cellID);
	}
	
	//for default setting at view opening
	internal func getElementFromTable(cellID:String)->AnyObject? {
		//let anyobjectOfTable:AnyObject?;
		for (var i:Int = 0; i < tableCells.count; ++i) {
			if (tableCells[i].cellID == cellID) {
				return tableCells[i].cellElement!;
			}
		}
		return nil;
	}
	
	func setupModalView(frame:CGRect) {
		modalView.view.frame = frame;
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		if (showBlur) {
			ViewController.viewSelf?.showHideBlurview(false);
		}
		self.dismissViewControllerAnimated(true, completion: nil);
	}
	
	///// for table func
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 3;
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
			case 1:
				return 200;
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
	func createCell( cellType:Int, cellID:String ) -> AlarmSettingsCell {
		let tCell:AlarmSettingsCell = AlarmSettingsCell();
		tCell.cellID = cellID;
		tCell.backgroundColor = colorWithHexString("#FFFFFF");
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45); //default cell size
		
		switch( cellType ) {
			case 0: //Inputtext cell
				let alarmNameInput:UITextField = UITextField(frame: tCell.frame);
				alarmNameInput.placeholder = Languages.$("alarmTitle");
				alarmNameInput.borderStyle = UITextBorderStyle.None;
				alarmNameInput.autocorrectionType = UITextAutocorrectionType.No;
				alarmNameInput.keyboardType = UIKeyboardType.Default;
				alarmNameInput.returnKeyType = UIReturnKeyType.Done;
				alarmNameInput.clearButtonMode = UITextFieldViewMode.Never;
				alarmNameInput.contentVerticalAlignment = UIControlContentVerticalAlignment.Center;
				alarmNameInput.textAlignment = .Center;
				alarmNameInput.delegate = self;
				
				tCell.cellElement = alarmNameInput;
				tCell.addSubview(alarmNameInput);
				break;
			case 1: //DatePicker cell
				tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 200); //cell size to datepicker size fit
				let alarmTimePicker:UIDatePicker = UIDatePicker(frame: tCell.frame);
				alarmTimePicker.datePickerMode = UIDatePickerMode.Time;
				alarmTimePicker.date = NSDate(); //default => current
				//alarmTimePicker.fr
				tCell.cellElement = alarmTimePicker;
				tCell.addSubview(alarmTimePicker);
				break;
			
			case 2: //Option sel label cell
				let tLabel:UILabel = UILabel(); let tSettingLabel:UILabel = UILabel();
				tLabel.frame = CGRectMake(16, 0, self.modalView.view.frame.width * 0.4, 45);
				tSettingLabel.frame = CGRectMake(self.modalView.view.frame.width - self.modalView.view.frame.width * 0.5 - 32, 0, self.modalView.view.frame.width * 0.5, 45);
				tSettingLabel.textAlignment = .Right;
				tLabel.font = UIFont.systemFontOfSize(16); tSettingLabel.font = tLabel.font;
				tSettingLabel.textColor = colorWithHexString("#CCCCCC");
				
				switch(cellID) {
					case "alarmGame":
						tLabel.text = Languages.$("alarmGame");
						break;
					case "alarmSound":
						tLabel.text = Languages.$("alarmSound");
						break;
					default: break;
				}
				
				tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
				
				//tCell.cellElement =
				tSettingLabel.text = Languages.$("generalDefault");
				tCell.addSubview(tLabel); tCell.addSubview(tSettingLabel);
				break;
			
			default:
				return tCell; //return empty cell
		}
		
		/*
		let tLabel:UILabel = UILabel();
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRectMake(16, 0, self.modalView.frame.width * 0.75, CGFloat(45));
		tCell.addSubview(tLabel);
		tLabel.text = name;
		tLabel.font = UIFont.systemFontOfSize(16);
		*/
		
		tCell.selectionStyle = UITableViewCellSelectionStyle.None;
		tableCells += [tCell];
		return tCell;
	}
	
	//UITextfield del
	func textFieldShouldReturn(textField: UITextField) -> Bool { //Returnkey to hide
		self.view.endEditing(true);
		return false;
	}
	
	
	//////////////////comment
	
	func colorWithHexString (hex:String) -> UIColor {
		var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
		
		if (cString.hasPrefix("#")) {
			cString = (cString as NSString).substringFromIndex(1)
		}
		
		if (cString.characters.count != 6) {
			return UIColor.grayColor()
		}
		
		let rString = (cString as NSString).substringToIndex(2)
		let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
		let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
		
		var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
		NSScanner(string: rString).scanHexInt(&r)
		NSScanner(string: gString).scanHexInt(&g)
		NSScanner(string: bString).scanHexInt(&b)
		
		
		return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
	}
}