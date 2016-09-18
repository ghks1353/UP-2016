//
//  AchievementManager.swift
//  UP
//
//  Created by ExFl on 2016. 5. 26..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import SwiftyJSON;

class AchievementManager {
	
	static var achievementLoaded:Bool = false;
	static var achievementJsonFile:NSDictionary?;
	
	//도전과제 element가 담긴 리스트. 여기서 json을 읽고 parse해서 들어감
	static var achievementList:Array<AchievementElement> = Array<AchievementElement>();
	
	static func initManager() {
		//load file
		if (achievementLoaded) {
			return;
		}
		
		print("Initing achievements");
		var jStr:String = "";
		if let Path = Bundle.main.path(forResource: "AchievementList", ofType: "json") {
			do {
				jStr = try NSString(contentsOfFile: Path, usedEncoding: nil) as String
			} catch {
				// contents could not be loaded
			}
		} else {
			// example.txt not found!
		}
		
		let jData = JSON.parse(jStr); //JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("AchievementList", ofType: "json")!)!);
		//print("len", jData["list"].arrayValue.count);
		//print( jData["list"][0]["id"].string );
		
		//도전과제 파싱
		for i:Int in 0 ..< jData["list"].arrayValue.count {
			let tmpAchievement:AchievementElement = AchievementElement();
			tmpAchievement.id = jData["list"][i]["id"].string!;
			tmpAchievement.name = jData["list"][i]["name"][ Languages.currentLocaleCode ].string!;
			tmpAchievement.description = jData["list"][i]["description"][ Languages.currentLocaleCode ].string!;
			tmpAchievement.checkTargets = jData["list"][i]["targets"].arrayValue.map {$0.string!};
			tmpAchievement.equalStr = jData["list"][i]["valueEquals"].arrayValue.map {$0.string!};
			tmpAchievement.checkVals = jData["list"][i]["values"].arrayValue.map {$0.float!};
			tmpAchievement.rewardsID = jData["list"][i]["rewards"].arrayValue.map {$0.string!};
			tmpAchievement.rewardsAmount = jData["list"][i]["rewardsAmount"].arrayValue.map {$0.float!};
			
			tmpAchievement.isHiddenTitle = jData["list"][i]["hiddenTitle"].bool!;
			tmpAchievement.isHiddenDescription = jData["list"][i]["hiddenDescription"].bool!;
			achievementList += [tmpAchievement];
		}
		
		achievementLoaded = true;
		
	} //end init.
	
	//ID로 아이콘 가져오기
	static func getIconNameFromID(_ achievementID:String) -> String {
		switch(achievementID) { //ID에 따라 준비된 아이콘들 표시
			default: break;
		}
		
		//return blank
		return "achievements-icon-blank.png";
	}
	
}
