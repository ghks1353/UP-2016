//
//  StatisticsDataPointView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 22..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class StatisticsDataPointView:UIModalPopView, UITableViewDataSource, UITableViewDelegate {
	
	//Data point
	static let POINT_UNTIL_OFF:String = "ualarmoff"
	static let POINT_UNTIL_START:String = "ugamestart"
	static let POINT_PLAYTIME:String = "playtime"
	
	static let POINT_GAME_CLEARED:String = "gameclrpercent"
	static let POINT_GAME_TOUCHES:String = "gametouches"
	static let POINT_GAME_VALID:String = "gamevalidtouch"
	static let POINT_GAME_ASLEEP:String = "gameasleepcount"
	
	//클래스 외부접근을 위함
	static var selfView:StatisticsDataPointView?
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped);	var tablesArray:Array<Array<AnyObject>> = []
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("statsDataPoint") );
		StatisticsDataPointView.selfView = self
		
		//add table to modals
		tableView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height)
		self.view.addSubview(tableView)
		
		//add table cells (options)
		tablesArray = [
			[ /* section 1 */
				createCell(LanguagesManager.$("statsTitleUntilAlarmOff"), cellID: StatisticsDataPointView.POINT_UNTIL_OFF),
				createCell(LanguagesManager.$("statsTitleUntilGameStart"), cellID: StatisticsDataPointView.POINT_UNTIL_START),
				createCell(LanguagesManager.$("statsTitleGamePlayTime"), cellID: StatisticsDataPointView.POINT_PLAYTIME)
			],
			[ /* section 2 */
				createCell(LanguagesManager.$("statsTitleGameClearPercent"), cellID: StatisticsDataPointView.POINT_GAME_CLEARED),
				createCell(LanguagesManager.$("statsTitleTouches"), cellID: StatisticsDataPointView.POINT_GAME_TOUCHES),
				createCell(LanguagesManager.$("statsTitleVaildTouchPercent"), cellID: StatisticsDataPointView.POINT_GAME_VALID),
				createCell(LanguagesManager.$("statsTitleFellAsleepCount"), cellID: StatisticsDataPointView.POINT_GAME_ASLEEP)
			]
		] ////////
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
	} /////// end func
	
	override func viewWillDisappear(_ animated: Bool) {
		StatisticsView.selfView!.drawMainGraph() //설정이 바뀌었으니, 그래프를 다시 그림
	}
	
	//////////////////////////////////////////
	///// for table func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellObj:CustomTableCell = tableView.cellForRow(at: indexPath) as! CustomTableCell
		
		for j:Int in 0 ..< tablesArray.count {
			for i:Int in 0 ..< (tablesArray[j] as! Array<CustomTableCell>).count {
				(tablesArray[j] as! Array<CustomTableCell>)[i].accessoryType = .none
			}
		} //end for
		cellObj.accessoryType = .checkmark
		
		//Sel to root
		StatisticsView.selfView!.rootSelectedCurrentDataPoint = cellObj.cellID
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return LanguagesManager.$("statsDataCategoryTime")
			case 1:
				return LanguagesManager.$("statsDataCategoryGame")

			default:
				return ""
		} ///end switch
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] ).count
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch((indexPath as NSIndexPath).section){
			default:
				break
		} //end switch
		
		return UITableViewAutomaticDimension
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section] )[(indexPath as NSIndexPath).row] as! UITableViewCell
		return cell
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 28 //0.0001;
	}
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 8
	} ///////////////////////////////////////////////////
	
	//Tableview cell view create
	func createCell( _ cellName:String, cellID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell()
		tCell.backgroundColor = UIColor.white
		tCell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45) //default cell size
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3)
		switch(cellID) { //특정 조건으로 아이콘 구분
			case StatisticsDataPointView.POINT_UNTIL_OFF: tIconFileStr = "comp-icons-datacategory-untiloff"; break;
			case StatisticsDataPointView.POINT_UNTIL_START: tIconFileStr = "comp-icons-datacategory-untilstart"; break;
			case StatisticsDataPointView.POINT_PLAYTIME: tIconFileStr = "comp-icons-datacategory-playtime"; break;
			case StatisticsDataPointView.POINT_GAME_VALID: tIconFileStr = "comp-icons-datacategory-validratio"; break;
			case StatisticsDataPointView.POINT_GAME_CLEARED: tIconFileStr = "comp-icons-datacategory-compratio"; break;
			case StatisticsDataPointView.POINT_GAME_ASLEEP: tIconFileStr = "comp-icons-datacategory-asleepcount"; break;
			case StatisticsDataPointView.POINT_GAME_TOUCHES: tIconFileStr = "comp-icons-datacategory-alltouches"; break;
			default:
				tIconFileStr = "comp-icons-blank"
				break
		} //end switch
		tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8
		tIconImg.image = UIImage( named: tIconFileStr + ".png" )
		tCell.addSubview(tIconImg)
		
		let tLabel:UILabel = UILabel()
		tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: tableView.frame.width * 0.85, height: 45)
		tLabel.font = UIFont.systemFont(ofSize: 16)
		tLabel.text = cellName
		
		tCell.accessoryType = UITableViewCellAccessoryType.none
		tCell.cellID = cellID //for sel evt
		
		tCell.addSubview(tLabel)
		return tCell
	} //////
	
	//Set selected style from other view (accessable)
	func setSelectedCell(_ cellID:String) {
		if (tablesArray.count == 0) {
			return
		} //end if
		
		for j:Int in 0 ..< tablesArray.count {
			for i:Int in 0 ..< (tablesArray[j] as! Array<CustomTableCell>).count {
				if ((tablesArray[j] as! Array<CustomTableCell>)[i].cellID == cellID) {
					(tablesArray[j] as! Array<CustomTableCell>)[i].accessoryType = .checkmark
				} else {
					(tablesArray[j] as! Array<CustomTableCell>)[i].accessoryType = .none
				} //end if
			} //end for [i]
		} //end for [j]
	} //end func
	
}
