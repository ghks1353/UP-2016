//
//  StatisticsView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 1..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;
import Charts;

class StatisticsView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
	//Table for menu
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor()
		
		//ModalView
		modalView.view.backgroundColor = UIColor.whiteColor();
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#333333");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = "Stats";
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(SettingsView.viewCloseAction));
		modalView.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor();
		self.view.addSubview(navigationCtrl.view);
		
		//add table to modal
		tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
		modalView.view.addSubview(tableView);
		
		//add table cells (options)
		tablesArray = [
			[ /* SECTION 1 */
				createCellWithTable()
			]
			
		];
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
		
		//get data from local (stat data)
		DataManager.initDefaults();
		
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		FitModalLocationToCenter();
	}
	
	// iOS7 Background fallback
	override func viewDidAppear(animated: Bool) {
		
	} // iOS7 Background fallback end
	
	/// table setup
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			default:
				return "";
		}
	} //end func
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		//return UITableViewAutomaticDimension;
		switch(indexPath.section) {
			case 0:
				return 160;
			default:
				return UITableViewAutomaticDimension;
		}
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 38;
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	
	////////////////
	
	func setupModalView(frame:CGRect) {
		modalView.view.frame = frame;
	}
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame.origin.x = DeviceGeneral.defaultModalSizeRect.minX;
		navigationCtrl.view.frame.origin.y = DeviceGeneral.defaultModalSizeRect.minY;
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		
		ViewController.viewSelf!.showHideBlurview(false);
		self.dismissViewControllerAnimated(true, completion: nil);
	} //end close func
	
	
	
	func createCellWithTable() -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		var tMultipleChart:BarChartView = BarChartView();
		
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 160);
		tMultipleChart.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 160);
		
		tMultipleChart.pinchZoomEnabled = false;
		tMultipleChart.setScaleEnabled(false);
		tMultipleChart.doubleTapToZoomEnabled = false;
		tMultipleChart.descriptionText = "";
		
		//가로줄 라벨 아래로
		tMultipleChart.xAxis.labelPosition = .Bottom;
		tMultipleChart.xAxis.drawGridLinesEnabled = false;
		
		tMultipleChart.leftYAxisRenderer.yAxis!.enabled = false;
		tMultipleChart.rightYAxisRenderer.yAxis!.labelPosition = .InsideChart;
		tMultipleChart.rightYAxisRenderer.yAxis!.drawGridLinesEnabled = false;
		
		
		tMultipleChart.drawValueAboveBarEnabled = false;
		
		tMultipleChart.drawBordersEnabled = false;
		
		var tDataEntries:Array<BarChartDataEntry> = [];
		var exampleDatas:Array<Double> = [1, 3, 5, 6, 7, 9, 10];
		
		for i:Int in 0 ..< exampleDatas.count {
			let dataEntry = BarChartDataEntry( value: exampleDatas[i], xIndex: i );
			tDataEntries.append( dataEntry );
		}
		
		let chartDataSet:BarChartDataSet = BarChartDataSet( yVals: tDataEntries, label: "TEST" );
		let chartData = BarChartData(xVals: ["3월 2일", "3일", "4일", "5일", "6일", "7일", "8일"], dataSet: chartDataSet );
		
		chartDataSet.barSpace = 0.4;
		chartDataSet.drawValuesEnabled = false;
		
		tMultipleChart.data = chartData;
		
		tCell.addSubview(tMultipleChart);
		return tCell;
	}
	
	func createCellWithNextArrow( name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRectMake(16, 0, self.modalView.view.frame.width, 45);
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45);
		tCell.backgroundColor = UIColor.whiteColor();
		
		tCell.addSubview(tLabel);
		tLabel.text = name;
		
		tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
		tLabel.font = UIFont.systemFontOfSize(16);
		
		return tCell;
	} //end func
	
}