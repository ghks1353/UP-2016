//
//  AchievementManager.swift
//  UP
//
//  Created by ExFl on 2016. 5. 26..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import SwiftyJSON

class AchievementManager {
	
	static var achievementLoaded:Bool = false
	static var achievementJsonFile:NSDictionary?
	
	//도전과제 element가 담긴 리스트. 여기서 json을 읽고 parse해서 들어감
	static var achievementsData:Array<AchievementData> = []
	
	static func initManager() {
		//load file
		if (achievementLoaded) {
			return
		} //end if
		
		print("[AchievementManager] initing")
		
		var jStr:String = ""
		if let Path = Bundle.main.path(forResource: "achievements", ofType: "json") {
			do {
				jStr = try NSString(contentsOfFile: Path, usedEncoding: nil) as String
			} catch {
				// contents could not be loaded
			}
		} else {
			// example.txt not found!
		}
		
		let jData:JSON = JSON.init(parseJSON: jStr)
		
		//도전과제 파싱
		for i:Int in 0 ..< jData.arrayValue.count {
			let tAchievement:AchievementData = AchievementData()
			
			tAchievement.achievementID = jData[i]["id"].string!
			tAchievement.achievementGameCenterID = jData[i]["gamecenter-id"].string!
			
			tAchievement.achievementHidden = jData[i]["hidden"].bool!
			tAchievement.descriptionHidden = jData[i]["hidden-goal"].bool!
			
			for (key, value):(String, JSON) in jData[i]["name"] {
				tAchievement.name[ key ] = value.string!
			} //// end for
			for (key, value):(String, JSON) in jData[i]["description"] {
				tAchievement.description[ key ] = value.string!
			} //// end for
			
			let tVariablesArr:[String] = jData[i]["values"].arrayValue.map { $0.string! }
			let tComparsArr:[String] = jData[i]["values-exp"].arrayValue.map { $0.string! }
			let tValuesArr:[Double] = jData[i]["values-amount"].arrayValue.map { $0.double! }
			for j:Int in 0 ..< tVariablesArr.count {
				/// Parse variables name
				tAchievement.aVariables.append( tVariablesArr[j] )
			} //end for
			for j:Int in 0 ..< tComparsArr.count {
				/// Parse comparsions str
				tAchievement.aComparsions.append( tComparsArr[j] )
			} //end for
			for j:Int in 0 ..< tValuesArr.count {
				/// Parse values
				tAchievement.aValues.append( tValuesArr[j] )
			} //end for
			
			let tRewardsArr:[String] = jData[i]["rewards"].arrayValue.map { $0.string! }
			let tRewardAmountArr:[Double] = jData[i]["rewards-amount"].arrayValue.map { $0.double! }
			for j:Int in 0 ..< tRewardsArr.count {
				/// Parse rewards id
				tAchievement.aRewards.append( tRewardsArr[j] )
			} //end for
			for j:Int in 0 ..< tRewardAmountArr.count {
				/// Parse reward amounts
				tAchievement.aRewardAmount.append( tRewardAmountArr[j] )
			} //end for
			
			achievementsData.append( tAchievement )
		} //end for parsing.
		
		achievementLoaded = true
	} //end init.
	
	/*
	//ID로 아이콘 가져오기
	static func getIconNameFromID(_ achievementID:String) -> String {
		switch(achievementID) { //ID에 따라 준비된 아이콘들 표시
			default: break;
		}
		
		//return blank
		return "achievements-icon-blank.png";
	}*/
	
}
