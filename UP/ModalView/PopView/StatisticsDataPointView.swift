//
//  StatisticsDataPointView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 22..
//  Copyright © 2016년 Project UP. All rights reserved.
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
	
	func popToRootAction() {
		//Pop to root by back button
		self.navigationController?.popViewControllerAnimated(true);
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
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRectMake(12, 6, 31.3, 31.3);
		switch(cellID) { //특정 조건으로 아이콘 구분
			case StatisticsDataPointView.POINT_UNTIL_OFF: tIconFileStr = "comp-icons-datacategory-untiloff"; break;
			case StatisticsDataPointView.POINT_UNTIL_START: tIconFileStr = "comp-icons-datacategory-untilstart"; break;
			case StatisticsDataPointView.POINT_PLAYTIME: tIconFileStr = "comp-icons-datacategory-playtime"; break;
			case StatisticsDataPointView.POINT_GAME_VALID: tIconFileStr = "comp-icons-datacategory-validratio"; break;
			case StatisticsDataPointView.POINT_GAME_CLEARED: tIconFileStr = "comp-icons-datacategory-compratio"; break;
			case StatisticsDataPointView.POINT_GAME_ASLEEP: tIconFileStr = "comp-icons-datacategory-asleepcount"; break;
			case StatisticsDataPointView.POINT_GAME_TOUCHES: tIconFileStr = "comp-icons-datacategory-alltouches"; break;
			default:
				tIconFileStr = "comp-icons-blank";
				break;
		}; tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
		let tLabel:UILabel = UILabel();
		tLabel.frame = CGRectMake(tIconWPadding, 0, tableView.frame.width * 0.85, 45);
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