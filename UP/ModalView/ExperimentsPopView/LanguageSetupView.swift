//
//  LanguageSetupView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//


import Foundation
import AVFoundation
import UIKit

class LanguageSetupView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	static var selfView:LanguageSetupView?;
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped);
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		LanguageSetupView.selfView = self;
		self.view.backgroundColor = .clear();
		//ModalView
		self.view.backgroundColor = UIColor.white;
		self.title = Languages.$("settingsChangeLanguage");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), for: UIControlState());
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(LanguageSetupView.popToRootAction), for: .touchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true;
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		
		tablesArray = [
			[ /* sec 1 */
				createCell( Languages.$("settingsLanguageSystemSettings"), menuID: "default")
				, createCell("한국어", menuID: "ko")
				, createCell("日本語", menuID: "ja")
				, createCell("English", menuID: "en")
			] ];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	func popToRootAction() {
		//Pop to root by back button
		self.navigationController?.popViewController(animated: true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	override func viewWillAppear(_ animated: Bool) {
		var savedLang:String = "";
		if (DataManager.nsDefaults.object(forKey: DataManager.settingsKeys.language) == nil) {
			savedLang = "default";
		} else {
			savedLang = DataManager.nsDefaults.object(forKey: DataManager.settingsKeys.language) as! String;
		}
		
		selectCell(savedLang);
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		////
	}
	
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellObj:CustomTableCell = tableView.cellForRow(at: indexPath) as! CustomTableCell;
		selectCell(cellObj.cellID);
		switch(cellObj.cellID) {
			case "default":
				DataManager.nsDefaults.removeObject(forKey: DataManager.settingsKeys.language);
				break;
			default:
				DataManager.nsDefaults.set(cellObj.cellID, forKey: DataManager.settingsKeys.language);
				break;
		} //switch end
		DataManager.save();
		
		/*let alarmCantAddAlert = UIAlertController(title: "설정 저장됨", message: "애플리케이션을 재시작하여 주세요.", preferredStyle: UIAlertControllerStyle.Alert);
		alarmCantAddAlert.addAction(UIAlertAction(title: Languages.$("generalOK"), style: .Default, handler: { (action: UIAlertAction!) in
			//Nothing do
		}));
		presentViewController(alarmCantAddAlert, animated: true, completion: nil);
		*/
		tableView.deselectRow(at: indexPath, animated: true);
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return Languages.$("settingsChangeLanguage");
			default:
				return "";
		}
	}
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return Languages.$("settingsChangeLanguageAlert");
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 45;
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] as! Array<AnyObject>)[(indexPath as NSIndexPath).row] as! UITableViewCell;
		return cell;
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 38;
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 52;
	}
	
	func createCell( _ name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel(); var tIconFileStr:String = "";
		
		switch(menuID) {
			case "default": tIconFileStr = "comp-icons-settings-language"; break;
			case "ko", "ja", "en": tIconFileStr = "comp-icons-settings-language-" + menuID; break;
			default: tIconFileStr = "comp-icons-settings-experiments"; break;
		}
		tCell.cellID = menuID;
		
		let tIconImg:UIImageView = UIImageView(); var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3);
		
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
		tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: tableView.frame.width, height: 45);
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45);
		tCell.backgroundColor = UIColor.white;
		
		tCell.addSubview(tLabel);
		tLabel.text = name; tLabel.font = UIFont.systemFont(ofSize: 16);
		
		return tCell;
	}
	
	func selectCell( _ localeCode:String ) {
		let loc:String = localeCode == "" ? "default" : localeCode;
		for i:Int in 0 ..< (tablesArray[0] as! Array<CustomTableCell>).count {
			if ((tablesArray[0] as! Array<CustomTableCell>)[i].cellID == loc) {
				(tablesArray[0] as! Array<CustomTableCell>)[i].accessoryType = .checkmark;
			} else {
				(tablesArray[0] as! Array<CustomTableCell>)[i].accessoryType = .none;
			}
		}
	}
	
	
}
