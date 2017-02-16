//
//  StatisticsView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 1..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit
import Charts

class StatisticsView:UIModalView, UITableViewDataSource, UITableViewDelegate {
	
	//클래스 외부접근을 위함
	static var selfView:StatisticsView?
	
	//Table for menu
	var tableView:UITableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 42), style: UITableViewStyle.grouped)
	var tablesArray:Array<Array<CustomTableCell>> = []
	
	//Main charts pointer
	var rootViewChartPointer:ChartViewBase? //차트에 대한 기본 클래스
	
	var rootViewChartSubtitle:UILabel?
	var rootViewChartTitle:UILabel? //제목 및 부제목
	var rootViewChartWrapperCellPointer:UIView?
	var rootViewChartBackgroundGradient:CAGradientLayer?
	
	var rootViewChartSelSegmentCell:UISegmentedControl?
	var rootViewChartNodataUILabel:UILabel?
	var rootViewChartSelectedCategory:Int = 0 //메인차트 주/월/년 구분
	
	//완주 비율 그래프일 때 나타낼 텍스트 (4개)
	var rootViewRightLFirstTitle:UILabel?
	var rootViewRightLFirstValue:UILabel?
	var rootViewRightLSecondTitle:UILabel?
	var rootViewRightLSecondValue:UILabel?
	
	//ualarmoff - 겜시작+플레이, ugamestart - 겜시작, playtime - 플레이
	var rootSelectedCurrentDataPoint:String = StatisticsDataPointView.POINT_UNTIL_OFF
	
	//Subviews
	var statsDataPointView:StatisticsDataPointView = GlobalSubView.alarmStatisticsDataPointView
	
	override func viewDidLoad() {
		super.viewDidLoad(LanguagesManager.$("userStatistics"), barColor: UPUtils.colorWithHexString("#174468"))
		StatisticsView.selfView = self
		
		//add table to modal
		tableView.frame = CGRect(x: 0, y: 0, width: modalView.view.frame.width, height: modalView.view.frame.height)
		modalView.view.addSubview(tableView)
		
		//add table cells (options)
		tablesArray = [
			[ /* SECTION 1 */
				createIntroChartCell(),
				createCellWithNextArrow(LanguagesManager.$("statsDataPoint"), menuID: "dataPoint")
			]
		] //////////////////////
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA")
		
		setSubviewSize()
	} //////////// end func load
	
	/////// View transition animation
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
		//뷰 초기 진입시 설정 초기화
		rootViewChartSelectedCategory = 0
		rootSelectedCurrentDataPoint = StatisticsDataPointView.POINT_UNTIL_OFF
		rootViewChartSelSegmentCell!.selectedSegmentIndex = 0
		
		drawMainGraph()
	} //end func
	
	///////////////////////////////////////////////
	func drawMainGraph() {
		//data fetch
		print("Getting graph data from Database")
		var selDataPointInt:Int = 0
		
		switch(rootSelectedCurrentDataPoint) {
			case StatisticsDataPointView.POINT_UNTIL_OFF:
				selDataPointInt = 0
				rootViewChartTitle!.text = LanguagesManager.$("statsTitleUntilAlarmOff")
				break
			case StatisticsDataPointView.POINT_UNTIL_START:
				selDataPointInt = 1
				rootViewChartTitle!.text = LanguagesManager.$("statsTitleUntilGameStart")
				break
			case StatisticsDataPointView.POINT_PLAYTIME:
				selDataPointInt = 2
				rootViewChartTitle!.text = LanguagesManager.$("statsTitleGamePlayTime")
				break;
			case StatisticsDataPointView.POINT_GAME_CLEARED:
				selDataPointInt = 3
				rootViewChartTitle!.text = LanguagesManager.$("statsTitleGameClearPercent")
				break
			case StatisticsDataPointView.POINT_GAME_TOUCHES:
				selDataPointInt = 4
				rootViewChartTitle!.text = LanguagesManager.$("statsTitleTouches")
				break
			case StatisticsDataPointView.POINT_GAME_VALID:
				selDataPointInt = 5
				rootViewChartTitle!.text = LanguagesManager.$("statsTitleVaildTouchPercent")
				break
			case StatisticsDataPointView.POINT_GAME_ASLEEP:
				selDataPointInt = 6
				rootViewChartTitle!.text = LanguagesManager.$("statsTitleFellAsleepCount")
				break
			default: break
		} //end switch [selectedDataPoint]
		
		//Default hidden
		rootViewRightLFirstTitle!.isHidden = true; rootViewRightLFirstValue!.isHidden = true;
		rootViewRightLSecondTitle!.isHidden = true; rootViewRightLSecondValue!.isHidden = true;
		
		//Data fetch from datamanager
		let statsDataResult:Array<StatisticsData>? = DataManager.getAlarmGraphData( rootViewChartSelectedCategory, dataPointSelection: selDataPointInt )
		
		//Set pointers
		var barChartPointer:BarChartView?
		var lineChartPointer:LineChartView?
		var pieChartPointer:PieChartView?
		
		//BGColor
		var currentBGColor:String = ""
		
		//Remove existing view
		if (rootViewChartPointer != nil) {
			rootViewChartPointer!.removeFromSuperview()
			rootViewChartPointer = nil
		} //end chk
		
		if (statsDataResult == nil) {
			//no data or error
		} else {
			//그래디언트 색은 미리 여기서 정해줍시다
			switch(selDataPointInt) {
				case 3,4,5,6: //게임 데이터 그래프 색
					switch(rootViewChartSelectedCategory) { //주 월 년?
						case 0: //보라 계열 그래디언트 색 설정
							rootViewChartBackgroundGradient!.colors = [ UPUtils.colorWithHexString("7E49B3").cgColor , UPUtils.colorWithHexString("532185").cgColor ];
							currentBGColor = "7E49B3";
							break;
						case 1, 2: //초록 계열 그래디언트 색 설정
							rootViewChartBackgroundGradient!.colors = [ UPUtils.colorWithHexString("50B354").cgColor , UPUtils.colorWithHexString("218524").cgColor ];
							currentBGColor = "50B354";
							break;
						default: break;
					}
					break;
				default: //기본 그래프 색
					switch(rootViewChartSelectedCategory) { //주 월 년?
						case 0: //파랑 계열 그래디언트 색 설정
							rootViewChartBackgroundGradient!.colors = [ UPUtils.colorWithHexString("0082ED").cgColor , UPUtils.colorWithHexString("005396").cgColor ];
							break;
						case 1, 2: //주황 계열 그래디언트 색 설정
							rootViewChartBackgroundGradient!.colors = [ UPUtils.colorWithHexString("FFA408").cgColor , UPUtils.colorWithHexString("F26100").cgColor ];
							break;
						default: break;
					}
					break;
			} //end switch
			
			if (statsDataResult!.count == 0) {
				//데이터 없음 fallback
				rootViewChartSubtitle!.text = "-";
				rootViewChartNodataUILabel!.isHidden = false;
				return;
			}
			rootViewChartNodataUILabel!.isHidden = true;
			
			//데이터 구축
			var tDataEntries:Array<BarChartDataEntry> = []; //data entries array
			var tLineDataEntries:Array<ChartDataEntry> = [];
			var tDatasXAxisEntry:Array<String> = []; //x-dayas entry (아마 날짜 표시)
			var previousMonth:Int = -1; //다음 달과 비교해서 넘어갔다고 판단되는 경우, x값에 월도 표시하기 위함
			var resultAverage:Float = 0;
			
			var currentDataPrefix:String = "";
			var currentDataSuffix:String = "";
			
			//createPredesignedPieChart
			
			//데이터별 차트 선택.
			switch(selDataPointInt) {
				case 3: //게임 포기 비율 차트
					rootViewChartPointer = createPredesignedPieChart() as ChartViewBase;
					pieChartPointer = rootViewChartPointer as? PieChartView;
					
					//element를 돌면서 성공과 비율을 먼저 구하자
					var successCount:Int = 0; var failedCount:Int = 0;
					
					for i:Int in 0 ..< statsDataResult!.count {
						if (statsDataResult![i].numberData < 1) { //== 0인데, float라 걱정되서 이렇게 검사함
							failedCount += 1; //실패 시 실패 카운트
						} else { //성공 시 성공 카운트
							successCount += 1;
						} //end if
					} //end for
					
					//카운트를 기반으로 데이터를 넣기.
					let successPercent:Double = (Double(successCount) / Double(statsDataResult!.count)) * 100;
					let failedPercent:Double = (Double(failedCount) / Double(statsDataResult!.count)) * 100;
					
					let failedDataEntry:PieChartDataEntry =
						PieChartDataEntry(value: failedPercent, label: failedCount == 0 ? "" : LanguagesManager.$("statsDataGameRetired"));
					let successDataEntry:PieChartDataEntry =
						PieChartDataEntry(value: successPercent, label: successCount == 0 ? "" : LanguagesManager.$("statsDataGameCleared"));
					let pieChartDataSet:PieChartDataSet =
						PieChartDataSet(values: [ failedDataEntry, successDataEntry ], label: "");
					
					pieChartDataSet.colors = [
						UIColor(red: 1, green: 1, blue: 1, alpha: 0.2), /* 포기 */
						UIColor(red: 1, green: 1, blue: 1, alpha: 0.82) //성공
					];
					pieChartDataSet.valueColors = [
						UIColor.white, UPUtils.colorWithHexString(currentBGColor)
					];
					
					let pieChartDatas:PieChartData = PieChartData(dataSet: pieChartDataSet);
					pieChartDatas.setDrawValues(false);
					
					pieChartPointer!.data = pieChartDatas; //data apply
					
					currentDataPrefix = ""; currentDataSuffix = LanguagesManager.$("statsDataFormatPercent");
					
					//Show pie titles
					rootViewRightLFirstTitle!.isHidden = false; rootViewRightLFirstValue!.isHidden = false;
					rootViewRightLSecondTitle!.isHidden = false; rootViewRightLSecondValue!.isHidden = false;
					
					rootViewRightLFirstValue!.text = String(round(successPercent)) + currentDataSuffix;
					rootViewRightLSecondValue!.text = String(round(failedPercent)) + currentDataSuffix;
					
					pieChartPointer!.animate( xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutCirc );
					
					break;
				default: //기타 주/연도에 따른 바/라인차트 생성
					
					switch(rootViewChartSelectedCategory) { //차트별 데이터 정리
						case 0: //use bar chart.
							rootViewChartPointer = createPredesignedBarChart() as ChartViewBase;
							barChartPointer = rootViewChartPointer as? BarChartView;
							
							for i:Int in 0 ..< statsDataResult!.count {
								let dataEntry = BarChartDataEntry(x: Double(i), y: Double(statsDataResult![i].numberData));
								tDataEntries.append( dataEntry );
								
								resultAverage += statsDataResult![i].numberData;
								
								//x축 라벨 추가를 위한 작업
								
								if (previousMonth != statsDataResult![i].dateComponents!.month) {
									previousMonth = statsDataResult![i].dateComponents!.month!;
									//Languages $0 ~ $1 되있는것 자동 변수 삽입.
									let monthStr:String = LanguagesManager.localizeMonth( String(describing: previousMonth ));
									
									tDatasXAxisEntry += [ LanguagesManager.parseStr(LanguagesManager.$("statsDateFormatWithMonth"), args: monthStr as AnyObject, statsDataResult![i].dateComponents!.day as AnyObject) ];
								} else {
									//일만 추가
									tDatasXAxisEntry += [ LanguagesManager.parseStr(LanguagesManager.$("statsDateFormatDayOnly"), args: statsDataResult![i].dateComponents!.day as AnyObject) ];
								}
							} //end for
							
							//DataSet 지정(하나의 legend라고 생각하면 됨)
							let chartDataSet:BarChartDataSet = BarChartDataSet(values: tDataEntries, label: "");
								//BarChartDataSet( yVals: tDataEntries, label: "" );
							//종합적인 차트 데이터를 하나로 묶어야 함. dataSet는 단일이 아닌 배열로 줄 수도 있음
							let chartData = BarChartData(dataSet: chartDataSet);
							chartData.barWidth = 0.07;
							
							//Visual settings
							//chartDataSet.barBorderWidth = 0.8; //before: barSpace
							chartDataSet.barBorderColor = UIColor.clear;
							chartDataSet.drawValuesEnabled = false;
							chartDataSet.setColor( UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5) ); //Chart color
							
							let tYaxisTopLine:ChartLimitLine = ChartLimitLine(limit: chartData.getYMax(), label: "");
							tYaxisTopLine.lineColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5);
							tYaxisTopLine.lineWidth = 1;
							
							//표에 구분선 추가
							barChartPointer!.rightYAxisRenderer.axis!.removeAllLimitLines(); //Reset all lines
							barChartPointer!.rightYAxisRenderer.axis!.addLimitLine(tYaxisTopLine);
							
							barChartPointer!.data = chartData; //data apply
							
							barChartPointer!.rightYAxisRenderer.axis!.axisMinimum = 0;
							barChartPointer!.rightYAxisRenderer.axis!.axisMaximum = chartData.getYMax(); //set max value
							
							barChartPointer!.rightYAxisRenderer.axis!.setLabelCount(2, force: true);
							barChartPointer!.xAxisRenderer.axis!.setLabelCount(chartData.entryCount, force: false);
							//barChartPointer!.xAxisRenderer.axis!.centerAxisLabelsEnabled = true;
							
							print("chart entrycount is ", chartData.entryCount);
							
							barChartPointer!.fitBars = true;
							
							switch(selDataPointInt) {
								case 3, 5: //~% 표기
									currentDataPrefix = ""; currentDataSuffix = LanguagesManager.$("statsDataFormatPercent");
									
									//Get average
									resultAverage = resultAverage / Float(statsDataResult!.count);
									break;
								case 4, 6: //합계 ~회 표기
									currentDataPrefix = LanguagesManager.$("statsDataFormatCountsPrefixShort");
									currentDataSuffix = LanguagesManager.$("statsDataFormatCountsSuffixShort");
									
									//Average 구할 필요 없음
									break;
								default: //평균 ~분 표기
									currentDataPrefix = LanguagesManager.$("statsTimeFormatMinPrefix");
									currentDataSuffix = LanguagesManager.$("statsTimeFormatMinSuffix");
									
									//Get average
									resultAverage = resultAverage / Float(statsDataResult!.count);
									break;
							} //end switch
							
							
							barChartPointer!.animate( xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutCirc );
							
							//X Formatter
							let defXFormatter:StrArrayFormatter = StrArrayFormatter();
							defXFormatter.strArr = tDatasXAxisEntry;
							
							//Y Formatter
							let defFormatter:NumberFormatter = NumberFormatter();
							defFormatter.positivePrefix = currentDataPrefix;
							defFormatter.positiveSuffix = currentDataSuffix;
							
							barChartPointer!.xAxisRenderer.axis!.valueFormatter = DefaultAxisValueFormatter(formatter: defXFormatter);
							barChartPointer!.rightYAxisRenderer.axis!.valueFormatter = DefaultAxisValueFormatter(formatter: defFormatter);
							
							break;
						case 1, 2: //use line chart.
							rootViewChartPointer = createPredesignedLineChart() as ChartViewBase;
							lineChartPointer = rootViewChartPointer as? LineChartView;
							
							for i:Int in 0 ..< statsDataResult!.count {
								let dataEntry = ChartDataEntry(x: Double(i), y: Double(statsDataResult![i].numberData));
									//ChartDataEntry( value: Double(statsDataResult![i].numberData), xIndex: i );
								tLineDataEntries.append( dataEntry );
								
								resultAverage += statsDataResult![i].numberData;
								
								//x축 라벨 추가를 위한 작업
								if (previousMonth != statsDataResult![i].dateComponents!.month) {
									previousMonth = statsDataResult![i].dateComponents!.month!;
									//Languages $0 ~ $1 되있는것 자동 변수 삽입.
									let monthStr:String = LanguagesManager.localizeMonth( String(describing: previousMonth) );
									
									tDatasXAxisEntry += [ LanguagesManager.parseStr(LanguagesManager.$("statsDateFormatWithMonth"), args: monthStr as AnyObject, statsDataResult![i].dateComponents!.day as AnyObject) ];
								} else {
									//일만 추가
									tDatasXAxisEntry += [ LanguagesManager.parseStr(LanguagesManager.$("statsDateFormatDayOnly"), args: statsDataResult![i].dateComponents!.day as AnyObject) ];
								}
							} //end for
							
							//DataSet 지정(하나의 legend라고 생각하면 됨)
							let chartDataSet:LineChartDataSet = LineChartDataSet(values: tLineDataEntries, label: "");
							//종합적인 차트 데이터를 하나로 묶어야 함. dataSet는 단일이 아닌 배열로 줄 수도 있음
							let chartData = LineChartData(dataSet: chartDataSet);
								//LineChartData(xVals: tDatasXAxisEntry, dataSet: chartDataSet );
							
							chartDataSet.drawValuesEnabled = false; //값 표시 안함
							//선 색 설정. 알파 적용을 위해 RGB 입력
							chartDataSet.setColor( UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5) );
							chartDataSet.circleRadius = 2;
							chartDataSet.circleHoleColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5);
							chartDataSet.circleColors = [ UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5) ];
							chartDataSet.drawFilledEnabled = true;
							chartDataSet.fillColor = UIColor.white;
							chartDataSet.fillAlpha = 0.5;
							
							//데이터 적용
							lineChartPointer!.data = chartData;
							
							//최대치 설정. 최대치는 여기서 설정해야 버그없이 작동함.
							lineChartPointer!.rightYAxisRenderer.axis!.axisMinimum = chartData.getYMax();
							lineChartPointer!.rightYAxisRenderer.axis!.setLabelCount(2, force: true);
							
							//label max count max 7
							lineChartPointer!.xAxisRenderer.axis!.setLabelCount(min(7, chartData.entryCount), force: false);
							
							switch(selDataPointInt) {
								case 3, 5: //~% 표기
									currentDataPrefix = ""; currentDataSuffix = LanguagesManager.$("statsDataFormatPercent");
									
									//Get average
									resultAverage = resultAverage / Float(statsDataResult!.count);
									break;
								case 4, 6: //합계 ~회 표기
									currentDataPrefix = LanguagesManager.$("statsDataFormatCountsPrefixShort");
									currentDataSuffix = LanguagesManager.$("statsDataFormatCountsSuffixShort");
									
									//Average 구할 필요 없음
									break;
								default: //평균 ~분 표기
									currentDataPrefix = LanguagesManager.$("statsTimeFormatMinPrefix");
									currentDataSuffix = LanguagesManager.$("statsTimeFormatMinSuffix");
									
									//Get average
									resultAverage = resultAverage / Float(statsDataResult!.count);
									break;
							} //end switch
							
							lineChartPointer!.animate( xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeOutCirc )
							
							//X Formatter
							let defXFormatter:StrArrayFormatter = StrArrayFormatter()
							defXFormatter.strArr = tDatasXAxisEntry
							
							//Y Formatter
							let defFormatter:NumberFormatter = NumberFormatter()
							defFormatter.positivePrefix = currentDataPrefix
							defFormatter.positiveSuffix = currentDataSuffix
							
							lineChartPointer!.xAxisRenderer.axis!.valueFormatter = DefaultAxisValueFormatter(formatter: defXFormatter)
							lineChartPointer!.rightYAxisRenderer.axis!.valueFormatter = DefaultAxisValueFormatter(formatter: defFormatter)
							
							break
						default: //fallback
							break
					} //end switch
					break
			} //end if [if data exists]
			
			switch(selDataPointInt) {
				case 3: //표기 없음
					rootViewChartSubtitle!.text = ""
					break
				case 5: //평균 ~% 표기
					rootViewChartSubtitle!.text = LanguagesManager.parseStr(LanguagesManager.$("statsAverageFormat"),
					                                                 args: String(String(format:"%.0f", resultAverage) + LanguagesManager.$("statsDataFormatPercent")) as AnyObject)
					break
				case 4, 6: //합계 ~회 표기
					rootViewChartSubtitle!.text = LanguagesManager.parseStr(LanguagesManager.$("statsTotalFormat"),
																	 args: String(LanguagesManager.$("statsDataFormatCountsPrefix") + String(format:"%.0f", resultAverage) + LanguagesManager.$("statsDataFormatCountsSuffix") ) as AnyObject)
					break
				default: //평균 ~분 표기
					rootViewChartSubtitle!.text = LanguagesManager.parseStr(LanguagesManager.$("statsAverageFormat"),
																	 args: String(LanguagesManager.$("statsTimeFormatMinPrefix") + String(format:"%.0f", resultAverage) + LanguagesManager.$("statsTimeFormatMinSuffix") ) as AnyObject)
				break
			} //end switch
		} //end if
		
		//Add charts to view
		if (rootViewChartPointer != nil) {
			rootViewChartWrapperCellPointer!.addSubview( rootViewChartPointer! );
		} //end if
	} ////end func
	
	
	/// table setup
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
			default:
				return "";
		}
	} //end func
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section]).count
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch((indexPath as NSIndexPath).section) {
			case 0:
				if ((indexPath as NSIndexPath).row == 0) {
					return 180 + 48 + 6
				} else {
					return 45
				}
			default:
				return UITableViewAutomaticDimension
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[(indexPath as NSIndexPath).section])[(indexPath as NSIndexPath).row] as UITableViewCell;
		return cell
	}
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch( section ) {
			case 0:
				return 0.0001
			default:
				return 38
		} //end switch
	} //end func
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cellID:String = (tableView.cellForRow(at: indexPath) as! CustomTableCell).cellID
		switch(cellID) {
			case "dataPoint": //open datapoint view
				self.statsDataPointView.setSelectedCell( rootSelectedCurrentDataPoint )
				navigationCtrl.pushViewController(self.statsDataPointView, animated: true)
				statsDataPointView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false) //scroll to top
				break
			default: break
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	} ////end func
	
	////////////////
	
	func setSubviewSize() {
		statsDataPointView.view.frame = CGRect(
			x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height );
	} ///////////////////////////////////////////////
	
	///// 초기 화면 그래프 (segment) 표시
	func createIntroChartCell() -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		
		//셀 크기 지정
		tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 180 + 48 + 18);
		
		//create 3-seg sel
		let tSelection:UISegmentedControl
			= UISegmentedControl( items: [ LanguagesManager.$("statsWeek"), LanguagesManager.$("statsMonth"), LanguagesManager.$("statsYear") ] );
		tSelection.frame = CGRect( x: (self.modalView.view.frame.width / 2) - (190 / 2), y: 12, width: 190, height: 30 );
		tSelection.selectedSegmentIndex = 0; //default selected index
		tSelection.addTarget(self, action: #selector(StatisticsView.segmentIdxChanged(_:)), for: .valueChanged);
		
		//create chart table
		let tChartTableWrapper:UIView = createBarChartTableCell();
		tChartTableWrapper.frame = CGRect( x: 0, y: 54, width: self.modalView.view.frame.width, height: 180 );
		let tChartNodataUILabel:UILabel = UILabel();
		tChartNodataUILabel.textAlignment = .center;
		tChartNodataUILabel.font = UIFont.systemFont(ofSize: 14);
		tChartNodataUILabel.textColor = UIColor.white;
		tChartNodataUILabel.frame = CGRect( x: 0, y: 140, width: self.modalView.view.frame.width, height: 24 );
		tChartNodataUILabel.text = LanguagesManager.$("statsNoDataAvailable");
		
		//// 아래 4개 라벨은 파이차트용
		let tChartRightFirstLabelTitle:UILabel = UILabel();
		tChartRightFirstLabelTitle.textAlignment = .right;
		tChartRightFirstLabelTitle.font = UIFont.boldSystemFont(ofSize: 22);
		tChartRightFirstLabelTitle.textColor = UIColor.white;
		tChartRightFirstLabelTitle.frame = CGRect( x: 0, y: 110, width: self.modalView.view.frame.width - 24, height: 24 );
		tChartRightFirstLabelTitle.text = LanguagesManager.$("statsDataGameCleared");
		
		let tChartRightFirstLabelValue:UILabel = UILabel();
		tChartRightFirstLabelValue.textAlignment = .right;
		tChartRightFirstLabelValue.font = UIFont.systemFont(ofSize: 14);
		tChartRightFirstLabelValue.textColor = UIColor.white;
		tChartRightFirstLabelValue.frame = CGRect( x: 0, y: 132, width: self.modalView.view.frame.width - 24, height: 24 );
		tChartRightFirstLabelValue.text = "100%";
		
		let tChartRightSecondLabelTitle:UILabel = UILabel();
		tChartRightSecondLabelTitle.textAlignment = .right;
		tChartRightSecondLabelTitle.font = UIFont.boldSystemFont(ofSize: 22);
		tChartRightSecondLabelTitle.textColor = UIColor.white;
		tChartRightSecondLabelTitle.frame = CGRect( x: 0, y: 164, width: self.modalView.view.frame.width - 24, height: 24 );
		tChartRightSecondLabelTitle.text = LanguagesManager.$("statsDataGameRetired");
		
		let tChartRightSecondLabelValue:UILabel = UILabel();
		tChartRightSecondLabelValue.textAlignment = .right;
		tChartRightSecondLabelValue.font = UIFont.systemFont(ofSize: 14);
		tChartRightSecondLabelValue.textColor = UIColor.white;
		tChartRightSecondLabelValue.frame = CGRect( x: 0, y: 186, width: self.modalView.view.frame.width - 24, height: 24 );
		tChartRightSecondLabelValue.text = "100%";

		rootViewChartWrapperCellPointer = tChartTableWrapper; //set pointer
		rootViewChartSelSegmentCell = tSelection;
		rootViewChartNodataUILabel = tChartNodataUILabel;
		
		rootViewRightLFirstTitle = tChartRightFirstLabelTitle; rootViewRightLFirstValue = tChartRightFirstLabelValue;
		rootViewRightLSecondTitle = tChartRightSecondLabelTitle; rootViewRightLSecondValue = tChartRightSecondLabelValue;
		
		tCell.addSubview(tChartTableWrapper);
		tCell.addSubview(tSelection);
		tCell.addSubview(tChartNodataUILabel);
		
		tCell.addSubview(tChartRightFirstLabelTitle); tCell.addSubview(tChartRightFirstLabelValue);
		tCell.addSubview(tChartRightSecondLabelTitle); tCell.addSubview(tChartRightSecondLabelValue);
		
		return tCell;
	} //end func
	
	//// SegmentedControl func
	func segmentIdxChanged(_ target: UISegmentedControl) {
		if (target.selectedSegmentIndex == rootViewChartSelectedCategory || target.selectedSegmentIndex == -1) {
			return //같은걸 선택했으면 새로 안 그림
		}
		
		rootViewChartSelectedCategory = target.selectedSegmentIndex
		drawMainGraph()
	} //end func
	
	
	//바 차트 테이블 뷰 반환
	func createBarChartTableCell() -> UIView {
		print("adding bar chart");
		let tCell:UIView = UIView();
		//Chart title
		let tChartTitleLabel:UILabel = UILabel();
		tChartTitleLabel.text = LanguagesManager.$("statsTitleUntilAlarmOff"); // title text.
		tChartTitleLabel.font = UIFont.systemFont(ofSize: 17);
		tChartTitleLabel.frame = CGRect(x: 16, y: 10, width: self.modalView.view.frame.width / 1.25, height: 24);
		tChartTitleLabel.textColor = UIColor.white;
		
		//Chart subtitle
		let tChartSubtitleLabel:UILabel = UILabel();
		tChartSubtitleLabel.text = ""; //Subtitle.
		tChartSubtitleLabel.font = UIFont.systemFont(ofSize: 13);
		tChartSubtitleLabel.frame = CGRect(x: self.modalView.view.frame.width / 2 - 6, y: 13, width: self.modalView.view.frame.width / 2 - 6, height: 24);
		tChartSubtitleLabel.textAlignment = .right;
		tChartSubtitleLabel.textColor = UIColor.white;
		
		//Add to cell view
		tCell.addSubview(tChartTitleLabel); tCell.addSubview(tChartSubtitleLabel);
		
        //gradient background
        let gradient:CAGradientLayer = CAGradientLayer();
        gradient.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 180);
		// 그래디언트 시작컬러, 끝컬러 지정
        gradient.colors = [ UPUtils.colorWithHexString("0082ED").cgColor , UPUtils.colorWithHexString("005396").cgColor ];
        tCell.layer.insertSublayer(gradient, at: 0); // 셀 레이어로 추가
		
		//셀 크기 지정
		tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 180);
		
		//후에 차트 조정을 위한 포인터 지정
		rootViewChartTitle = tChartTitleLabel;
		rootViewChartSubtitle = tChartSubtitleLabel;
		rootViewChartBackgroundGradient = gradient;
		
		return tCell;
	} //함수 끝
	
	func createPredesignedPieChart() -> PieChartView {
		let tMultipleChart:PieChartView = PieChartView(); //차트 뷰
		
		//차트 크기 지정
		//파이차트는 반만 그리고, 남는 우측에 %를 크게 씁시다
		tMultipleChart.frame = CGRect(x: 0, y: 34, width: self.modalView.view.frame.width / 1.75, height: 140);
		
		//User-interaction 해제 부분
		tMultipleChart.legend.enabled = false;
		tMultipleChart.highlightPerTapEnabled = false;
		//오른쪽 아래 차트에 오버레이되는 라벨 텍스트
		tMultipleChart.chartDescription!.text = "";
		tMultipleChart.noDataText = LanguagesManager.$("statsNoDataAvailable");
		tMultipleChart.holeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0);
		
		
		return tMultipleChart;
		
	}
	
	func createPredesignedBarChart() -> BarChartView {
		let tMultipleChart:BarChartView = BarChartView(); //차트 뷰
		let yAxisNumberFormatter:NumberFormatter = NumberFormatter();
		yAxisNumberFormatter.numberStyle = .none; //숫자 표현 방법. NoStyle이면 포맷 안함
		yAxisNumberFormatter.positivePrefix = LanguagesManager.$("statsTimeFormatMinPrefix"); //숫자 앞
		yAxisNumberFormatter.positiveSuffix = LanguagesManager.$("statsTimeFormatMinSuffix"); //positiveSuffix -> 숫자 뒤에 붙는 문자
		
		//차트 크기 지정
		tMultipleChart.frame = CGRect(x: 0, y: 28 + 12, width: self.modalView.view.frame.width, height: 140 - 12);
		
		//User-interaction 해제 부분
		tMultipleChart.pinchZoomEnabled = false;
		tMultipleChart.setScaleEnabled(false);
		tMultipleChart.doubleTapToZoomEnabled = false;
		tMultipleChart.legend.enabled = false;
		tMultipleChart.dragEnabled = false;
		tMultipleChart.highlightPerTapEnabled = false;
		
		//오른쪽 아래 차트에 오버레이되는 라벨 텍스트
		tMultipleChart.chartDescription!.text = "";
		
		//주변 선 그리지 않도록 무시
		tMultipleChart.drawBordersEnabled = false;
		
		//가로줄 라벨 아래로
		tMultipleChart.xAxis.labelPosition = .bottom;
		//그리드 라인 그림 여부
		tMultipleChart.xAxis.drawGridLinesEnabled = false;
		//Axis 라벨 위의 라인 표시 여부
		tMultipleChart.xAxis.drawAxisLineEnabled = true;
		
		//라인 컬러 및 라벨 컬러
		tMultipleChart.xAxis.axisLineColor = UIColor.white;
		tMultipleChart.xAxis.labelTextColor = UIColor.white;
		
		//스킵이 있을 경우, 너비와 상관 없이 가로 라벨을 생략하므로 0으로 설정하여 생략이 없게 설정
		tMultipleChart.xAxis.setLabelCount(tMultipleChart.xAxis.labelCount, force: true);
		
		//왼쪽 yAxis 표시 안함
		tMultipleChart.leftYAxisRenderer.axis!.enabled = false;
		
		//오른쪽 yAxis의 라벨을 바깥으로 보냄
		//tMultipleChart.rightYAxisRenderer.axis!.label = .outsideChart;
		
		//그리드 라인, ZeroLine, AxisLine 그리지 않음 설정
		tMultipleChart.rightYAxisRenderer.axis!.drawGridLinesEnabled = false;
		//tMultipleChart.rightYAxisRenderer.axis!.drawZeroLineEnabled = false;
		tMultipleChart.rightYAxisRenderer.axis!.drawAxisLineEnabled = false;
		
		//~분 포맷
		tMultipleChart.rightYAxisRenderer.axis!.valueFormatter = DefaultAxisValueFormatter(formatter: yAxisNumberFormatter);
		
		
		//라벨 컬러 지정
		tMultipleChart.rightYAxisRenderer.axis!.labelTextColor = UIColor.white;
		tMultipleChart.leftYAxisRenderer.axis!.axisMinimum = 0; //disabled 되어있어도 설정이 필요.
		tMultipleChart.rightYAxisRenderer.axis!.axisMinimum = 0;
		//tMultipleChart.rightYAxisRenderer.axis!.showOnlyMinMaxEnabled = true;
		
		tMultipleChart.noDataText = LanguagesManager.$("statsNoDataAvailable");
		
		return tMultipleChart;
	}
	
	//라인 차트 테이블 뷰 반환
	func createLineChartTableCell() -> UIView {
		print("adding line chart");
		let tCell:UIView = UIView();
		//Chart title
		let tChartTitleLabel:UILabel = UILabel();
		tChartTitleLabel.text = LanguagesManager.$("statsTitleUntilAlarmOff"); // title text.
		tChartTitleLabel.font = UIFont.systemFont(ofSize: 17);
		tChartTitleLabel.frame = CGRect(x: 16, y: 10, width: self.modalView.view.frame.width / 1.25, height: 24);
		tChartTitleLabel.textColor = UIColor.white;
		
		//Chart subtitle
		let tChartSubtitleLabel:UILabel = UILabel();
		tChartSubtitleLabel.text = ""; //Subtitle.
		tChartSubtitleLabel.font = UIFont.systemFont(ofSize: 13);
		tChartSubtitleLabel.frame = CGRect(x: self.modalView.view.frame.width / 2 - 6, y: 13, width: self.modalView.view.frame.width / 2 - 6, height: 24);
		tChartSubtitleLabel.textAlignment = .right;
		tChartSubtitleLabel.textColor = UIColor.white;
		
		//Add to cell view
		tCell.addSubview(tChartTitleLabel); tCell.addSubview(tChartSubtitleLabel);
		
		//gradient background
		let gradient:CAGradientLayer = CAGradientLayer();
		gradient.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 180);
		// 그래디언트 시작컬러, 끝컬러 지정
		gradient.colors = [ UPUtils.colorWithHexString("FFCE08").cgColor , UPUtils.colorWithHexString("FF7300").cgColor ];
		tCell.layer.insertSublayer(gradient, at: 0); // 셀 레이어로 추가
		
		//셀 크기 지정
		tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 180);
		
		
		//후에 차트 조정을 위한 포인터 지정
		rootViewChartSubtitle = tChartSubtitleLabel;
		rootViewChartBackgroundGradient = gradient;
		
		return tCell;
	} //함수 끝
	
	func createPredesignedLineChart() -> LineChartView {
		let tMultipleChart:LineChartView = LineChartView(); //차트 뷰
		let yAxisNumberFormatter:NumberFormatter = NumberFormatter();
		yAxisNumberFormatter.numberStyle = .none; //숫자 표현 방법. NoStyle이면 포맷 안함
		yAxisNumberFormatter.positivePrefix = LanguagesManager.$("statsTimeFormatMinPrefix"); //숫자 앞
		yAxisNumberFormatter.positiveSuffix = LanguagesManager.$("statsTimeFormatMinSuffix"); //positiveSuffix -> 숫자 뒤에 붙는 문자
		
		//차트 크기 지정
		tMultipleChart.frame = CGRect(x: 0, y: 28 + 12, width: self.modalView.view.frame.width, height: 140 - 12);
		
		//User-interaction 해제 부분
		tMultipleChart.pinchZoomEnabled = false;
		tMultipleChart.setScaleEnabled(false);
		tMultipleChart.doubleTapToZoomEnabled = false;
		tMultipleChart.legend.enabled = false;
		tMultipleChart.dragEnabled = false;
		tMultipleChart.highlightPerTapEnabled = false;
		
		//오른쪽 아래 차트에 오버레이되는 라벨 텍스트
		tMultipleChart.chartDescription!.text = "";
		
		//주변 선 그리지 않도록 무시
		tMultipleChart.drawBordersEnabled = false;
		
		//가로줄 라벨 아래로
		tMultipleChart.xAxis.labelPosition = .bottom;
		//그리드 라인 그림 여부
		tMultipleChart.xAxis.drawGridLinesEnabled = false;
		//Axis 라벨 위의 라인 표시 여부
		tMultipleChart.xAxis.drawAxisLineEnabled = true;
		
		//라인 컬러 및 라벨 컬러
		tMultipleChart.xAxis.axisLineColor = UIColor.white;
		tMultipleChart.xAxis.labelTextColor = UIColor.white;
		
		//스킵이 있을 경우, 너비와 상관 없이 가로 라벨을 생략하므로 0으로 설정하여 생략이 없게 설정
		//tMultipleChart.xAxis.setLabelsToSkip(0);
		
		//왼쪽 yAxis 표시 안함
		tMultipleChart.leftYAxisRenderer.axis!.enabled = false;
		
		//오른쪽 yAxis의 라벨을 바깥으로 보냄
		//tMultipleChart.rightYAxisRenderer.axis!.labelPosition = .outsideChart;
		
		//그리드 라인, ZeroLine, AxisLine 그리지 않음 설정
		tMultipleChart.rightYAxisRenderer.axis!.drawGridLinesEnabled = false;
		//tMultipleChart.rightYAxisRenderer.axis!.drawZeroLineEnabled = false;
		tMultipleChart.rightYAxisRenderer.axis!.drawAxisLineEnabled = false;
		
		//~분 포맷
		tMultipleChart.rightYAxisRenderer.axis!.valueFormatter = DefaultAxisValueFormatter( formatter: yAxisNumberFormatter );
		
		//라벨 컬러 지정
		tMultipleChart.rightYAxisRenderer.axis!.labelTextColor = UIColor.white;
		tMultipleChart.rightYAxisRenderer.axis!.axisMinimum = 0;
		//tMultipleChart.rightYAxisRenderer.axis!.showOnlyMinMaxEnabled = true;
		
		tMultipleChart.noDataText = LanguagesManager.$("statsNoDataAvailable");
		
		//chart 반환
		return tMultipleChart
	} //end func
	
	func createCellWithNextArrow( _ name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRect(x: 12, y: 6, width: 31.3, height: 31.3);
		switch(menuID) { //특정 조건으로 아이콘 구분
			case "dataPoint": tIconFileStr = "comp-icons-datacategory-icon"; break;
			default:
				tIconFileStr = "comp-icons-blank"
				break
		}; tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg)
		
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRect(x: tIconWPadding, y: 0, width: self.modalView.view.frame.width, height: 45)
		tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 45)
		tCell.backgroundColor = UIColor.white
		
		tCell.addSubview(tLabel)
		tLabel.text = name
		
		tCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
		tLabel.font = UIFont.systemFont(ofSize: 16)
		
		tCell.cellID = menuID
		
		return tCell
	} //end func
	
}
