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
	static var isAlarmMergedFirst:Bool = false; //첫회 merge 체크용
	
	static func mergeAlarm() {
		//스케줄된 알람들 가져와서 지난것들 merge함
		DataManager.initDefaults();
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
		
		var savedAlarm:NSData; var scdAlarm:Array<AlarmElements> = [];
		if (DataManager.nsDefaults.objectForKey("alarmsList") != nil) {
			savedAlarm = DataManager.nsDefaults.objectForKey("alarmsList") as! NSData;
			alarmsArray = NSKeyedUnarchiver.unarchiveObjectWithData(savedAlarm) as! [AlarmElements];
			scdAlarm = alarmsArray; //this is pointer of alarmsArray.
		}
		
		var scdNotifications:Array<UILocalNotification> = UIApplication.sharedApplication().scheduledLocalNotifications!;
		
		print("Scheduled alarm count", scdAlarm.count);
		for (var i:Int = 0; i < scdAlarm.count; ++i) {
			//Toggle on된것 대상으로만 검사
			if (scdAlarm[i].alarmToggle == false) {
				print("Scheduled alarm", scdAlarm[i].alarmID, " state off. skipping");
				continue;
			}
			
			print("alarm id", scdAlarm[i].alarmID, " firedate", scdAlarm[i].alarmFireDate.timeIntervalSince1970);
			print("current firedate", NSDate().timeIntervalSince1970);
			if (scdAlarm[i].alarmFireDate.timeIntervalSince1970 <= NSDate().timeIntervalSince1970
				&& scdAlarm[i].alarmCleared == false /* false = test */) { /* 시간이 지났어도, 게임을 클리어 해야됨. 게임 클리어시 true로 설정후 merge 한번더 하면됨 */
					print("Merge start:", scdAlarm[i].alarmID);
				//알람 merge 대상. 우선 일치하는 ID의 알람을 스케줄에서 삭제함
				for (var j:Int = 0; j < scdNotifications.count; ++j) {
					if (scdNotifications[j].userInfo!["id"] as! Int == scdAlarm[i].alarmID) {
						UIApplication.sharedApplication().cancelLocalNotification(scdNotifications[j]);
					}
				} //end for
				
				//다음 Repeat 대상이 있는지 체크
				let todayDate:NSDateComponents = NSCalendar.currentCalendar().components( .Weekday, fromDate: NSDate());
				//TODO - 1. 오늘의 요일을 얻어옴. 2. 다음 날짜 알람 체크. 3. 날짜만큼 더함.
				//단, 오늘날짜가 아니라 다음날짜로 계산해야함. (왜냐면 오늘은 울렸으니깐.)
				var nextAlarmVaild:Int = -1;
				for (var k:Int = todayDate.weekday ==  7 ? 0 : (todayDate.weekday - 0 /* 다음날짜부터 */); k < scdAlarm[i].alarmRepeat.count; ++k) {
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
				scdAlarm[i].alarmCleared = false; // 게임클리어 리셋셋
					
				//TODO 2
				//다음 알람 날짜에 알람 추가. (몇일 차이나는지 구해서 day만 더해주면됨. 없으면 추가안하고 토글종료)
				if (nextAlarmVaild == -1) {
					//반복 없는 경우 알람 토글 종료
					scdAlarm[i].alarmToggle = false;
					print("Alarm toggle finished (no-repeat alarm)");
				} else {
					//반복인 경우 다음 반복일 계산
					print("Alarm toggle will repeat");
					var fireAfterDay:Int = 0;
					if (nextAlarmVaild - (todayDate.weekday - 1) > 0) {
						fireAfterDay = nextAlarmVaild - (todayDate.weekday - 1);
						print("Firedate is over today: ", fireAfterDay);
					} else {
						fireAfterDay = (7 - (todayDate.weekday - 1)) + nextAlarmVaild;
						print("Firedate is before today: ", fireAfterDay);
					}
					
					//alarmdate add
					scdAlarm[i].alarmFireDate = UPUtils.addDays(scdAlarm[i].alarmFireDate, additionalDays: fireAfterDay);
					
					//add new push for next alarm
					addLocalNotification(scdAlarm[i].alarmName,	aFireDate: scdAlarm[i].alarmFireDate, gameID: scdAlarm[i].gameSelected,
						soundFile: scdAlarm[i].alarmSound, repeatInfo: scdAlarm[i].alarmRepeat, alarmID: scdAlarm[i].alarmID);
					//add 30sec needed
					var dateForRepeat:NSDate = NSDate(timeIntervalSince1970: scdAlarm[i].alarmFireDate.timeIntervalSince1970);
					let tmpNSComp:NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: dateForRepeat);
					tmpNSComp.second = 0;
					dateForRepeat = NSCalendar.currentCalendar().dateFromComponents(tmpNSComp)!;
					addLocalNotification(scdAlarm[i].alarmName,	aFireDate: dateForRepeat, gameID: scdAlarm[i].gameSelected,
						soundFile: scdAlarm[i].alarmSound, repeatInfo: scdAlarm[i].alarmRepeat, alarmID: scdAlarm[i].alarmID);
					print("Alarm added successfully.");
					
				} //end vaild chk
				
					
				//todayDate.weekday
				
			} //alarm merge check if end
			
		} //for end
		print("Merge is done. time to save!");
		DataManager.nsDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(alarmsArray), forKey: "alarmsList");
		DataManager.nsDefaults.synchronize();
		
		//Badge 표시용
		let toBadgeShow:Bool = DataManager.nsDefaults.boolForKey(DataManager.settingsKeys.showBadge);
		if (toBadgeShow) {
			var badgeNumber:Int = 0;
			for (var i:Int = 0; i < alarmsArray.count; ++i) {
				if (alarmsArray[i].alarmToggle == true) {
					badgeNumber += 1;
				}
			}
			UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber;
		} else {
			UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
		}
		
		isAlarmMergedFirst = true;
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
	} //merge end
	
	//Clear alarm all (for debug?)
	static func clearAlarm() {
		print("Clearing saved alarm");
		alarmsArray = [];
		DataManager.nsDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(alarmsArray), forKey: "alarmsList");
		DataManager.nsDefaults.synchronize();
	}
	
	//Toggle alarm (on/off)
	static func toggleAlarm(alarmID:Int, alarmStatus:Bool, isListOn:Bool = false) {
		//- 알람이 켜져있는 상태에서 끌 경우, LocalNotification도 같이 종료
		//- 알람이 꺼져있는 상태에서 킬 경우, 상황에 따라 (반복체크후) LocalNotification 추가
		if (!isAlarmMergedFirst) {
			mergeAlarm();
		} //merge first
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true;
		
		for (var i:Int = 0; i < alarmsArray.count; ++i) {
			if (alarmsArray[i].alarmID == alarmID) { //target found
				print("Toggling. target:", alarmID);
				if (alarmsArray[i].alarmToggle == alarmStatus) {
					print("status already same..!!");
					break; //상태가 같으므로 변경할 필요 없음
				}
				var scdNotifications:Array<UILocalNotification> = UIApplication.sharedApplication().scheduledLocalNotifications!;
				
				if (alarmStatus == false) { //알람 끄기
					for (var j:Int = 0; j < scdNotifications.count; ++j) {
						if (scdNotifications[j].userInfo!["id"] as! Int == alarmsArray[i].alarmID) {
							UIApplication.sharedApplication().cancelLocalNotification(scdNotifications[j]);
						}
					} //for end
					alarmsArray[i].alarmToggle = false; //alarm toggle to off.
				} else {
					//알람 켜기 (addalarm 재탕)
					let tmpsInfoObj = SoundInfoObj(soundName: "", fileName: alarmsArray[i].alarmSound);
					let tmpNSDate:NSDate = NSDate();
					let tmpNSComp:NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: tmpNSDate);
					let tComp:NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: alarmsArray[i].alarmFireDate);
					tmpNSComp.hour = tComp.hour;
					tmpNSComp.minute = tComp.minute;
					tmpNSComp.second = 0;
					alarmsArray[i].alarmFireDate = NSCalendar.currentCalendar().dateFromComponents(tmpNSComp)!;
					
					print("Comp changed date to", alarmsArray[i].alarmFireDate);
					
					let alarmsArrTmpPointer:AlarmElements = alarmsArray[i];
					alarmsArray.removeAtIndex(i);
					addAlarm(alarmsArrTmpPointer.alarmFireDate, alarmTitle: alarmsArrTmpPointer.alarmName,
						gameID: alarmsArrTmpPointer.gameSelected, soundFile: tmpsInfoObj,
						repeatArr: alarmsArrTmpPointer.alarmRepeat, insertAt: i, alarmID: alarmsArrTmpPointer.alarmID,
						redrawList: !isListOn);
					
					
					
					//return; //한번더 저장해야됨.
					break; //save
				} //end status
				break; //해당 ID를 처리했으므로 다음부터의 루프는 무의미
			} //end alarmid target search
		} //end for
		
		//save it
		print("Status change saving");
		DataManager.nsDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(alarmsArray), forKey: "alarmsList");
		DataManager.nsDefaults.synchronize();
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false;
	} //end func
	
	//Remove alarm from system
	static func removeAlarm(alarmID:Int) {
		if (!isAlarmMergedFirst) {
			mergeAlarm();
		} //merge first
		
		var scdNotifications:Array<UILocalNotification> = UIApplication.sharedApplication().scheduledLocalNotifications!;
		for (var i:Int = 0; i < scdNotifications.count; ++i) {
			if (scdNotifications[i].userInfo!["id"] as! Int == alarmID) {
				UIApplication.sharedApplication().cancelLocalNotification(scdNotifications[i]);
			}
		} //alarm del from sys
		
		for (var i:Int = 0; i < alarmsArray.count; ++i) {
			if (alarmsArray[i].alarmID == alarmID) {
				alarmsArray.removeAtIndex(i);
				break;
			}
		} //remove item from array
		
		//save it
		print("Alarm removed from system. saving");
		DataManager.nsDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(alarmsArray), forKey: "alarmsList");
		DataManager.nsDefaults.synchronize();
		
	}
	
	//Add alarm to system
	static func addAlarm(var date:NSDate, var alarmTitle:String, gameID:Int, soundFile:SoundInfoObj, repeatArr:Array<Bool>, insertAt:Int = -1, alarmID:Int = -1, redrawList:Bool = true) {
		//repeatarr에 일,월,화,수,목,금,토 순으로 채움
		
		if(alarmTitle == "") { //알람 타이틀이 없으면 소리만 울리는 상황이 발생하므로 기본 이름 설정
			alarmTitle = Languages.$("alarmDefaultName");
		}
		
		//TODO 1 -> 테스트가 필요하지만, 일단 했음.
		//repeat이 있는 경우, 현재일이 아닌 다른일에 알람이 추가된경우 현재일에 울리지 않게 함.
		//해결방안- firedate를 해당 다른일부터 시작하게 만들면 되지 않을까?
		let todayDate:NSDateComponents = NSCalendar.currentCalendar().components( .Weekday, fromDate: NSDate());
		var fireOnce:Int = -1; /* 반복요일 설정이 없는경우 1회성으로 판단하고 date 변화 없음) */
		var fireSearched:Bool = false;
		for (var i:Int = 0; i < repeatArr.count; ++i) {
			if (repeatArr[i] == true) {
				fireOnce = i; break;
			}
		}
		if (fireOnce != -1) { //여러번 울려야 하는 경우 오늘을 포함해서 다음 fireDate까지만 더함
			for (var i:Int = todayDate.weekday ==  7 ? 0 : (todayDate.weekday - 1); i < repeatArr.count; ++i) {
				if (repeatArr[i] == true) {
					fireOnce = i; fireSearched = true; break;
				}
			} //없을경우 다음주로 넘어간것으로 치고 한번더 루프
			if (!fireSearched) {
				for (var i:Int = 0 ; i < repeatArr.count; ++i) {
					if (repeatArr[i] == true) {
						fireOnce = i; fireSearched = true; break;
					}
				}
			}
		}
		
		print("Next alarm date is ",fireOnce," (-1: no repeat, 0=sunday)");
		if (fireOnce == -1 || (fireSearched && fireOnce == todayDate.weekday - 1)) {
			//Firedate modifiy not needed but check time
			//시간이 과거면 알람 추가 안해야함 + 다음날로 넘겨야됨
			if (date.timeIntervalSince1970 <= (NSDate().timeIntervalSince1970)) {
				//과거의 알람이기 때문에, 다음날로 넘겨야됨!
				print("Past alarm!! add 1 day");
				date = UPUtils.addDays(date, additionalDays: 1);
			}
			
		} else {
			//Firedate modify.
			var fireAfterDay:Int = 0;
			if (fireOnce - (todayDate.weekday - 1) > 0) {
				fireAfterDay = fireOnce - (todayDate.weekday - 1);
				print("Firedate is over today: ", fireAfterDay);
				
			} else {
				fireAfterDay = (7 - (todayDate.weekday - 1)) + fireOnce;
				print("Firedate is before today: ", fireAfterDay);
				
			}
			//Add to date
			date = UPUtils.addDays(date, additionalDays: fireAfterDay);
			print("Firedate", date);
		}
		
		let alarmUUID:Int = alarmID == -1 ? Int(NSDate().timeIntervalSince1970) : alarmID;
		
		//초단위 제거
		let tmpNSComp:NSDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date);
		tmpNSComp.second = 0;
		date = NSCalendar.currentCalendar().dateFromComponents(tmpNSComp)!;
		
		AlarmManager.addLocalNotification(alarmTitle, aFireDate: date, gameID: gameID, soundFile: soundFile.soundFileName, repeatInfo: repeatArr, alarmID: alarmUUID);
		
		//30초
		tmpNSComp.second = 30;
		date = NSCalendar.currentCalendar().dateFromComponents(tmpNSComp)!;
		
		AlarmManager.addLocalNotification(alarmTitle, aFireDate: date, gameID: gameID, soundFile: soundFile.soundFileName, repeatInfo: repeatArr, alarmID: alarmUUID);
		
		//Add alarm to system (array) and save to nsdef
		let tmpAlarmEle:AlarmElements = AlarmElements();
		
		//reset
		tmpNSComp.second = 0;
		date = NSCalendar.currentCalendar().dateFromComponents(tmpNSComp)!;
		
		tmpAlarmEle.initObject(alarmTitle, game: gameID, repeats: repeatArr, sound: soundFile.soundFileName, alarmDate: date, alarmTool: true, id: alarmUUID);
		
		if (insertAt == -1) {
			//add to arr and save
			alarmsArray += [tmpAlarmEle];
		} else {
			alarmsArray.insert(tmpAlarmEle, atIndex: insertAt);
		}
		
		DataManager.nsDefaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(alarmsArray), forKey: "alarmsList");
		DataManager.nsDefaults.synchronize();
		
		
		//refresh another view
		if (redrawList) {
			AlarmListView.selfView?.createTableList();
		}
	}
	
	//내부함수
	static func addLocalNotification(aBody:String, aFireDate:NSDate, gameID:Int, soundFile:String, repeatInfo:Array<Bool>, alarmID:Int) {
		
		//Add to system
		let notification = UILocalNotification();
		notification.alertBody = aBody;
		notification.alertAction = "게임시작"; //'밀어서' 고정
		notification.fireDate = aFireDate;
		notification.soundName = soundFile;
		notification.userInfo = [
			"id": alarmID,
			"soundFile": soundFile,
			"gameCategory": gameID,
			"repeat": repeatInfo
		];
		notification.repeatInterval = .Minute; //30초 간격 (1분 ~ 30초)
		UIApplication.sharedApplication().scheduleLocalNotification(notification);
		
	}
	
}