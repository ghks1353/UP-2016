//
//  AnalyticsManager.swift
//  UP
//
//  Created by ExFl on 2016. 5. 1..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import Firebase;

class AnalyticsManager {
	
	//Tracking ID
	static let T_ITEM_SCREEN:String = "Screen";
	static let T_GAME_RESULTS:String = "GameResult";
	
	//Screens
	static let T_SCREEN_MAIN:String = "Main";
	static let T_SCREEN_SETTINGS:String = "Settings";
	static let T_SCREEN_ALARMLIST:String = "AlarmList";
	static let T_SCREEN_ALARMADD:String = "AlarmAdd";
	static let T_SCREEN_STATS:String = "Statistics";
	static let T_SCREEN_CHARACTERINFO:String = "CharacterInformation";
	
	static let T_SCREEN_RESULT:String = "Result";
	
	static let T_SCREEN_GAME:String = "Game";
	
	static let T_SCREEN_PLAYGAME:String = "GameSelectWindow";
	static let T_SCREEN_PLAYGAME_READY:String = "GameSelectWindow";
	
	//Games
	static let T_GAME_NAME_JUMPUP:String = "JumpUP";
	
	//////////////
	
	//Tracking store array
	static var trackingArray:Array<String> = [];
	
	/// Tracking usage by google analytics
	static func trackScreen( _ screenName:String, registerToArray:Bool = true ) {
		Analytics.logEvent(T_ITEM_SCREEN, parameters: [
			"target": screenName as NSObject
			]);
		print("Tracking", screenName);
		if (registerToArray) {
			trackingArray += [screenName];
		}
	} //end func
	static func untrackScreen() -> Bool {
		if (trackingArray.count > 1) { //적어도 두개여야함
			print("Untracking screen");
			trackingArray.removeLast();
			trackScreen( trackingArray[ trackingArray.count - 1], registerToArray: false);
			return true;
		}
		print("Untracking failed");
		return false; // untrack failed
	}
	
	
	////////////////// Analytics custom events
	
	//Log game result
	static func sendGameResults( _ gameID:Int, isAlarm:Bool = false,
	                             startTime:Int = 0, endTime:Int = 0,
	                             diedCount:Int = 0, touchTotal:Int = 0, validTotal:Int = 0) {
		
		let dateFormatter:DateFormatter = DateFormatter();
		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss";
		
		let gamePlayTime:Int = endTime - startTime;
		
		Analytics.logEvent(T_GAME_RESULTS, parameters: [
			"id": String(gameID) as NSObject,
			"isAlarm": String(isAlarm ? "true" : "false") as NSObject,
			"startTime": dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTime))) as NSObject,
			"endTime": dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endTime))) as NSObject,
			"playtime": String(gamePlayTime) as NSObject,
			"missCount": String(diedCount) as NSObject,
			"touchTotal": String(touchTotal) as NSObject,
			"touchVaild": String(validTotal) as NSObject
			
			]);
		print("GameData analytics tracking. gameID = ", gameID);
	}
	
}
