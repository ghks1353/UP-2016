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

class LanguageSetupView:UIModalPopView, UITableViewDataSource, UITableViewDelegate {
	
	static var selfView:LanguageSetupView?
	
	var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped)
	var tablesArray:Array<Array<AnyObject>> = []
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("settingsChangeLanguage") )
		LanguageSetupView.selfView = self
		
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height)
		self.view.addSubview(tableView)
		
		tablesArray = [
			[ /* sec 1 */
				createCell( LanguagesManager.$("settingsLanguageSystemSettings"), menuID: "default")
				, createCell("English", menuID: LanguagesManager.LanguageCode.English)
				, createCell("日本語", menuID: LanguagesManager.LanguageCode.Japanese)
				, createCell("한국어", menuID: LanguagesManager.LanguageCode.Korean)
				, createCell("中文", menuID: LanguagesManager.LanguageCode.ChineseSimp)
			] ]
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
	} ///////// end func
	
	override func viewWillAppear(_ animated: Bool) {
		var savedLang:String = ""
		if (DataManager.nsDefaults.object(forKey: DataManager.settingsKeys.language) == nil) {
			savedLang = "default"
		} else {
			savedLang = DataManager.nsDefaults.object(forKey: DataManager.settingsKeys.language) as! String
		} //end if
		
		selectCell(savedLang)
	} ////////// end func
	
	override func viewWillDisappear(_ animated: Bool) {
		////
	}
	
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellObj:CustomTableCell = tableView.cellForRow(at: indexPath) as! CustomTableCell
		selectCell(cellObj.cellID)
		
		switch(cellObj.cellID) {
			case "default":
				DataManager.nsDefaults.removeObject(forKey: DataManager.settingsKeys.language)
				break
			default:
				DataManager.nsDefaults.set(cellObj.cellID, forKey: DataManager.settingsKeys.language)
				break
		} //switch end
		DataManager.save()
		
		tableView.deselectRow(at: indexPath, animated: true)
	} //end func
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return LanguagesManager.$("settingsChangeLanguage")
			default:
				return ""
		} //// end switch
	}
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return LanguagesManager.$("settingsChangeLanguageAlert")
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
		return 38
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func createCell( _ name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell()
		let tLabel:UILabel = UILabel()
		var tIconFileStr:String = ""
		
		switch(menuID) {
			case "default":
				tIconFileStr = "comp-icons-settings-language"
				break
			case LanguagesManager.LanguageCode.Korean,
			     LanguagesManager.LanguageCode.Japanese,
			     LanguagesManager.LanguageCode.English,
			     LanguagesManager.LanguageCode.ChineseSimp: tIconFileStr = "comp-icons-settings-language-" + menuID
				break
			default:
				tIconFileStr = "comp-icons-settings-experiments"
				break
		} /// end switch
		tCell.cellID = menuID
		
		let tIconImg:UIImageView = UIImageView()
		var tIconWPadding:CGFloat = 0
		
		tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3)
		
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8
		tIconImg.image = UIImage( named: tIconFileStr + ".png" )
		tCell.addSubview(tIconImg)
		
		tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: tableView.frame.width, height: 45)
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45)
		tCell.backgroundColor = UIColor.white
		
		tCell.addSubview(tLabel)
		tLabel.text = name; tLabel.font = UIFont.systemFont(ofSize: 16)
		
		return tCell
	} /////////////// end func
	
	func selectCell( _ localeCode:String ) {
		let loc:String = localeCode == "" ? "default" : localeCode
		for i:Int in 0 ..< (tablesArray[0] as! Array<CustomTableCell>).count {
			if ((tablesArray[0] as! Array<CustomTableCell>)[i].cellID == loc) {
				(tablesArray[0] as! Array<CustomTableCell>)[i].accessoryType = .checkmark
			} else {
				(tablesArray[0] as! Array<CustomTableCell>)[i].accessoryType = .none
			} //end if
		} //end for
	} //end func
	
	
}
