//
//  DataManager.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import SQLite;

//SQLite 사용한 데이터베이스도 데이터매니저에서 관리하도록 병합
/*
	사용자가 접근 가능한 path: NSDocumentDirectory (iTunes에서 도큐멘트 데이터로 관리 가능.)
	사용자가 접근 불가능한 path: NSLibraryDirectory (일반적으로 앱에서만 접근관리가능)
	
	https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#creating-a-table


	통계 데이터 저장에 대한 메모
	Type:
		아래 enum 리스트 참고.

	게임 값 저장 수치(타입3) 의 경우 타입3으로 두지말고 타 테이블에 저장
*/

class DataManager {
    enum settingsKeys {
        static let showBadge:String = "settings_showbadge";
        static let syncToiCloud:String = "settings_synctoicloud";
    }
	enum statsType {
		static let TYPE_ALARM_START_TIME:Int = 0; //게임을 시작하기 전 까지 걸린 시간. 단위: 초
		static let TYPE_ALARM_CLEAR_TIME:Int = 1; //게임을 클리어하는데 걸린 시간. 단위: 초
		
		static let TYPE_ALARM_GAME_DATA:Int = 3; //게임에 대한 전반적인 결과를 가짐.
	}
	
	//////////////////////
	
	static var nsDefaults = NSUserDefaults.standardUserDefaults();
	static func initDefaults() {
		nsDefaults = NSUserDefaults.standardUserDefaults();
	} //end func
	
	/////////// DB
	static var upDatabaseConnection:Connection? = nil;
	
	/// Tables
	static let upDBTableStats = Table("statisticsCollection"); //통계 자료를 모아놓는 테이블
	static let upDBTableGameResults = Table("statisticsGameResults"); //게임 결과 모아놓는 테이블.
	
	//DataManager init (nsDefault의 init와는 다르게 작동함)
	static func initDataManager() {
		let libPathArr:NSArray = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true);
		
