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
				createBarChartTableCell(),
				createLineChartTableCell()
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
				return 180;
			default:
				return UITableViewAutomaticDimension;
		}
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch( section ) {
			case 0:
				return 0.0001;
			default:
				return 38;
		}
		
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
	
	
	//바 차트 테이블 셀 생성
	func createBarChartTableCell() -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tMultipleChart:BarChartView = BarChartView(); //차트 뷰
        let yAxisNumberFormatter:NSNumberFormatter = NSNumberFormatter();
		yAxisNumberFormatter.numberStyle = .NoStyle; //숫자 표현 방법. NoStyle이면 포맷 안함
		yAxisNumberFormatter.positiveSuffix = "분"; //positiveSuffix -> 숫자 뒤에 붙는 문자
		
		//Chart title
		let tChartTitleLabel:UILabel = UILabel();
		tChartTitleLabel.text = "알람 해제까지";
		tChartTitleLabel.font = UIFont.systemFontOfSize(17);
		tChartTitleLabel.frame = CGRectMake(16, 10, self.modalView.view.frame.width / 1.25, 24);
		tChartTitleLabel.textColor = UIColor.whiteColor();
		
		//Chart subtitle
		let tChartSubtitleLabel:UILabel = UILabel();
		tChartSubtitleLabel.text = "평균 99분";
		tChartSubtitleLabel.font = UIFont.systemFontOfSize(13);
		tChartSubtitleLabel.frame = CGRectMake(self.modalView.view.frame.width / 2 - 6, 13, self.modalView.view.frame.width / 2 - 6, 24);
		tChartSubtitleLabel.textAlignment = .Right;
		tChartSubtitleLabel.textColor = UIColor.whiteColor();
		
		//Add to cell view
		tCell.addSubview(tChartTitleLabel); tCell.addSubview(tChartSubtitleLabel);
		
        //gradient background
        let gradient:CAGradientLayer = CAGradientLayer();
        gradient.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 180);
		// 그래디언트 시작컬러, 끝컬러 지정
        gradient.colors = [ UPUtils.colorWithHexString("0082ED").CGColor , UPUtils.colorWithHexString("005396").CGColor ];
        tCell.layer.insertSublayer(gradient, atIndex: 0); // 셀 레이어로 추가
		
		//셀 크기 지정
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 180);
		//차트 크기 지정
		tMultipleChart.frame = CGRectMake(0, 28, self.modalView.view.frame.width, 140);
		
		//User-interaction 해제 부분
		tMultipleChart.pinchZoomEnabled = false;
		tMultipleChart.setScaleEnabled(false);
		tMultipleChart.doubleTapToZoomEnabled = false;
        tMultipleChart.legend.enabled = false;
        tMultipleChart.dragEnabled = false;
        tMultipleChart.highlightPerTapEnabled = false;
		
		//오른쪽 아래 차트에 오버레이되는 라벨 텍스트
		tMultipleChart.descriptionText = "";
		
		//주변 선 그리지 않도록 무시
		tMultipleChart.drawBordersEnabled = false;
		
		//가로줄 라벨 아래로
		tMultipleChart.xAxis.labelPosition = .Bottom;
		//그리드 라인 그림 여부
		tMultipleChart.xAxis.drawGridLinesEnabled = false;
		//Axis 라벨 위의 라인 표시 여부
		tMultipleChart.xAxis.drawAxisLineEnabled = true;
		
		//라인 컬러 및 라벨 컬러
		tMultipleChart.xAxis.axisLineColor = UIColor.whiteColor();
		tMultipleChart.xAxis.labelTextColor = UIColor.whiteColor();
		
		//스킵이 있을 경우, 너비와 상관 없이 가로 라벨을 생략하므로 0으로 설정하여 생략이 없게 설정
		tMultipleChart.xAxis.setLabelsToSkip(0);
		
		//왼쪽 yAxis 표시 안함
		tMultipleChart.leftYAxisRenderer.yAxis!.enabled = false;
		
		//오른쪽 yAxis의 라벨을 바깥으로 보냄
		tMultipleChart.rightYAxisRenderer.yAxis!.labelPosition = .OutsideChart;
		
		//그리드 라인, ZeroLine, AxisLine 그리지 않음 설정
		tMultipleChart.rightYAxisRenderer.yAxis!.drawGridLinesEnabled = false;
        tMultipleChart.rightYAxisRenderer.yAxis!.drawZeroLineEnabled = false;
        tMultipleChart.rightYAxisRenderer.yAxis!.drawAxisLineEnabled = false;
		
		//~분 포맷
        tMultipleChart.rightYAxisRenderer.yAxis!.valueFormatter = yAxisNumberFormatter;
		
		//라벨 컬러 지정
        tMultipleChart.rightYAxisRenderer.yAxis!.labelTextColor = UIColor.whiteColor();
		tMultipleChart.rightYAxisRenderer.yAxis!.axisMinValue = 0;
		tMultipleChart.rightYAxisRenderer.yAxis!.showOnlyMinMaxEnabled = true;
		
		//데이터 차트 맨 위쪽에 구분선 그림. (xAxis를 상하에 배치하면 라벨도 같이 배치되므로 이렇게 함)
		let tYaxisTopLine:ChartLimitLine = ChartLimitLine(limit: 24, label: ""); //limit 부분은 데이터의 최대치로 지정해야함.
		tYaxisTopLine.lineColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5);
		tYaxisTopLine.lineWidth = 1;
		//표에 구분선 추가
		tMultipleChart.rightYAxisRenderer.yAxis!.addLimitLine(tYaxisTopLine);
		
		//DataEntry라는 배열 항목으로 정리하여 데이터가 들어가는듯 함.
		var tDataEntries:Array<BarChartDataEntry> = [];
		//실제 데이터를 여기다 넣을 예정
		var exampleDatas:Array<Double> = [12, 3, 8, 24, 9, 14, 16];
		//xAxis (가로줄) 에 나타나는 데이터는 실 데이터의 수와 일치해야 함
		let dataDateVals:Array<String> = ["3월 2일", "3일", "4일", "5일", "6일", "7일", "8일"];
		
		for i:Int in 0 ..< exampleDatas.count {
			let dataEntry = BarChartDataEntry( value: exampleDatas[i], xIndex: i );
			tDataEntries.append( dataEntry ); //DataEntry 객체로 만들어서 넣음.
		} //end for
		
		//DataSet 지정(하나의 legend라고 생각하면 됨)
		let chartDataSet:BarChartDataSet = BarChartDataSet( yVals: tDataEntries, label: "" );
		//종합적인 차트 데이터를 하나로 묶어야 함. dataSet는 단일이 아닌 배열로 줄 수도 있음
		let chartData = BarChartData(xVals: dataDateVals, dataSet: chartDataSet );
		
		//막대와의 간격 지정. 클수록 반대로 바 차트의 막대 크기는 줄어듦
		chartDataSet.barSpace = 0.8;
		chartDataSet.drawValuesEnabled = false; //값 표시 안함
		//막대 색 설정. 알파 적용을 위해 RGB 입력
        chartDataSet.setColor( UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5) );
        //데이터 적용
		tMultipleChart.data = chartData;
		
		//최대치 설정. 최대치는 여기서 설정해야 버그없이 작동함.
		tMultipleChart.rightYAxisRenderer.yAxis!.axisMaxValue = 24;
		
		//뷰에 차트 추가
		tCell.addSubview(tMultipleChart);
		return tCell;
	} //함수 끝
	
	//라인차트 테이블 셀 생성
	func createLineChartTableCell() -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tMultipleChart:LineChartView = LineChartView(); //차트 뷰
		let yAxisNumberFormatter:NSNumberFormatter = NSNumberFormatter();
		yAxisNumberFormatter.numberStyle = .NoStyle; //숫자 표현 방법. NoStyle이면 포맷 안함
		yAxisNumberFormatter.positiveSuffix = "분"; //positiveSuffix -> 숫자 뒤에 붙는 문자
		
		//Chart title
		let tChartTitleLabel:UILabel = UILabel();
		tChartTitleLabel.text = "알람 해제까지 (Line)";
		tChartTitleLabel.font = UIFont.systemFontOfSize(17);
		tChartTitleLabel.frame = CGRectMake(16, 10, self.modalView.view.frame.width / 1.25, 24);
		tChartTitleLabel.textColor = UIColor.whiteColor();
		
		//Chart subtitle
		let tChartSubtitleLabel:UILabel = UILabel();
		tChartSubtitleLabel.text = "2016.03";
		tChartSubtitleLabel.font = UIFont.systemFontOfSize(13);
		tChartSubtitleLabel.frame = CGRectMake(self.modalView.view.frame.width / 2 - 6, 13, self.modalView.view.frame.width / 2 - 6, 24);
		tChartSubtitleLabel.textAlignment = .Right;
		tChartSubtitleLabel.textColor = UIColor.whiteColor();
		
		//Add to cell view
		tCell.addSubview(tChartTitleLabel); tCell.addSubview(tChartSubtitleLabel);
		
		//gradient background
		let gradient:CAGradientLayer = CAGradientLayer();
		gradient.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 180);
		// 그래디언트 시작컬러, 끝컬러 지정
		gradient.colors = [ UPUtils.colorWithHexString("FFCE08").CGColor , UPUtils.colorWithHexString("FF7300").CGColor ];
		tCell.layer.insertSublayer(gradient, atIndex: 0); // 셀 레이어로 추가
		
		//셀 크기 지정
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 180);
		//차트 크기 지정
		tMultipleChart.frame = CGRectMake(0, 28, self.modalView.view.frame.width, 140);
		
		//User-interaction 해제 부분
		tMultipleChart.pinchZoomEnabled = false;
		tMultipleChart.setScaleEnabled(false);
		tMultipleChart.doubleTapToZoomEnabled = false;
		tMultipleChart.legend.enabled = false;
		tMultipleChart.dragEnabled = false;
		tMultipleChart.highlightPerTapEnabled = false;
		
		//오른쪽 아래 차트에 오버레이되는 라벨 텍스트
		tMultipleChart.descriptionText = "";
		
		//주변 선 그리지 않도록 무시
		tMultipleChart.drawBordersEnabled = false;
		
		//가로줄 라벨 아래로
		tMultipleChart.xAxis.labelPosition = .Bottom;
		//그리드 라인 그림 여부
		tMultipleChart.xAxis.drawGridLinesEnabled = false;
		//Axis 라벨 위의 라인 표시 여부
		tMultipleChart.xAxis.drawAxisLineEnabled = true;
		
		//라인 컬러 및 라벨 컬러
		tMultipleChart.xAxis.axisLineColor = UIColor.whiteColor();
		tMultipleChart.xAxis.labelTextColor = UIColor.whiteColor();
		
		//스킵이 있을 경우, 너비와 상관 없이 가로 라벨을 생략하므로 0으로 설정하여 생략이 없게 설정
		//tMultipleChart.xAxis.setLabelsToSkip(0);
		
		//왼쪽 yAxis 표시 안함
		tMultipleChart.leftYAxisRenderer.yAxis!.enabled = false;
		
		//오른쪽 yAxis의 라벨을 바깥으로 보냄
		tMultipleChart.rightYAxisRenderer.yAxis!.labelPosition = .OutsideChart;
		
		//그리드 라인, ZeroLine, AxisLine 그리지 않음 설정
		tMultipleChart.rightYAxisRenderer.yAxis!.drawGridLinesEnabled = false;
		tMultipleChart.rightYAxisRenderer.yAxis!.drawZeroLineEnabled = false;
		tMultipleChart.rightYAxisRenderer.yAxis!.drawAxisLineEnabled = false;
		
		//~분 포맷
		tMultipleChart.rightYAxisRenderer.yAxis!.valueFormatter = yAxisNumberFormatter;
		
		//라벨 컬러 지정
		tMultipleChart.rightYAxisRenderer.yAxis!.labelTextColor = UIColor.whiteColor();
		tMultipleChart.rightYAxisRenderer.yAxis!.axisMinValue = 0;
		tMultipleChart.rightYAxisRenderer.yAxis!.showOnlyMinMaxEnabled = true;
		
		//데이터 차트 맨 위쪽에 구분선 그림. (xAxis를 상하에 배치하면 라벨도 같이 배치되므로 이렇게 함)
		/*let tYaxisTopLine:ChartLimitLine = ChartLimitLine(limit: 78, label: ""); //limit 부분은 데이터의 최대치로 지정해야함.
		tYaxisTopLine.lineColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5);
		tYaxisTopLine.lineWidth = 1;
		//표에 구분선 추가
		tMultipleChart.rightYAxisRenderer.yAxis!.addLimitLine(tYaxisTopLine);*/
		
		//DataEntry라는 배열 항목으로 정리하여 데이터가 들어가는듯 함.
		var tDataEntries:Array<ChartDataEntry> = [];
		//실제 데이터를 여기다 넣을 예정
		var exampleDatas:Array<Double> = [1, 5, 3, 9, 32, 56, 12, 54, 2, 7 ,2 ,8, 1, 78 ,15 ,8 ,2 ,8];
		//xAxis (가로줄) 에 나타나는 데이터는 실 데이터의 수와 일치해야 함
		let dataDateVals:Array<String> = ["2일", "3일", "4일", "5일", "6일", "7일", "8일", "9일", "10일", "11일", "12일", "13일", "14일", "15일", "16일"
		,"17일", "18일", "19일"];
		
		for i:Int in 0 ..< exampleDatas.count {
			let dataEntry = ChartDataEntry(value: exampleDatas[i], xIndex: i);
			tDataEntries.append( dataEntry ); //DataEntry 객체로 만들어서 넣음.
		} //end for
		
		//DataSet 지정(하나의 legend라고 생각하면 됨)
		let chartDataSet:LineChartDataSet = LineChartDataSet(yVals: tDataEntries, label: "");
		//종합적인 차트 데이터를 하나로 묶어야 함. dataSet는 단일이 아닌 배열로 줄 수도 있음
		let chartData = LineChartData(xVals: dataDateVals, dataSet: chartDataSet );
		
		chartDataSet.drawValuesEnabled = false; //값 표시 안함
		//선 색 설정. 알파 적용을 위해 RGB 입력
		chartDataSet.setColor( UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5) );
		chartDataSet.circleRadius = 2;
		chartDataSet.circleHoleColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5);
		chartDataSet.circleColors = [ UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5) ];
		chartDataSet.drawFilledEnabled = true;
		chartDataSet.fillColor = UIColor.whiteColor();
		chartDataSet.fillAlpha = 0.5;
		
		//데이터 적용
		tMultipleChart.data = chartData;
		
		//최대치 설정. 최대치는 여기서 설정해야 버그없이 작동함.
		tMultipleChart.rightYAxisRenderer.yAxis!.axisMaxValue = 78;
		
		//뷰에 차트 추가
		tCell.addSubview(tMultipleChart);
		return tCell;
	} //함수 끝
	
	
	
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