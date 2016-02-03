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
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<AnyObject> = [];
	var tableCells:Array<UITableViewCell> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		
		self.title = Languages.$("alarmSound");
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height);
		tableView.rowHeight = UITableViewAutomaticDimension;
		self.view.addSubview(tableView);
		
		//add table cells (options)
		tablesArray = [
			[ createCell("default_0") ]
		];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = colorWithHexString("#FAFAFA");
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
	func createCell( cellID:String ) -> UITableViewCell {
		let tCell:UITableViewCell = UITableViewCell();
		tCell.backgroundColor = colorWithHexString("#FFFFFF");
		tCell.frame = CGRectMake(0, 0, self.view.frame.width, 45); //default cell size
		
		let tLabel:UILabel = UILabel();
		tLabel.frame = CGRectMake(16, 0, self.view.frame.width * 0.9, 45);
		tLabel.font = UIFont.systemFontOfSize(16);
		
		switch(cellID) {
			case "0":
				tLabel.text = "testsound";
				break;
			default: break;
		}
		
		tCell.accessoryType = UITableViewCellAccessoryType.None;
		
		//tCell.cellElement =
		tCell.addSubview(tLabel);
	
		
		
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