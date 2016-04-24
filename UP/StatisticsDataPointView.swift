//
//  StatisticsDataPointView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 22..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;

class StatisticsDataPointView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//Data point
	static let POINT_UNTIL_OFF:String = "ualarmoff";
	static let POINT_UNTIL_START:String = "ugamestart";
	static let POINT_PLAYTIME:String = "playtime";
	
	static let POINT_GAME_CLEARED:String = "gameclrpercent";
	static let POINT_GAME_TOUCHES:String = "gametouches";
	static let POINT_GAME_VALID:String = "gamevalidtouch";
	static let POINT_GAME_ASLEEP:String = "gameasleepcount";
	
	//클래스 외부접근을 위함
	static var selfView:StatisticsDataPointView?;
	
	//Table for view
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		StatisticsDataPointView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("statsDataPoint");
		
		//add table to modals
		tableView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		self.view.addSubview(tableView);
		
		//add table cells (options)
		tablesArray = [
			[ /* section 1 */
				createCell(Languages.$("statsTitleUntilAlarmOff"), cellID: StatisticsDataPointView.POINT_UNTIL_OFF),
				createCell(Languages.$("statsTitleUntilGameStart"), cellID: StatisticsDataPointView.POINT_UNTIL_START),
				createCell(Languages.$("statsTitleGamePlayTime"), cellID: StatisticsDataPointView.POINT_PLAYTIME)
			],
			[ /* section 2 */
				createCell(Languages.$("statsTitleGameClearPercent"), cellID: StatisticsDataPointView.POINT_GAME_CLEARED),
				createCell(Languages.$("statsTitleTouches"), cellID: StatisticsDataPointView.POINT_GAME_TOUCHES),
				createCell(Languages.$("statsTitleVaildTouchPercent"), cellID: StatisticsDataPointView.POINT_GAME_VALID),
				createCell(Languages.$("statsTitleFellAsleepCount"), cellID: StatisticsDataPointView.POINT_GAME_ASLEEP)
			]
		];
		
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillDisappear(animated: Bool) {
		StatisticsView.selfView!.drawMainGraph(); //설정이 바뀌었으니, 그래프를 다시 그림
	}
	
	///// for table func
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cellObj:CustomTableCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableCell;
		
		for j:Int in 0 ..< tablesArray.count {
			for i:Int in 0 ..< (tablesArray[j] as! Array<CustomTableCell>).count {
				(tablesArray[j] as! Array<CustomTableCell>)[i].accessoryType = .None;
			}
		}
		cellObj.accessoryType = .Checkmark;
		
		//Sel to root
		StatisticsView.selfView!.rootSelectedCurrentDataPoint = cellObj.cellID;
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2;
	}
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			case 0:
				return Languages.$("statsDataCategoryTime");
			case 1:
				return Languages.$("statsDataCategoryGame");

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
		
		return UITableViewAutomaticDimension;
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 28; //0.0001;
	}
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 8;
	}
	
	
	//Tableview cell view create
	func createCell( cellName:String, cellID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		tCell.backgroundColor = UIColor.whiteColor();
		tCell.frame = CGRectMake(0, 0, tableView.frame.width, 45); //default cell size
		
		let tLabel:UILabel = UILabel();
		tLabel.frame = CGRectMake(16, 0, tableView.frame.width * 0.85, 45);
		tLabel.font = UIFont.systemFontOfSize(16);
		tLabel.text = cellName;
		
		tCell.accessoryType = UITableViewCellAccessoryType.None;
		tCell.cellID = cellID; //for sel evt
		
		tCell.addSubview(tLabel);
		return tCell;
	}
	
	//Set selected style from other view (accessable)
	func setSelectedCell(cellID:String) {
		if (tablesArray.count == 0) {
			return;
		}
		
		for j:Int in 0 ..< tablesArray.count {
			for i:Int in 0 ..< (tablesArray[j] as! Array<CustomTableCell>).count {
				if ((tablesArray[j] as! Array<CustomTableCell>)[i].cellID == cellID) {
					(tablesArray[j] as! Array<CustomTableCell>)[i].accessoryType = .Checkmark;
				} else {
					(tablesArray[j] as! Array<CustomTableCell>)[i].accessoryType = .None;
				}
			}
		}
		
	}
	
}