		print("Database init works started");
		do {
			//DB 연결
			upDatabaseConnection = try Connection( libPathArr.objectAtIndex(0) as! String + "/db.sqlite3" );
			//Type 0,1을 위한 테이블 생성 (없을 경우)
			try upDatabaseConnection!.run(upDBTableStats.create(ifNotExists: true) { t in
				t.column( Expression<Int64>("id") , primaryKey: .Autoincrement) //자동증가 ID
				t.column( Expression<Int64>("type")) //통계 타입
				t.column( Expression<Int64>("date")) //통계 저장 날짜
				t.column( Expression<Int64?>("statsDataInt")) //Int형 저장 데이터
				t.column( Expression<String?>("statsDataStr")) //Str형 저장 데이터
				//배열 저장이 필요한 경우
				t.column( Expression<String?>("statsDataArray"))
				//배열 저장 데이터. Expression에 배열은 없으므로, 문자형으로 저장하며 ,로 구분
			});
			
			//게임 성과 저장을 위한 테이블 생성
			try upDatabaseConnection!.run(upDBTableGameResults.create(ifNotExists: true) { t in
				t.column( Expression<Int64>("id") , primaryKey: .Autoincrement) //uid.
				t.column( Expression<Int64>("gameid")) //게임 ID
				t.column( Expression<Int64>("date")) //통계 저장 날짜
				t.column( Expression<Int64>("gameCleared")) //게임 클리어 여부. 0 = 클리어 못함, 1 = 클리어함
				t.column( Expression<Int64>("startedTimeStamp")) //게임 시작 시간 (타임스탬프)
				t.column( Expression<Int64>("playTime")) //게임 플레이 시간
				t.column( Expression<Int64>("resultMissCount")) //게임오버 등에 해당하는 값
				t.column( Expression<Int64>("touchAll")) //전체 행동수
				t.column( Expression<Int64>("touchValid")) //유효 행동수
				t.column( Expression<Int64>("backgroundExitCount")) //중간에 백그라운드로 나간 횟수
				});
			
			print("Database init works finished");
		} catch {
			print("Database Error");
		} //end do try catch
		
	} //end func
	
	//init된 경우에만 제대로 받아올 수 있도록 함수 지정
	static func db() -> Connection? {
		return upDatabaseConnection;
	}
	//Stats Collection fetch
	static func statsTable() -> Table {
		return upDBTableStats;
	}
	static func gameResultTable() -> Table {
		return upDBTableGameResults;
	}
	
	
	///// utils: int to str arr (,)
	static func covertToStringArray(intObj:Array<Int>) -> String {
		var tmpStr:String = "";
		for i:Int in 0 ..< intObj.count {
			tmpStr += String(intObj[i]);
			if (i != intObj.count - 1) {
				tmpStr += ",";
			}
		}
		
		return tmpStr;
	} //end func
	
	//// 타임스탬프를 계산하여 연, 월, 일을 나누고 같은 날은 평균으로 계산한다.
	static func getAlarmGraphData( daysCategory:Int = 0, dataPointSelection:Int = 0 ) -> Array<StatsDataElement>? {
		//daysCategory 0 - 주, 1 - 월, 2 - 년
		//id가 큰것 하나만 얻어서 (id desc limit 1), 해당 날짜를 구한 다음, 해당 날짜의 타임스탬프 첫 시작일을 구함
		//그 다음, 거기서 카테고리에 따라 3600 * 일 만큼 뺀 부분부터 데이터 집계를 시작하면 됨.
		//그 다음 모은 데이터들을 for돌리면서 날짜를 구한다음(아마 숫자로도 할수있을듯), 같은 날짜의 경우 평균을 구함
		//그렇게 한 날짜의 데이터가 다 모아지면 배열에 날짜별로 넣음. 최대 1년치. 365개. 그걸 나중에 차트로 표현함.
		
		/*
		dataPointSelection에 따라 밑 3개 배열 중 뭘 줄지 결정해야 함
		*/
		
		var dataBeforeStartArray:Array<StatsDataElement> = Array<StatsDataElement>();
		var dataClearReducedArray:Array<StatsDataElement> = Array<StatsDataElement>();
		var dataUntilAlarmOff:Array<StatsDataElement> = Array<StatsDataElement>(); //이 변수는 위 두 값을 합친 형태임
		var dataGameResults:Array<StatsDataElement> = Array<StatsDataElement>();
		
		//돌려줄 데이터 모음.
		var toReturnDatasArray:Array<StatsDataElement>?;
		var seekTablePointer:Table?;
		
		var goalToFetchDataDays:Int = 0;
		switch(daysCategory) {
			case 0:
				goalToFetchDataDays = 7; //일주일 데이터
				break;
			case 1:
				goalToFetchDataDays = 30; //한달치 데이터.
				break;
			case 2:
				goalToFetchDataDays = 365; //1년치 데이터. (365일이라 쳤을 때)
				break;
			default: break;
		}
		
		var isGameTable:Bool = false;
		
		//데이터 셀렉션에 따른 참조 테이블 변경 및 필터링 생성
		switch(dataPointSelection) {
			case 0, 1, 2:
				seekTablePointer = DataManager.statsTable();
				break;
			case 3, 4, 5, 6: //완주 비율, 전체 행동 수, 행동 비율, 잠든 횟수
				seekTablePointer = DataManager.gameResultTable();
				isGameTable = true;
				break;
			default: break;
		}
		
		////////////////////
		
		print("Starting to get latest log for extract log data");
		do {
			var dataSeekStartTimeStamp:Int = 0;
			
			//1. 맨 마지막 데이터를 얻어옴
			for dbResult in try DataManager.db()!.prepare(
				seekTablePointer!
					.filter( isGameTable == true || Expression<Int64>("type") == 0 )
					/* type0,1,2이 같이 저장되기 때문에, 중복 방지로 하나만 불러옴 */
					.order( Expression<Int64>("id").desc )
					.limit( 1, offset: 1 )
			) {
				var targetDate:NSDate = NSDate(timeIntervalSince1970: NSTimeInterval(dbResult[ Expression<Int64>("date") ]) );
				let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: targetDate);
				components.hour = 0; components.minute = 0; components.second = 0;
				targetDate = NSCalendar.currentCalendar().dateFromComponents(components)!;
				
				dataSeekStartTimeStamp = Int(targetDate.timeIntervalSince1970) - (86400 * goalToFetchDataDays);
				print( "Latest id:", dbResult[ Expression<Int64>("id") ], ", time:", dbResult[ Expression<Int64>("date") ], "days start:", targetDate.timeIntervalSince1970 );
				print(" Data time seek start is:", dataSeekStartTimeStamp);
			} //end for
			//2. 시작할 Seektime을 얻어온 것을 기반으로 데이터 검색을 시작함.
			for dbResult in try DataManager.db()!.prepare(
				seekTablePointer!
					.filter( isGameTable == true || Expression<Int64>("type") == 0 || Expression<Int64>("type") == 1 )
					.filter( Expression<Int64>("date") >= Int64(dataSeekStartTimeStamp) )
					.order( Expression<Int64>("date").asc )
			) {
				//result.
				//날짜 구분 방법: seekTimeStart 지점을 0이라고 잡고 3600으로 나눠서 나온 구간별로?
				//로 하면 그래프를 그릴 때마다 일자를 구해야 하므로 여기서 미리 넣어줄까여.
				//우선 result에 대해서.
				
				//type 1혹은 2인걸 받아옴. 그리고 배열에 넣어줄땐 그 타입을 분류해서 넣어주도록 하자.
				//Date별로 작은순부터 정렬해서 받아오기 때문에, i - 1할 수 있는 경우
				//전 컴포넌트의 날짜랑 비교해서 같은 경우, 전 컴포넌트를 수정해주는 방식으로 해보자.
				
				var targetArrayPointer:Array<StatsDataElement> = /* 타겟 배열 포인터. */
					isGameTable ? dataGameResults : (
					dbResult[ Expression<Int64>("type") ] == 0 ? dataBeforeStartArray : dataClearReducedArray
				);
				
				let dateComp:NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second],
				                                                       fromDate: NSDate( timeIntervalSince1970: NSTimeInterval(dbResult[ Expression<Int64>("date") ]) ) );
				
				let tmpDataElements:StatsDataElement = StatsDataElement();
				var tmpDataResult:Float = 0;
				switch(dataPointSelection) { //값에 따른 데이터 참조값 변경
					case 4: //전체 행동 수
						tmpDataResult = Float( dbResult[Expression<Int64>("touchAll")] );
						break;
					case 5: //유효 행동 비율
						tmpDataResult =
							(Float(dbResult[Expression<Int64>("touchValid")]) / Float( dbResult[Expression<Int64>("touchAll")] )) * 100;
						break;
					case 6: //잠든 횟수
						tmpDataResult = Float( dbResult[Expression<Int64>("backgroundExitCount")] );
						break;
					default: //기타 참조하는 데이터는...
						tmpDataResult = Float( dbResult[Expression<Int64>("statsDataInt")] ) / 60; //초 단위를 분으로 계산하기 위해 나눔.
						break;
				} //end switch
				
				tmpDataElements.dataType = isGameTable ? 0 : Int( dbResult[ Expression<Int64>("type") ] );
				tmpDataElements.dataID = Int( dbResult[ Expression<Int64>("id") ] ); //같은 ID끼리 취합할때 사용
				
				tmpDataElements.dateComponents = dateComp;
				tmpDataElements.numberData = tmpDataResult;
				
				//날짜 중복 방지를 위한 계산
				if (targetArrayPointer.count == 0) {
					//배열에 아무것도 없는 경우 새로 추가
					if (isGameTable) {
						dataGameResults += [tmpDataElements];
					} else if (dbResult[ Expression<Int64>("type") ] == 0) {
						dataBeforeStartArray += [tmpDataElements];
					} else {
						dataClearReducedArray += [tmpDataElements];
					}
					//print("Element adding:", tmpDataResult);
				} else {
					let toCompareComp:NSDateComponents = targetArrayPointer[targetArrayPointer.count - 1].dateComponents!;
					
					if ( /* 이전 항목과 날짜가 일치하는지를 검사함. 전 element 참고를 위해 1 뺌. (2를 안 빼는 이유는 배열에 추가 안했거든.) */
						toCompareComp.year == dateComp.year && toCompareComp.month == dateComp.month && toCompareComp.day == dateComp.day ) {
						//일치하는 경우, 이전 항목 배열에 추가
						
						//print("Same day of last element. adding result to last element:", tmpDataResult);
						//DB 검색 추가 반복문이 끝난 후, 평균계산 반복문을 한번 더 돌릴거임.
						if (targetArrayPointer[targetArrayPointer.count - 1].numberDataArray == nil) {
							targetArrayPointer[targetArrayPointer.count - 1].numberDataArray = Array<Float>();
						}
						targetArrayPointer[targetArrayPointer.count - 1].numberDataArray! += [ tmpDataResult ];
						
					} else {
						//안하면 다른날짜 취급하여 그냥 추가함
						if (isGameTable) {
							dataGameResults += [tmpDataElements];
						} else if (dbResult[ Expression<Int64>("type") ] == 0) {
							dataBeforeStartArray += [tmpDataElements];
						} else {
							dataClearReducedArray += [tmpDataElements];
						}
						//print("Element adding:", tmpDataResult);
					} //end if chk comps
				} //end if chk empty array or not
				
			} //end for for dbresult
			
			//평균 배열에 들어가있는 값을 정리
			for tmpLr:Int in 0 ..< 2 { //loop 0 ~ 1
				var targetArrayPointer:Array<StatsDataElement> = /* 타겟 배열 포인터. */
					isGameTable ? dataGameResults : ( /* 게임 테이블이면 테이블배열 참조 */
						tmpLr == 0 ? dataBeforeStartArray : dataClearReducedArray
					);
				
				for i:Int in 0 ..< targetArrayPointer.count {
					if (targetArrayPointer[i].numberDataArray == nil) {
						continue;
					} //평균취할게 없으면 넘김.
					//평균취해야 하는경우
					var nResult:Float = targetArrayPointer[i].numberData; //초기값은 배열에 없으므로 미리 추기함
					for j:Int in 0 ..< targetArrayPointer[i].numberDataArray!.count {
						nResult += targetArrayPointer[i].numberDataArray![j];
					}
					
					switch(dataPointSelection) {
						case 4: //총 터치 수는 나눌 필요가 없음
							//nothing to do
							break;
						default: //평균 구함. 1을 더하는 이유는 배열에 하나가 추가가 안 되어 있는 상태라서.
							nResult /= Float(targetArrayPointer[i].numberDataArray!.count + 1);
							break;
					}
					
					targetArrayPointer[i].numberData = nResult; //평균값 대입
					targetArrayPointer[i].numberDataArray = nil; //배열 초기화
				} //end for
				
			} //end for
			
			switch(dataPointSelection) {
				case 0: //두개를 합친 종합 데이터
					
					//이제 같은 ID끼리 묶어서 배열에 정리하자.
					for i:Int in 0 ..< dataBeforeStartArray.count {
						//start를 돌면서 end랑 같은걸 찾아 하나의 배열에 합쳐 넣을거임
						let statsElement:StatsDataElement = StatsDataElement();
						//시간 합산. 통계에서 요구하는게 따로따로면 합산 필요가 없음
						statsElement.numberData = dataBeforeStartArray[i].numberData + dataClearReducedArray[i].numberData;
						statsElement.dataID = dataBeforeStartArray[i].dataID;
						statsElement.dateComponents = dataBeforeStartArray[i].dateComponents;
						dataUntilAlarmOff += [statsElement]; //통계 배열에 추가
						
						print("STATS id:", statsElement.dataID, ", result:", statsElement.numberData, ", date:",
						      statsElement.dateComponents!.year,"-",statsElement.dateComponents!.month,"-",statsElement.dateComponents!.day);
					} //end for
					toReturnDatasArray = dataUntilAlarmOff; //Return pointer
					
					break;
				case 1: //게임 시작 전까지 걸린 시간
					toReturnDatasArray = dataBeforeStartArray;
					break;
				case 2: //게임 플레이 시간
					toReturnDatasArray = dataClearReducedArray;
					break;
				case 3, 4, 5, 6: //게임 데이터 리턴
					toReturnDatasArray = dataGameResults;
					break;
				default: break;
			}
			
			
			
			
			
		} catch {
			
		}
		
		
		//통계 데이터값 return
		return toReturnDatasArray;
		
	} //end func
	
}