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
	internal var gameSelected:Int = 0;
	internal var alarmID:Int = 0;
	internal var alarmRepeat:Array<Bool> = [false, false, false, false, false, false, false];
	internal var alarmSound:String = "";
	internal var alarmFireDate:NSDate = NSDate();
	
	//alarm on-off toggle
	internal var alarmToggle:Bool = false;
	
	//Game clear check bool
	internal var alarmCleared:Bool = false; //false인 경우, merge 대상에서 빠짐.
	
	
	func encodeWithCoder(aCoder: NSCoder!) {
		aCoder.encodeObject(alarmName, forKey: "alarmName");
		aCoder.encodeInteger(gameSelected, forKey: "gameSelected");
		aCoder.encodeInteger(alarmID, forKey: "alarmID");
		for (var i:Int = 0; i < alarmRepeat.count; ++i) {
			aCoder.encodeBool(alarmRepeat[i], forKey: "alarmRepeat-" + String(i));
		}
		aCoder.encodeObject(alarmSound, forKey: "alarmSound");
		aCoder.encodeInteger(Int(alarmFireDate.timeIntervalSince1970), forKey: "alarmFireDate");
		
		//toggle
		aCoder.encodeBool(alarmToggle, forKey: "alarmToggle");
		//game clear toggle
		aCoder.encodeBool(alarmCleared, forKey: "alarmCleared");
	}
	
	init(coder aDecoder: NSCoder!) {
		alarmName = aDecoder.decodeObjectForKey("alarmName") as! String;
		gameSelected = aDecoder.decodeIntegerForKey("gameSelected");
		alarmID = aDecoder.decodeIntegerForKey("alarmID");
		for (var i:Int = 0; i < alarmRepeat.count; ++i) {
			alarmRepeat[i] = aDecoder.decodeBoolForKey("alarmRepeat-" + String(i));
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
	
	internal func initObject(name:String, game:Int, repeats:Array<Bool>, sound:String, alarmDate:NSDate, alarmTool:Bool, id:Int) {
		alarmName = name; gameSelected = game; alarmRepeat = repeats;
		alarmSound = sound; alarmFireDate = alarmDate;
		alarmToggle = alarmTool; alarmID = id;
		alarmCleared = false; //Default game clear toggle is false.
	}
	
}