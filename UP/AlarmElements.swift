//
//  AlarmElements.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
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
	
	internal var alarmFireDate:NSDate = NSDate();
	
	//alarm on-off toggle
	internal var alarmToggle:Bool = false;
	
	//Game clear check bool
	internal var alarmCleared:Bool = false; //false인 경우, merge 대상에서 빠짐.
	
	//Class to NSData
	func encodeWithCoder(aCoder: NSCoder!) {
		aCoder.encodeObject(alarmName, forKey: "alarmName");
		aCoder.encodeObject(alarmMemo, forKey: "alarmMemo");
		
		aCoder.encodeInteger(gameSelected, forKey: "gameSelected");
		aCoder.encodeInteger(alarmID, forKey: "alarmID");
		for i:Int in 0 ..< alarmRepeat.count {
			aCoder.encodeBool(alarmRepeat[i], forKey: "alarmRepeat-" + String(i));
		}
		
		aCoder.encodeInteger(alarmSoundLevel, forKey: "alarmSoundLevel");
		aCoder.encodeObject(alarmSound, forKey: "alarmSound");
		aCoder.encodeInteger(Int(alarmFireDate.timeIntervalSince1970), forKey: "alarmFireDate");
		
		//toggle
		aCoder.encodeBool(alarmToggle, forKey: "alarmToggle");
		//game clear toggle
		aCoder.encodeBool(alarmCleared, forKey: "alarmCleared");
	}
	
	//Decode from NSData to class
	init(coder aDecoder: NSCoder!) {
		alarmName = aDecoder.decodeObjectForKey("alarmName") as! String;
		
		if (aDecoder.containsValueForKey("alarmMemo")) {
			alarmMemo = aDecoder.decodeObjectForKey("alarmMemo") as! String;
		} else { //memo not exists fallback
			alarmMemo = ""; //default empty.
		}
		
		gameSelected = aDecoder.decodeIntegerForKey("gameSelected");
		alarmID = aDecoder.decodeIntegerForKey("alarmID");
		for i:Int in 0 ..< alarmRepeat.count {
			alarmRepeat[i] = aDecoder.decodeBoolForKey("alarmRepeat-" + String(i));
		}
		
		if (aDecoder.containsValueForKey("alarmSoundLevel")) {
			alarmSoundLevel = aDecoder.decodeIntegerForKey("alarmSoundLevel");
		} else { //sound not exists fallback
			alarmSoundLevel = 80; //default 80%
		}
		alarmSound = aDecoder.decodeObjectForKey("alarmSound") as! String;
		alarmFireDate = NSDate(timeIntervalSince1970: NSTimeInterval(aDecoder.decodeIntegerForKey("alarmFireDate")));
		
		//toggle
		alarmToggle = aDecoder.decodeBoolForKey("alarmToggle");
		//game clear toggle
		alarmCleared = aDecoder.decodeBoolForKey("alarmCleared");
	}
	
	override init() {
	}
	
	internal func initObject(name:String, memo:String, game:Int, repeats:Array<Bool>, soundSize:Int, sound:String, alarmDate:NSDate, alarmTool:Bool, id:Int) {
		alarmName = name; alarmMemo = memo;
		gameSelected = game; alarmRepeat = repeats;
		
		alarmSoundLevel = soundSize;
		alarmSound = sound; alarmFireDate = alarmDate;
		alarmToggle = alarmTool; alarmID = id;
		alarmCleared = false; //Default game clear toggle is false.
	}
	
}