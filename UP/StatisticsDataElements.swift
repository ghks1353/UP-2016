//
//  StatisticsDataElements.swift
//  UP
//
//  Created by ExFl on 2016. 4. 2..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation

class StatisticsDataElements:NSObject {
	//통계를 위한 데이터 타입 (NSObj)
	
	//static let TYPE_ALARM_OFF_TIME:Int = 0; //밑의 두 수치를 더한 값.
	static let TYPE_ALARM_START_TIME:Int = 0; //게임을 시작하기 전 까지 걸린 시간. 단위: 초
	static let TYPE_ALARM_CLEAR_TIME:Int = 1; //게임을 클리어하는데 걸린 시간. 단위: 초
	static let TYPE_ALARM_RESTARTED_COUNT:Int = 2; //중간에 백그라운드로 나간 후 1초 정도 지나면 잠시 존 것으로 판단함.
	static let TYPE_ALARM_GAME_DATA:Int = 3; //게임에 대한 전반적인 결과를 가짐.
	
	//통계가 저장된 날짜
	internal var statsTargetDate:NSDate = NSDate();
	internal var statsDataType:Int = 0; //저장된 데이터 타입.
	
	//값 저장 수치 (타입별 구분 사용)
	internal var statsDataInt:Int = 0;
	internal var statsDataStr:String = "";
	internal var statsDataIntArr:Array<Int> = Array<Int>(); //연속값이나 한 타입에 대한 여러값을 저장해야 할 때 사용함
	
	//// 게임 값 저장 수치(타입3) 의 경우 Int배열에 정보 저장
	//statsDataInt -> 게임ID
	//statsDataIntArr 0 -> 정상적으로 클리어한 경우 0, 포기했을 경우 1
	//statsDataIntArr 1 -> 게임오버 혹은 그와 상정하는 결과에 대한 카운트 횟수
	//statsDataIntArr 2 -> 전체 행동수 (터치 등)
	//statsDataIntArr 3 -> 유효 행동수 (조작 터치)
	
	
	//Class to NSData
	func encodeWithCoder(aCoder: NSCoder!) {
		aCoder.encodeInteger(statsDataType, forKey: "statsDataType");
		aCoder.encodeInteger(Int(statsTargetDate.timeIntervalSince1970), forKey: "statsTargetDate");
		
		aCoder.encodeInteger(statsDataInt, forKey: "statsDataInt");
		aCoder.encodeObject(statsDataStr, forKey: "statsDataStr");
		
		//배열을 여러개의 키로 저장
		for i:Int in 0 ..< statsDataIntArr.count {
			aCoder.encodeInteger(statsDataIntArr[i], forKey: "statsDataIntArr-" + String(i));
		}
	} //end func
	
	//Decode from NSData to class
	init(coder aDecoder: NSCoder!) {
		statsDataType = aDecoder.decodeIntegerForKey("statsDataType");
		statsTargetDate = NSDate(timeIntervalSince1970: NSTimeInterval(aDecoder.decodeIntegerForKey("statsTargetDate")));
		
		statsDataInt = aDecoder.decodeIntegerForKey("statsDataInt");
		statsDataStr = aDecoder.decodeObjectForKey("statsDataStr") as! String;
		for i:Int in 0 ..< statsDataIntArr.count {
			statsDataIntArr[i] = aDecoder.decodeIntegerForKey("statsDataIntArr-" + String(i));
		}
		
	} //end func
	
	
	override init() {
	}
	
	internal func initObject( sDataType:Int, sTargetDate:NSDate, sDataInt:Int, sDataStr:String, sDataIntArr:Array<Int> ) {
		statsDataType = sDataType; statsTargetDate = sTargetDate;
		statsDataInt = sDataInt; statsDataStr = sDataStr;
		statsDataIntArr = sDataIntArr;
	}
	
}