//
//  AchievementManager.swift
//  UP
//
//  Created by ExFl on 2016. 5. 26..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
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
		if let Path = NSBundle.mainBundle().pathForResource("AchievementList", ofType: "json") {
			do {
				jStr = try NSString(contentsOfFile: Path, usedEncoding: nil) as String
			} catch {
				// contents could not be loaded
			}
		} else {
			// example.txt not found!
		}
		
		let jData = JSON.parse(jStr); //JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("AchievementList", ofType: "json")!)!);
		print("len", jData["list"].arrayValue.count);
		print( jData["list"][0]["id"].string );
		
		//도전과제 파싱
		for i:Int in 0 ..< jData["list"].arrayValue.count {
			let tmpAchievement:AchievementElement = AchievementElement();
			tmpAchievement.id = String( jData["list"][i]["id"].string );
			tmpAchievement.name = String( jData["list"][i]["name"][ Languages.currentLocaleCode ].string );
			
		}
		
		
	}
	
}