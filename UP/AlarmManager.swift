//
//  AlarmManager.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit;

class AlarmManager {
	/*
		LocalNotification을 이용한 알람 설정 및 해제, 다음 알람 반복 관련 처리
		알람 설정시 월화수목금토일 반복에 대한 정보를 userInfo에 저장함.
		앱 실행 / 알람 추가 / 수정 시 다음 사항 확인.
			- 다음 반복이 필요한지 체크함
			- 필요한 경우 날짜만 더해서 (다음 알람에 대해서만) 알람을 재등록함
			- 반복이 없으면 리스트에 off상태로 둠. 알람등록은 안함
			- 다음날이 알람일이 아니지만 반복은 있는경우 그 날이 돌아올때까지 일만 추가함
	*/
	static var alarmsArray:Array<AlarmElements> = [];
	
	static func mergeAlarm() {
		//스케줄된 알람들 가져와서 지난것들 merge함
		DataManager.initDefaults();
		var savedAlarm:NSData; var scdAlarm:Array<AlarmElements> = [];
		if (DataManager.nsDefaults.objectForKey("alarmsList") != nil) {
			savedAlarm = DataManager.nsDefaults.objectForKey("alarmsList") as! NSData;
			scdAlarm = NSKeyedUnarchiver.unarchiveObjectWithData(savedAlarm) as! [AlarmElements];
		}
		
		var scdNotifications:Array<UILocalNotification> = UIApplication.sharedApplication().scheduledLocalNotifications!;
		
		print("Scheduled alarm count", scdAlarm.count);
		for (var i:Int = 0; i < scdAlarm.count; ++i) {
			print("alarm id", scdAlarm[i].alarmID, " firedate", scdAlarm[i].alarmFireDate.timeIntervalSince1970);
			print("current firedate", NSDate().timeIntervalSince1970);
			if (scdAlarm[i].alarmFireDate.timeIntervalSince1970 <= NSDate().timeIntervalSince1970) {
				//알람 merge 대상. 우선 일치하는 ID의 알람을 스케줄에서 삭제함
				for (var j:Int = 0; j < scdNotifications.count; ++j) {
					if (scdNotifications[j].userInfo!["id"] as! Int == scdAlarm[i].alarmID) {
						UIApplication.sharedApplication().cancelLocalNotification(scdNotifications[j]);
					}
				} //end for
				
				//다음 Repeat 대상이 있는지 체크
				let todayDate:NSDateComponents = NSCalendar.currentCalendar().components( .Weekday, fromDate: NSDate());
				//TODO - 1. 오늘의 요일을 얻어옴. 2. 다음 날짜 알람 체크. 3. 날짜만큼 더함.
				var nextAlarmVaild:Int = -1;
				for (var k:Int = todayDate.weekday ==  7 ? 0 : (todayDate.weekday - 1); k < scdAlarm[i].alarmRepeat.count; ++k) {
					//마지막(토요일)에는 다음주 체크
					nextAlarmVaild = scdAlarm[i].alarmRepeat[k] == true ? k : nextAlarmVaild;
					if (scdAlarm[i].alarmRepeat[k] == true) { break; }
				}
				if (todayDate.weekday != 7 && nextAlarmVaild == -1) { //찾을 수 없는경우 앞에서부터 다시 검색
					//토요일을 배제하는 이유: 토요일은 이미 일요일부터 다시 돌기 때문.
					for (var k:Int = 0; k < scdAlarm[i].alarmRepeat.count; ++k) {
						nextAlarmVaild = scdAlarm[i].alarmRepeat[k] == true ? k : nextAlarmVaild;
						if (scdAlarm[i].alarmRepeat[k] == true) { break; }
					}
				}
				print("Next alarm day (0=sunday)", nextAlarmVaild);
				//nextAlarmVaild =
				
				//TODO 2
				//다음 알람 날짜에 알람 추가. (몇일 차이나는지 구해서 day만 더해주면됨. 없으면 추가안하고 토글종료)
				
				//todayDate.weekday
				
			}
			
			
			
		}
		
		
	}
	
	//Clear alarm all (for debug?)
	static func clearAlarm() {
		print("Clearing saved alarm");
		alarmsArray = [];
		DataManager.nsDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(alarmsArray), forKey: "alarmsList");
		DataManager.nsDefaults.synchronize();
	}
	
	static func addAlarm(date:NSDate, alarmTitle:String, soundFile:SoundInfoObj, repeatArr:Array<Bool>) {
		//repeatarr에 일,월,화,수,목,금,토 순으로 채움
		
		//TODO 1
		//repeat이 있는 경우, 현재일이 아닌 다른일에 알람이 추가된경우 현재일에 울리지 않게 함.
		//해결방안- firedate를 해당 다른일부터 시작하게 만들면 되지 않을까?
		
		var notification = UILocalNotification();
		notification.alertBody = alarmTitle;
		notification.alertAction = "게임시작"; //'밀어서' 고정
		notification.fireDate = date;
		notification.soundName = soundFile.soundFileName;
		notification.userInfo = [
			"id": alarmsArray.count,
			"soundFile": soundFile.soundFileName,
			"gameCategory": 0, /* 일단 더미로 남겨놓음 */
			"repeat": repeatArr
		];
		notification.repeatInterval = .Minute; //30초 간격 (1분 ~ 30초)
		UIApplication.sharedApplication().scheduleLocalNotification(notification);
		//////////////
		
		notification = UILocalNotification(); //30초 간격을 위해 하나 더 생성함
		notification.alertBody = alarmTitle;
		notification.alertAction = "게임시작"; //'밀어서' 고정
		notification.fireDate = date.dateByAddingTimeInterval(30);
		notification.soundName = soundFile.soundFileName;
		notification.userInfo = [
			"id": alarmsArray.count,
			"soundFile": soundFile.soundFileName,
			"gameCategory": 0, /* 일단 더미로 남겨놓음 */
			"repeat": repeatArr
		];
		notification.repeatInterval = .Minute;
		UIApplication.sharedApplication().scheduleLocalNotification(notification);
		
		let tmpAlarmEle:AlarmElements = AlarmElements();
		tmpAlarmEle.initObject(alarmTitle, game: 0, repeats: repeatArr, sound: soundFile.soundFileName, alarmDate: date, alarmTool: true, id: alarmsArray.count);
		//add to arr and save
		alarmsArray += [tmpAlarmEle];
		
		DataManager.nsDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(alarmsArray), forKey: "alarmsList");
		DataManager.nsDefaults.synchronize();
		
	}
	
}