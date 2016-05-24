//
//  ExperimentsLanguagesSetupView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 27..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//


import Foundation
import AVFoundation
import UIKit

class ExperimentsLanguagesSetupView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	static var selfView:ExperimentsLanguagesSetupView?;
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		ExperimentsLanguagesSetupView.selfView = self;
		self.view.backgroundColor = .clearColor();
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = "강제 언어 변경";
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(ExperimentsLanguagesSetupView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true;
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		print("Adding repeat table cells");
		
		tablesArray = [
			[ /* sec 1 */
				createCell("시스템 설정 사용", menuID: "default")
				, createCell("한국어", menuID: "ko")
				, createCell("日本語", menuID: "ja")
				, createCell("English", menuID: "en")
				, createCell("힘쎄고 강한 왈도", menuID: "waldo")
			] ];
		
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
		////
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cellObj:CustomTableCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableCell;
		
		switch(cellObj.cellID) {
			case "default":
				DataManager.nsDefaults.removeObjectForKey(DataManager.EXPERIMENTS_FORCE_LANGUAGES_KEY);
				break;
			default:
				DataManager.nsDefaults.setObject(cellObj.cellID, forKey: DataManager.EXPERIMENTS_FORCE_LANGUAGES_KEY);
				break;
		} //switch end
		DataManager.save();
		
		let alarmCantAddAlert = UIAlertController(title: "설정 저장됨", message: "애플리케이션을 재시작하여 주세요.", preferredStyle: UIAlertControllerStyle.Alert);
		alarmCantAddAlert.addAction(UIAlertAction(title: Languages.$("generalOK"), style: .Default, handler: { (action: UIAlertAction!) in
			//Nothing do
		}));
		presentViewController(alarmCantAddAlert, animated: true, completion: nil);
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return "사용 가능";
			default:
				return "";
		}
	}
	func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "변경된 설정은 애플리케이션을 재시작해야 반영됩니다.";
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
		return 38;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 52;
	}
	
	func createCell( name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		
		tCell.cellID = menuID;
		
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRectMake(12, 6, 31.3, 31.3);
		tIconFileStr = "comp-icons-settings-experiments";
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
		tLabel.frame = CGRectMake(tIconWPadding, 0, tableView.frame.width, 45);
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 45);
		tCell.backgroundColor = UIColor.whiteColor();
		
		tCell.addSubview(tLabel);
		tLabel.text = name; tLabel.font = UIFont.systemFontOfSize(16);
		
		return tCell;
	}
	
	
}