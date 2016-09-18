//
//  AlarmElements.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation

class AlarmElements:NSObject {
	
	internal var alarmName:String = "";
	internal var alarmMemo:String = ""; //added
	
	internal var gameSelected:Int = 0;
	internal var alarmID:Int = 0;
	internal var alarmRepeat:Array<Bool> = [false, false, false, false, false, false, false];
	
	internal var alarmSound:String = "";
	internal var alarmSoundLevel:Int = 100; //added. 0~100.
	
	internal var alarmFireDate:Date = Date();
	
	//alarm on-off toggle
	internal var alarmToggle:Bool = false;
	
	//Game clear check bool
	internal var alarmCleared:Bool = false; //false인 경우, merge 대상에서 빠짐.
	
	//Class to NSData
	func encodeWithCoder(_ aCoder: NSCoder!) {
		aCoder.encode(alarmName, forKey: "alarmName");
		aCoder.encode(alarmMemo, forKey: "alarmMemo");
		
		aCoder.encode(gameSelected, forKey: "gameSelected");
		aCoder.encode(alarmID, forKey: "alarmID");
		for i:Int in 0 ..< alarmRepeat.count {
			aCoder.encode(alarmRepeat[i], forKey: "alarmRepeat-" + String(i));
		}
		
		aCoder.encode(alarmSoundLevel, forKey: "alarmSoundLevel");
		aCoder.encode(alarmSound, forKey: "alarmSound");
		aCoder.encode(Int(alarmFireDate.timeIntervalSince1970), forKey: "alarmFireDate");
		
		//toggle
		aCoder.encode(alarmToggle, forKey: "alarmToggle");
		//game clear toggle
		aCoder.encode(alarmCleared, forKey: "alarmCleared");
	}
	
	//Decode from NSData to class
	init(coder aDecoder: NSCoder!) {
		alarmName = aDecoder.decodeObject(forKey: "alarmName") as! String;
		
		if (aDecoder.containsValue(forKey: "alarmMemo")) {
			alarmMemo = aDecoder.decodeObject(forKey: "alarmMemo") as! String;
		} else { //memo not exists fallback
			alarmMemo = ""; //default empty.
		}
		
		gameSelected = aDecoder.decodeInteger(forKey: "gameSelected");
		alarmID = aDecoder.decodeInteger(forKey: "alarmID");
		for i:Int in 0 ..< alarmRepeat.count {
			alarmRepeat[i] = aDecoder.decodeBool(forKey: "alarmRepeat-" + String(i));
		}
		
		if (aDecoder.containsValue(forKey: "alarmSoundLevel")) {
			alarmSoundLevel = aDecoder.decodeInteger(forKey: "alarmSoundLevel");
		} else { //sound not exists fallback
			alarmSoundLevel = 80; //default 80%
		}
		alarmSound = aDecoder.decodeObject(forKey: "alarmSound") as! String;
		alarmFireDate = Date(timeIntervalSince1970: TimeInterval(aDecoder.decodeInteger(forKey: "alarmFireDate")));
		
		//toggle
		alarmToggle = aDecoder.decodeBool(forKey: "alarmToggle");
		//game clear toggle
		alarmCleared = aDecoder.decodeBool(forKey: "alarmCleared");
	}
	
	override init() {
	}
	
	internal func initObject(_ name:String, memo:String, game:Int, repeats:Array<Bool>, soundSize:Int, sound:String, alarmDate:Date, alarmTool:Bool, id:Int) {
		alarmName = name; alarmMemo = memo;
		gameSelected = game; alarmRepeat = repeats;
		
		alarmSoundLevel = soundSize;
		alarmSound = sound; alarmFireDate = alarmDate;
		alarmToggle = alarmTool; alarmID = id;
		alarmCleared = false; //Default game clear toggle is false.
	}
	
}
