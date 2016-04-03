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

	게임 값 저장 수치(타입3) 의 경우 ,로 구분한 Str에 저장
		0 -> 게임ID
		1 -> 정상적으로 클리어한 경우 0, 포기했을 경우 1
		2 -> 게임 시작 시간 (NSDate timestamp)
		3 -> 게임 플레이 시간
		4 -> 게임오버 혹은 그와 상정하는 결과에 대한 카운트 횟수
		5 -> 전체 행동수 (터치 등)
		6 -> 유효 행동수 (조작 터치)
		7 -> 중간에 백그라운드로 나간 횟수 (졸아서 화면이 꺼졌다거나 등)
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
	static let upDBTableStats = Table("statisticsCollection"); //통계 자료를 모아놓는 테이블
	
	//DataManager init (nsDefault의 init와는 다르게 작동함)
	static func initDataManager() {
		let libPathArr:NSArray = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true);
		
		print("Database init works started");
		do {
			//DB 연결
			upDatabaseConnection = try Connection( libPathArr.objectAtIndex(0) as! String + "db.sqlite3" );
			//테이블 생성 (없을 경우)
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
	
	
}