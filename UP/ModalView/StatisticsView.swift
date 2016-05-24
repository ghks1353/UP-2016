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
	
	//클래스 외부접근을 위함
	static var selfView:StatisticsView?;
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
	//Table for menu
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	var tablesArray:Array<Array<CustomTableCell>> = [];
	
	//Main charts pointer
	var rootViewChartPointer:ChartViewBase?; //차트에 대한 기본 클래스
	
	var rootViewChartSubtitle:UILabel?; var rootViewChartTitle:UILabel?; //제목 및 부제목
	var rootViewChartWrapperCellPointer:UIView?; var rootViewChartBackgroundGradient:CAGradientLayer?;
	
	var rootViewChartSelSegmentCell:UISegmentedControl?; var rootViewChartNodataUILabel:UILabel?;
	var rootViewChartSelectedCategory:Int = 0; //메인차트 주/월/년 구분
	
	//완주 비율 그래프일 때 나타낼 텍스트 (4개)
	var rootViewRightLFirstTitle:UILabel?; var rootViewRightLFirstValue:UILabel?;
	var rootViewRightLSecondTitle:UILabel?; var rootViewRightLSecondValue:UILabel?;
	
	
	var rootSelectedCurrentDataPoint:String = StatisticsDataPointView.POINT_UNTIL_OFF; //ualarmoff - 겜시작+플레이, ugamestart - 겜시작, playtime - 플레이
	
	//Subviews
	var statsDataPointView:StatisticsDataPointView = GlobalSubView.alarmStatisticsDataPointView;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor()
		
		StatisticsView.selfView = self;
		print("initing view.");
		
		//ModalView
		modalView.view.backgroundColor = UIColor.whiteColor();
		modalView.view.frame = DeviceGeneral.defaultModalSizeRect;
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#174468");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("userStatistics");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(StatisticsView.viewCloseAction), forControlEvents: .TouchUpInside);
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		///////// Nav items fin
		
		//add ctrl
		self.view.addSubview(navigationCtrl.view);
		
		//add table to modal
		tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
		modalView.view.addSubview(tableView);
		
		print("Adding table.");
		
		//add table cells (options)
		tablesArray = [
			[ /* SECTION 1 */
				createIntroChartCell(),
				createCellWithNextArrow(Languages.$("statsDataPoint"), menuID: "dataPoint")
			]
			
		];
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
		
		setSubviewSize();
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"));
		modalMaskImageView.frame = modalView.view.frame;
		modalMaskImageView.contentMode = .ScaleAspectFit; self.view.maskView = modalMaskImageView;
		
		FitModalLocationToCenter();
	}
	
	/////// View transition animation
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_STATS);
		
		//뷰 초기 진입시 설정 초기화
		rootViewChartSelectedCategory = 0;
		rootSelectedCurrentDataPoint = StatisticsDataPointView.POINT_UNTIL_OFF;
		rootViewChartSelSegmentCell!.selectedSegmentIndex = 0;
		
		drawMainGraph();
	}
	
	override func viewWillDisappear(animated: Bool) {
		AnalyticsManager.untrackScreen(); //untrack to previous screen
	}
	
	override func viewDidAppear(animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRectMake(0, DeviceGeneral.scrSize!.height,
		                             DeviceGeneral.scrSize!.width, DeviceGeneral.scrSize!.height);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.view.frame = CGRectMake(0, 0,
				DeviceGeneral.scrSize!.width, DeviceGeneral.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	
	func drawMainGraph() {
		//data fetch
		print("Getting data");
		var selDataPointInt:Int = 0;
		
		switch(rootSelectedCurrentDataPoint) {
			case StatisticsDataPointView.POINT_UNTIL_OFF:
				selDataPointInt = 0;
				rootViewChartTitle!.text = Languages.$("statsTitleUntilAlarmOff");
				break;
			case StatisticsDataPointView.POINT_UNTIL_START:
				selDataPointInt = 1;
				rootViewChartTitle!.text = Languages.$("statsTitleUntilGameStart");
				break;
			case StatisticsDataPointView.POINT_PLAYTIME:
				selDataPointInt = 2;
				rootViewChartTitle!.text = Languages.$("statsTitleGamePlayTime");
				break;
			case StatisticsDataPointView.POINT_GAME_CLEARED:
				selDataPointInt = 3;
				rootViewChartTitle!.text = Languages.$("statsTitleGameClearPercent");
				break;
			
			case StatisticsDataPointView.POINT_GAME_TOUCHES:
				selDataPointInt = 4;
				rootViewChartTitle!.text = Languages.$("statsTitleTouches");
				break;
			case StatisticsDataPointView.POINT_GAME_VALID:
				selDataPointInt = 5;
				rootViewChartTitle!.text = Languages.$("statsTitleVaildTouchPercent");
				break;
			case StatisticsDataPointView.POINT_GAME_ASLEEP:
				selDataPointInt = 6;
				rootViewChartTitle!.text = Languages.$("statsTitleFellAsleepCount");
				break;
			default: break;
		}
		
		//Default hidden
		rootViewRightLFirstTitle!.hidden = true; rootViewRightLFirstValue!.hidden = true;
		rootViewRightLSecondTitle!.hidden = true; rootViewRightLSecondValue!.hidden = true;
		
		//Data fetch from datamanager
		let statsDataResult:Array<StatsDataElement>? = DataManager.getAlarmGraphData( rootViewChartSelectedCategory, dataPointSelection: selDataPointInt );
		
		//Set pointers
		var barChartPointer:BarChartView?; var lineChartPointer:LineChartView?; var pieChartPointer:PieChartView?;
		//BGColor
		var currentBGColor:String = "";
		
		//Remove existing view
		if (rootViewChartPointer != nil) {
			rootViewChartPointer!.removeFromSuperview();
			rootViewChartPointer = nil;
		} //end chk
		
		if (statsDataResult == nil) {
			//no data or error
		} else {
			//그래디언트 색은 미리 여기서 정해줍시다
			switch(selDataPointInt) {
				case 3,4,5,6: //게임 데이터 그래프 색
					switch(rootViewChartSelectedCategory) { //주 월 년?
						case 0: //보라 계열 그래디언트 색 설정
							rootViewChartBackgroundGradient!.colors = [ UPUtils.colorWithHexString("7E49B3").CGColor , UPUtils.colorWithHexString("532185").CGColor ];
							currentBGColor = "7E49B3";
							break;
						case 1, 2: //초록 계열 그래디언트 색 설정
							rootViewChartBackgroundGradient!.colors = [ UPUtils.colorWithHexString("50B354").CGColor , UPUtils.colorWithHexString("218524").CGColor ];
							currentBGColor = "50B354";
							break;
						default: break;
					}
					break;
				default: //기본 그래프 색
					switch(rootViewChartSelectedCategory) { //주 월 년?
						case 0: //파랑 계열 그래디언트 색 설정
							rootViewChartBackgroundGradient!.colors = [ UPUtils.colorWithHexString("0082ED").CGColor , UPUtils.colorWithHexString("005396").CGColor ];
							break;
						case 1, 2: //주황 계열 그래디언트 색 설정
							rootViewChartBackgroundGradient!.colors = [ UPUtils.colorWithHexString("FFCE08").CGColor , UPUtils.colorWithHexString("FF7300").CGColor ];
							break;
						default: break;
					}
					break;
			} //end switch
			
			if (statsDataResult!.count == 0) {
				//데이터 없음 fallback
				rootViewChartSubtitle!.text = "-";
				rootViewChartNodataUILabel!.hidden = false;
				return;
			}
			rootViewChartNodataUILabel!.hidden = true;
			
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
					
					//받아온 데이터를 0인지 1인지를 검사하여 두 카테고리로 분리해야 함
					var xIndArr:Array<String> = [
						Languages.$("statsDataGameRetired"), Languages.$("statsDataGameCleared")
					]; //0번째 카테고리 - 포기, 1번째 카테고리 - 성공
					
					//element를 돌면서 성공과 비율을 먼저 구하자
					var successCount:Int = 0; var failedCount:Int = 0;
					
					for i:Int in 0 ..< statsDataResult!.count {
						if (statsDataResult![i].numberData < 1) { //== 0인데, float라 걱정되서 이렇게 검사함
							failedCount += 1; //실패 시 실패 카운트
						} else { //성공 시 성공 카운트
							successCount += 1;
						} //end if
					} //end for
					
					//둘중 하나 카운트가 없으면 라벨 표기 안함
					if (failedCount == 0) {
						xIndArr[0] = ""; //0번째는 실패 라벨
					}
					if (successCount == 0) {
						xIndArr[1] = ""; //1번째는 클리어 라벨
					}
					
					//카운트를 기반으로 데이터를 넣기.
					let successPercent:Double = (Double(successCount) / Double(statsDataResult!.count)) * 100;
					let failedPercent:Double = (Double(failedCount) / Double(statsDataResult!.count)) * 100;
					
					let failedDataEntry:ChartDataEntry =
						ChartDataEntry(value: failedPercent, xIndex: 0);
					let successDataEntry:ChartDataEntry =
						ChartDataEntry(value: successPercent, xIndex: 1);
					let pieChartDataSet:PieChartDataSet =
						PieChartDataSet(yVals: [ failedDataEntry, successDataEntry ], label: "");
					
					pieChartDataSet.colors = [
						UIColor(red: 1, green: 1, blue: 1, alpha: 0.3), /* 포기 */
						UIColor(red: 1, green: 1, blue: 1, alpha: 0.82) //성공
					];
					pieChartDataSet.valueColors = [
						UIColor.whiteColor(),
						UPUtils.colorWithHexString(currentBGColor)
					];
					
					let pieChartDatas:PieChartData = PieChartData( xVals: xIndArr, dataSet: pieChartDataSet );
					pieChartDatas.setDrawValues(false);
					
					pieChartPointer!.data = pieChartDatas; //data apply
					currentDataPrefix = ""; currentDataSuffix = Languages.$("statsDataFormatPercent");
					
					//Show pie titles
					rootViewRightLFirstTitle!.hidden = false; rootViewRightLFirstValue!.hidden = false;
					rootViewRightLSecondTitle!.hidden = false; rootViewRightLSecondValue!.hidden = false;
					
					/*rootViewRightLFirstValue!.text =
						String(round(successPercent)) + currentDataSuffix + " (" +
						Languages.$("statsDataFormatCountsPrefix") + String(successCount) + Languages.$("statsDataFormatCountsSuffix")
					+ ")";*/
					rootViewRightLFirstValue!.text = String(round(successPercent)) + currentDataSuffix;
					rootViewRightLSecondValue!.text = String(round(failedPercent)) + currentDataSuffix;
					
					pieChartPointer!.animate( xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .EaseOutCirc );
					
					break;
				default: //기타 주/연도에 따른 바/라인차트 생성
					
					switch(rootViewChartSelectedCategory) { //차트별 데이터 정리
						case 0: //use bar chart.
							rootViewChartPointer = createPredesignedBarChart() as ChartViewBase;
							barChartPointer = rootViewChartPointer as? BarChartView;
							
							for i:Int in 0 ..< statsDataResult!.count {
								let dataEntry = BarChartDataEntry( value: Double(statsDataResult![i].numberData), xIndex: i );
								tDataEntries.append( dataEntry );
								
								resultAverage += statsDataResult![i].numberData;
								
								//x축 라벨 추가를 위한 작업
								if (previousMonth != statsDataResult![i].dateComponents!.month) {
									previousMonth = statsDataResult![i].dateComponents!.month;
									//Languages $0 ~ $1 되있는것 자동 변수 삽입.
									tDatasXAxisEntry += [ Languages.parseStr(Languages.$("statsDateFormatWithMonth"), args: statsDataResult![i].dateComponents!.month, statsDataResult![i].dateComponents!.day) ];
								} else {
									//일만 추가
									tDatasXAxisEntry += [ Languages.parseStr(Languages.$("statsDateFormatDayOnly"), args: statsDataResult![i].dateComponents!.day) ];
								}
							} //end for
							
							//DataSet 지정(하나의 legend라고 생각하면 됨)
							let chartDataSet:BarChartDataSet = BarChartDataSet( yVals: tDataEntries, label: "" );
							//종합적인 차트 데이터를 하나로 묶어야 함. dataSet는 단일이 아닌 배열로 줄 수도 있음
							let chartData = BarChartData(xVals: tDatasXAxisEntry, dataSet: chartDataSet );
							
							//Visual settings
							chartDataSet.barSpace = 0.8; chartDataSet.drawValuesEnabled = false;
							chartDataSet.setColor( UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5) ); //Chart color
							
							let tYaxisTopLine:ChartLimitLine = ChartLimitLine(limit: chartData.getYMax(), label: "");
							tYaxisTopLine.lineColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.5);
							tYaxisTopLine.lineWidth = 1;
							
							//표에 구분선 추가
							barChartPointer!.rightYAxisRenderer.yAxis!.removeAllLimitLines(); //Reset all lines
							barChartPointer!.rightYAxisRenderer.yAxis!.addLimitLine(tYaxisTopLine);
							
							barChartPointer!.data = chartData; //data apply
							
							barChartPointer!.rightYAxisRenderer.yAxis!.axisMinValue = 0;
							barChartPointer!.rightYAxisRenderer.yAxis!.axisMaxValue = chartData.getYMax(); //set max value
							
							switch(selDataPointInt) {
								case 3, 5: //~% 표기
									currentDataPrefix = ""; currentDataSuffix = Languages.$("statsDataFormatPercent");
									
									//Get average
									resultAverage = resultAverage / Float(statsDataResult!.count);
									break;
								case 4, 6: //합계 ~회 표기
									currentDataPrefix = Languages.$("statsDataFormatCountsPrefix");
									currentDataSuffix = Languages.$("statsDataFormatCountsSuffix");
									
									//Average 구할 필요 없음
									break;
								default: //평균 ~분 표기
									currentDataPrefix = Languages.$("statsTimeFormatMinPrefix");
									currentDataSuffix = Languages.$("statsTimeFormatMinSuffix");
									
									//Get average
									resultAverage = resultAverage / Float(statsDataResult!.count);
									break;
							} //end switch
							
							
							barChartPointer!.animate( xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .EaseOutCirc );
							barChartPointer!.rightYAxisRenderer.yAxis!.valueFormatter!.positivePrefix = currentDataPrefix;
							barChartPointer!.rightYAxisRenderer.yAxis!.valueFormatter!.positiveSuffix = currentDataSuffix;
							
							break;
						case 1, 2: //use line chart.
							rootViewChartPointer = createPredesignedLineChart() as ChartViewBase;
							lineChartPointer = rootViewChartPointer as? LineChartView;
							
							for i:Int in 0 ..< statsDataResult!.count {
								let dataEntry = ChartDataEntry( value: Double(statsDataResult![i].numberData), xIndex: i );
								tLineDataEntries.append( dataEntry );
								
								resultAverage += statsDataResult![i].numberData;
								
								//x축 라벨 추가를 위한 작업
								if (previousMonth != statsDataResult![i].dateComponents!.month) {
									previousMonth = statsDataResult![i].dateComponents!.month;
									//Languages $0 ~ $1 되있는것 자동 변수 삽입.
									tDatasXAxisEntry += [ Languages.parseStr(Languages.$("statsDateFormatWithMonth"), args: statsDataResult![i].dateComponents!.month, statsDataResult![i].dateComponents!.day) ];
								} else {
									//일만 추가
									tDatasXAxisEntry += [ Languages.parseStr(Languages.$("statsDateFormatDayOnly"), args: statsDataResult![i].dateComponents!.day) ];
								}
							} //end for
							
							//DataSet 지정(하나의 legend라고 생각하면 됨)
							let chartDataSet:LineChartDataSet = LineChartDataSet(yVals: tLineDataEntries, label: "");
							//종합적인 차트 데이터를 하나로 묶어야 함. dataSet는 단일이 아닌 배열로 줄 수도 있음
							let chartData = LineChartData(xVals: tDatasXAxisEntry, dataSet: chartDataSet );
							
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
							lineChartPointer!.data = chartData;
							
							//최대치 설정. 최대치는 여기서 설정해야 버그없이 작동함.
							lineChartPointer!.rightYAxisRenderer.yAxis!.axisMaxValue = chartData.getYMax();
							
							
							switch(selDataPointInt) {
							case 3, 5: //~% 표기
								currentDataPrefix = ""; currentDataSuffix = Languages.$("statsDataFormatPercent");
								
								//Get average
								resultAverage = resultAverage / Float(statsDataResult!.count);
								break;
							case 4, 6: //합계 ~회 표기
								currentDataPrefix = Languages.$("statsDataFormatCountsPrefix");
								currentDataSuffix = Languages.$("statsDataFormatCountsSuffix");
								
								//Average 구할 필요 없음
								break;
							default: //평균 ~분 표기
								currentDataPrefix = Languages.$("statsTimeFormatMinPrefix");
								currentDataSuffix = Languages.$("statsTimeFormatMinSuffix");
								
								//Get average
								resultAverage = resultAverage / Float(statsDataResult!.count);
								break;
							} //end switch
							
							
							lineChartPointer!.animate( xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .EaseOutCirc );
							lineChartPointer!.rightYAxisRenderer.yAxis!.valueFormatter!.positivePrefix = currentDataPrefix;
							lineChartPointer!.rightYAxisRenderer.yAxis!.valueFormatter!.positiveSuffix = currentDataSuffix;
							
							break;
						default: //fallback
							break;
					} //end switch
					
					break;
			}
			
			
			
			switch(selDataPointInt) {
				case 3: //표기 없음
					rootViewChartSubtitle!.text = "";
					break;
				case 5: //평균 ~% 표기
					rootViewChartSubtitle!.text = Languages.parseStr(Languages.$("statsAverageFormat"),
					                                                 args: String(format:"%.0f", resultAverage) + Languages.$("statsDataFormatPercent"));
					break;
				case 4, 6: //합계 ~회 표기
					rootViewChartSubtitle!.text = Languages.parseStr(Languages.$("statsTotalFormat"),
																	 args: Languages.$("statsDataFormatCountsPrefix") + String(format:"%.0f", resultAverage) + Languages.$("statsDataFormatCountsSuffix"));
					break;
				default: //평균 ~분 표기
					rootViewChartSubtitle!.text = Languages.parseStr(Languages.$("statsAverageFormat"),
																	 args: Languages.$("statsTimeFormatMinPrefix") + String(format:"%.0f", resultAverage) + Languages.$("statsTimeFormatMinSuffix"));
				break;
			} //end switch
			
			
			
		} //end if
		
		//Add charts to view
		if (rootViewChartPointer != nil) {
			rootViewChartWrapperCellPointer!.addSubview( rootViewChartPointer! );
		}
		
	}
	
	
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
		return (tablesArray[section]).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		//return UITableViewAutomaticDimension;
		switch(indexPath.section) {
			case 0:
				if (indexPath.row == 0) {
					return 180 + 48 + 6;
				} else {
					return 45;
				}
			default:
				return UITableViewAutomaticDimension;
		}
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section])[indexPath.row] as UITableViewCell;
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
		let cellID:String = (tableView.cellForRowAtIndexPath(indexPath) as! CustomTableCell).cellID;
		switch(cellID) {
			case "dataPoint":
				//open datapoint view
				self.statsDataPointView.setSelectedCell( rootSelectedCurrentDataPoint );
				navigationCtrl.pushViewController(self.statsDataPointView, animated: true);
				statsDataPointView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top

				break;
			default: break;
		}
		
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	
	////////////////
	
	internal func setSubviewSize() {
		statsDataPointView.view.frame = CGRectMake(
			0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height );
	}
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceGeneral.defaultModalSizeRect;
		
		if (self.view.maskView != nil) {
			self.view.maskView!.frame = DeviceGeneral.defaultModalSizeRect;
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		
		ViewController.viewSelf!.showHideBlurview(false);
		self.dismissViewControllerAnimated(true, completion: nil);
	} //end close func
	
	///// 초기 화면 그래프 (segment) 표시
	func createIntroChartCell() -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		
		//셀 크기 지정
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 180 + 48 + 18);
		
		//create 3-seg sel
		let tSelection:UISegmentedControl
			= UISegmentedControl( items: [ Languages.$("statsWeek"), Languages.$("statsMonth"), Languages.$("statsYear") ] );
		tSelection.frame = CGRectMake( (self.modalView.view.frame.width / 2) - (190 / 2), 12, 190, 30 );
		tSelection.selectedSegmentIndex = 0; //default selected index
		tSelection.addTarget(self, action: #selector(StatisticsView.segmentIdxChanged(_:)), forControlEvents: .ValueChanged);
		
		//create chart table
		let tChartTableWrapper:UIView = createBarChartTableCell();
		tChartTableWrapper.frame = CGRectMake( 0, 54, self.modalView.view.frame.width, 180 );
		let tChartNodataUILabel:UILabel = UILabel();
		tChartNodataUILabel.textAlignment = .Center;
		tChartNodataUILabel.font = UIFont.systemFontOfSize(14);
		tChartNodataUILabel.textColor = UIColor.whiteColor();
		tChartNodataUILabel.frame = CGRectMake( 0, 140, self.modalView.view.frame.width, 24 );
		tChartNodataUILabel.text = Languages.$("statsNoDataAvailable");
		
		//// 아래 4개 라벨은 파이차트용
		let tChartRightFirstLabelTitle:UILabel = UILabel();
		tChartRightFirstLabelTitle.textAlignment = .Right;
		tChartRightFirstLabelTitle.font = UIFont.boldSystemFontOfSize(22);
		tChartRightFirstLabelTitle.textColor = UIColor.whiteColor();
		tChartRightFirstLabelTitle.frame = CGRectMake( 0, 110, self.modalView.view.frame.width - 24, 24 );
		tChartRightFirstLabelTitle.text = Languages.$("statsDataGameCleared");
		
		let tChartRightFirstLabelValue:UILabel = UILabel();
		tChartRightFirstLabelValue.textAlignment = .Right;
		tChartRightFirstLabelValue.font = UIFont.systemFontOfSize(14);
		tChartRightFirstLabelValue.textColor = UIColor.whiteColor();
		tChartRightFirstLabelValue.frame = CGRectMake( 0, 132, self.modalView.view.frame.width - 24, 24 );
		tChartRightFirstLabelValue.text = "100%";
		
		let tChartRightSecondLabelTitle:UILabel = UILabel();
		tChartRightSecondLabelTitle.textAlignment = .Right;
		tChartRightSecondLabelTitle.font = UIFont.boldSystemFontOfSize(22);
		tChartRightSecondLabelTitle.textColor = UIColor.whiteColor();
		tChartRightSecondLabelTitle.frame = CGRectMake( 0, 164, self.modalView.view.frame.width - 24, 24 );
		tChartRightSecondLabelTitle.text = Languages.$("statsDataGameRetired");
		
		let tChartRightSecondLabelValue:UILabel = UILabel();
		tChartRightSecondLabelValue.textAlignment = .Right;
		tChartRightSecondLabelValue.font = UIFont.systemFontOfSize(14);
		tChartRightSecondLabelValue.textColor = UIColor.whiteColor();
		tChartRightSecondLabelValue.frame = CGRectMake( 0, 186, self.modalView.view.frame.width - 24, 24 );
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
	func segmentIdxChanged(target: UISegmentedControl) {
		if (target.selectedSegmentIndex == rootViewChartSelectedCategory || target.selectedSegmentIndex == -1) {
			return; //같은걸 선택했으면 새로 안 그림
		}
		
		rootViewChartSelectedCategory = target.selectedSegmentIndex;
		drawMainGraph();
	} //end func
	
	
	//바 차트 테이블 뷰 반환
	func createBarChartTableCell() -> UIView {
		print("adding bar chart");
		let tCell:UIView = UIView();
		//Chart title
		let tChartTitleLabel:UILabel = UILabel();
		tChartTitleLabel.text = Languages.$("statsTitleUntilAlarmOff"); // title text.
		tChartTitleLabel.font = UIFont.systemFontOfSize(17);
		tChartTitleLabel.frame = CGRectMake(16, 10, self.modalView.view.frame.width / 1.25, 24);
		tChartTitleLabel.textColor = UIColor.whiteColor();
		
		//Chart subtitle
		let tChartSubtitleLabel:UILabel = UILabel();
		tChartSubtitleLabel.text = ""; //Subtitle.
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
		tMultipleChart.frame = CGRectMake(0, 34, self.modalView.view.frame.width / 1.75, 140);
		
		//User-interaction 해제 부분
		tMultipleChart.legend.enabled = false;
		tMultipleChart.highlightPerTapEnabled = false;
		//오른쪽 아래 차트에 오버레이되는 라벨 텍스트
		tMultipleChart.descriptionText = "";
		tMultipleChart.noDataText = Languages.$("statsNoDataAvailable");
		tMultipleChart.holeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0);
		
		
		return tMultipleChart;
		
	}
	
	func createPredesignedBarChart() -> BarChartView {
		let tMultipleChart:BarChartView = BarChartView(); //차트 뷰
		let yAxisNumberFormatter:NSNumberFormatter = NSNumberFormatter();
		yAxisNumberFormatter.numberStyle = .NoStyle; //숫자 표현 방법. NoStyle이면 포맷 안함
		yAxisNumberFormatter.positivePrefix = Languages.$("statsTimeFormatMinPrefix"); //숫자 앞
		yAxisNumberFormatter.positiveSuffix = Languages.$("statsTimeFormatMinSuffix"); //positiveSuffix -> 숫자 뒤에 붙는 문자
		
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
		tMultipleChart.leftYAxisRenderer.yAxis!.axisMinValue = 0; //disabled 되어있어도 설정이 필요.
		tMultipleChart.rightYAxisRenderer.yAxis!.axisMinValue = 0;
		tMultipleChart.rightYAxisRenderer.yAxis!.showOnlyMinMaxEnabled = true;
		
		tMultipleChart.noDataText = Languages.$("statsNoDataAvailable");
		
		return tMultipleChart;
	}
	
	//라인 차트 테이블 뷰 반환
	func createLineChartTableCell() -> UIView {
		print("adding line chart");
		let tCell:UIView = UIView();
		//Chart title
		let tChartTitleLabel:UILabel = UILabel();
		tChartTitleLabel.text = Languages.$("statsTitleUntilAlarmOff"); // title text.
		tChartTitleLabel.font = UIFont.systemFontOfSize(17);
		tChartTitleLabel.frame = CGRectMake(16, 10, self.modalView.view.frame.width / 1.25, 24);
		tChartTitleLabel.textColor = UIColor.whiteColor();
		
		//Chart subtitle
		let tChartSubtitleLabel:UILabel = UILabel();
		tChartSubtitleLabel.text = ""; //Subtitle.
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
		
		
		//후에 차트 조정을 위한 포인터 지정
		rootViewChartSubtitle = tChartSubtitleLabel;
		rootViewChartBackgroundGradient = gradient;
		
		return tCell;
	} //함수 끝
	
	func createPredesignedLineChart() -> LineChartView {
		let tMultipleChart:LineChartView = LineChartView(); //차트 뷰
		let yAxisNumberFormatter:NSNumberFormatter = NSNumberFormatter();
		yAxisNumberFormatter.numberStyle = .NoStyle; //숫자 표현 방법. NoStyle이면 포맷 안함
		yAxisNumberFormatter.positivePrefix = Languages.$("statsTimeFormatMinPrefix"); //숫자 앞
		yAxisNumberFormatter.positiveSuffix = Languages.$("statsTimeFormatMinSuffix"); //positiveSuffix -> 숫자 뒤에 붙는 문자
		
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
		
		tMultipleChart.noDataText = Languages.$("statsNoDataAvailable");
		
		//chart 반환
		return tMultipleChart;
	}
	
	
	func createCellWithNextArrow( name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		
		//아이콘 표시 관련
		let tIconImg:UIImageView = UIImageView(); var tIconFileStr:String = ""; var tIconWPadding:CGFloat = 0;
		tIconImg.frame = CGRectMake(12, 6, 31.3, 31.3);
		switch(menuID) { //특정 조건으로 아이콘 구분
			case "dataPoint": tIconFileStr = "comp-icons-datacategory-icon"; break;
			default:
				tIconFileStr = "comp-icons-blank";
				break;
		}; tIconWPadding = tIconImg.frame.minX + tIconImg.frame.width + 8;
		tIconImg.image = UIImage( named: tIconFileStr + ".png" ); tCell.addSubview(tIconImg);
		
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRectMake(tIconWPadding, 0, self.modalView.view.frame.width, 45);
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45);
		tCell.backgroundColor = UIColor.whiteColor();
		
		tCell.addSubview(tLabel);
		tLabel.text = name;
		
		tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
		tLabel.font = UIFont.systemFontOfSize(16);
		
		tCell.cellID = menuID;
		
		return tCell;
	} //end func
	
}
