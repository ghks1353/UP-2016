//
//  AlarmManager.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer
import UserNotifications

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
	static var alarmsArray:[AlarmElements] = []
	static var isAlarmMergedFirst:Bool = false //첫회 merge 체크용
	static let alarmMaxRegisterCount:Int = 20 //알람 최대 등록 가능 개수
	
	static var alarmRingActivated:Bool = false //알람 액티비티.. 아니 뷰가 뜨고 있을 때 true. (게임 진행 중일 때.)
	static var alarmSoundPlaying:Bool = false
	static var alarmAudioPlayer:AVAudioPlayer?
	
	//강제 볼륨조절용
	static var alarmVolumeView:MPVolumeView = MPVolumeView()
	static var alarmPreviousVolume:Float = 0.5 //이전 볼륨값. (알람끌때 돌리기 위해서)
	
	//특정 시간 이후로는 알람을 바로 끌 수 있도록 함
	static let alarmForceStopAvaliableSeconds:Int = 3600 //default: 3600 (1h)
	
	//미디어 알람 끄기
	static func stopSoundAlarm() {
		if (alarmSoundPlaying == false) {
			return
		}
		
		if (alarmAudioPlayer != nil) {
			alarmAudioPlayer!.stop()
			alarmAudioPlayer = nil
		}
		
		if let view = alarmVolumeView.subviews.first as? UISlider{
			view.value = alarmPreviousVolume
		} else {
			print("[AlarmManager] Volume control error. creating new context")
			alarmVolumeView = MPVolumeView()
			if let view = alarmVolumeView.subviews.first as? UISlider{
				view.value = alarmPreviousVolume
			}
		}
		
		//기본 사운드 플레이모드로 변경
		if (DeviceManager.appIsBackground == false) {
			SoundManager.setAudioPlayback(.NormalMode)
		} else {
			//백그라운드에서는 Playback Mode를 알람 모드로 설정
			SoundManager.setAudioPlayback(.AlarmMode)
		} //end if
		
		alarmSoundPlaying = false
	}
	
	
	//알람 울림 (미디어)
	static func ringSoundAlarm(_ targetAlarmElement:AlarmElements?, useVibrate:Bool = false) {
		//alarmSoundPlaying
		if (useVibrate) {
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		}
		
		//알람 사운드 플레이백 모드로 변경
		SoundManager.setAudioPlayback(.AlarmMode)
		
		if (alarmSoundPlaying == true) {
			if (alarmAudioPlayer != nil) {
				//진짜로 울리는 중이면 강제로 볼륨을 위로 설정
				alarmAudioPlayer!.volume = Float(targetAlarmElement!.alarmSoundLevel) / 100
				if let view = alarmVolumeView.subviews.first as? UISlider{
					view.value = Float(targetAlarmElement!.alarmSoundLevel) / 100
				} else {
					print("[AlarmManager] Volume control error. creating new context")
					alarmVolumeView = MPVolumeView()
				}
			}
			return //중복 울림 방지
		}
		
		if (alarmAudioPlayer != nil) {
			alarmAudioPlayer!.stop()
			alarmAudioPlayer = nil
		}
		
		//알람 끌때 볼륨을 돌리기 위해 사용함
		alarmPreviousVolume = AVAudioSession.sharedInstance().outputVolume
		
		print("[AlarmManager] is Custom:", targetAlarmElement!.alarmSoundURLString)
		
		var sPlayURL:URL?
		if (targetAlarmElement!.alarmSoundURLString != "") {
			// custom sound일 경우
			// alarm element에 저장된 url는 계속 바뀔 수 있으며 파일이 사라져있을 수 있으므로
			// 우선 현재 사운드 리스트 검색 후, 지정함
			sPlayURL = URL( fileURLWithPath: targetAlarmElement!.alarmSoundURLString )
			
			SoundManager.fetchCustomSoundsList()
			
			var soundAvaliable:Bool = false
			for i:Int in 0 ..< SoundManager.userSoundsURL.count {
				if (SoundManager.userSoundsURL[i].lastPathComponent == sPlayURL!.lastPathComponent) {
					//경로가 같은 것으로 판단하여 사운드 지정 끝.
					//(최신 URL로 덮어쓰는 작업만 함.)
					print("[AlarmManager] This alarm will play custom sound")
					sPlayURL = SoundManager.userSoundsURL[i]
					soundAvaliable = true
					break
				} //end if
			} //end for
			
			if (soundAvaliable == false) {
				//사운드를 못 찾았을 경우, 1번째 번들 사운드로 강제 전환
				sPlayURL = Bundle.main.url( forResource: SoundManager.list[0].soundFileName.components(separatedBy: ".aiff")[0], withExtension: "aiff")!
				print("[AlarmManager] This alarm will play bundle sound, custom sound error.")
			} //end if
			
		} else {
			//Bundle sound일 경우
			sPlayURL = Bundle.main.url( forResource: targetAlarmElement!.alarmSound.components(separatedBy: ".aiff")[0] , withExtension: "aiff")!
		} //end if
		
		do { alarmAudioPlayer = try AVAudioPlayer(
			contentsOf: sPlayURL!,
			fileTypeHint: nil
			);
		} catch let error as NSError {
			print("[AlarmManager]",error.description)
		}
		alarmAudioPlayer!.numberOfLoops = -1
		alarmAudioPlayer!.prepareToPlay()
		alarmAudioPlayer!.play()
		alarmAudioPlayer!.volume = Float(targetAlarmElement!.alarmSoundLevel) / 100
		if let view = alarmVolumeView.subviews.first as? UISlider{
			view.value = Float(targetAlarmElement!.alarmSoundLevel) / 100
		} else {
			print("[AlarmManager] Volume control error. creating new context")
			alarmVolumeView = MPVolumeView()
		}

		alarmSoundPlaying = true
	} // end func
	
	//알람이 켜져있는 게 있을 경우 다음 알람이 언제 울리는지 초단위로 가져옴
	static func getNextAlarmFireInSeconds() -> Int {
		//Merge된 후 실행되야 함
		if (!isAlarmMergedFirst) {
			mergeAlarm()
		} //merge first
		
		var alarmNextFireDate:Int = -1
		for i:Int in 0 ..< alarmsArray.count {
			if (alarmsArray[i].alarmToggle == false) {
				continue
			} //ignores off
			if (alarmNextFireDate == -1 || alarmNextFireDate > Int(alarmsArray[i].alarmFireDate.timeIntervalSince1970) ) {
				//적은 시간 우선으로 대입
				alarmNextFireDate = Int(alarmsArray[i].alarmFireDate.timeIntervalSince1970)
			}
		} //end for [alarmsArray]
		
		return alarmNextFireDate //-1을 리턴한 경우, 켜져있는 알람이 없음
	} //end func
	
	//울리고 있는 알람을 가져옴. 배열로 반환함
	static func getRingingAlarms() -> Array<AlarmElements> {
		//나중에 게임 클리어 후 알람을 끌 때, 울리고 있는 알람 전체를 끌 수 있게 해야됨
		//(그렇지 않으면 울린 알람만큼 게임을 깨야됨)
		
		//또한 게임 진행중일땐 앱 자체에 게임 진행중이라는 체크가 필요하며 그렇지 않을 경우
		//게임하다가 밖으로 나갔다왔는데 알람 울림화면으로 다시..
		
		var alarmElementsArray:Array<AlarmElements> = []
		
		var currentDate:Date? = Date()
		for i:Int in 0 ..< alarmsArray.count {
			if (alarmsArray[i].alarmToggle == false) {
				continue
			} //ignores off
			
			if (alarmsArray[i].alarmFireDate.timeIntervalSince1970 <= currentDate!.timeIntervalSince1970
				&& alarmsArray[i].alarmCleared == false) {
				/*  1. fired된 알람일 때.
				2. 클리어를 못했을 때.
				3. toggled된 알람일 때. */
				alarmElementsArray.append(alarmsArray[i])
			}
		} //end for
		
		currentDate = nil
		return alarmElementsArray
	} //end func
	
	//울리고 있는 알람을 가져옴. 여러개인 경우, 첫번째 알람만 리턴함
	static func getRingingAlarm() -> AlarmElements? {
		let ringingAlarmsArray:Array<AlarmElements> = getRingingAlarms()
		
		return ringingAlarmsArray.count == 0 ? nil : ringingAlarmsArray[0]
	} //end func
	
	//알람 게임 클리어 토글
	static func gameClearToggle( _ alarmID:Int, cleared:Bool ) {
		let modAlarmElement:AlarmElements = getAlarm(alarmID)!
		modAlarmElement.alarmCleared = cleared
		
		//save it
		DataManager.nsDefaults.set(NSKeyedArchiver.archivedData(withRootObject: alarmsArray), forKey: "alarmsList")
		DataManager.save()
		print("[AlarmManager] Alarm clear toggle to ..." ,cleared, "to id", alarmID)
	} //end func [gameClearToggle]
	
	static func gameClearToggle( _ untilDate:Date, cleared:Bool ) {
		
		for i:Int in 0 ..< alarmsArray.count {
			if (alarmsArray[i].alarmToggle == false) {
				continue
			} //ignores off
			
			if (alarmsArray[i].alarmFireDate.timeIntervalSince1970 <= untilDate.timeIntervalSince1970) {
				alarmsArray[i].alarmCleared = cleared
				print("[AlarmManager] Alarm clear toggle to ..." ,cleared, "to id", alarmsArray[i].alarmID)
			}
		} //end for

		//save it
		DataManager.nsDefaults.set(NSKeyedArchiver.archivedData(withRootObject: alarmsArray), forKey: "alarmsList")
		DataManager.save()
	} //end func [gameClearToggle]
	
	static func checkRegisterAlarm() -> Bool {
		if (!isAlarmMergedFirst) {
			mergeAlarm()
		} //merge first
		
		if (alarmsArray.count < alarmMaxRegisterCount) {
			return true
		}
		return false
	} //end func [check Register alarm]
	
	static func mergeAlarm(_ mergeProcess:Int = 0, notificationsArray:[AnyObject]? = nil ) {
		//스케줄된 알람들 가져와서 지난것들 merge하고, 발생할 수 있는 오류에 대해서 체크함
		DataManager.initDefaults()
		
		var savedAlarm:Data
		var scdAlarm:[AlarmElements] = []
		if (DataManager.nsDefaults.object(forKey: "alarmsList") != nil) {
			savedAlarm = DataManager.nsDefaults.object(forKey: "alarmsList") as! Data
			alarmsArray = NSKeyedUnarchiver.unarchiveObject(with: savedAlarm) as! [AlarmElements]
			scdAlarm = alarmsArray //this is pointer of alarmsArray.
		} //end if
		
		if (mergeProcess == 0) {
			if #available(iOS 10, *) {
				//ios10: uilocalnotification 쓰지 않고 unnotificationcenter사용
				let unUserNotifyCenter = UNUserNotificationCenter.current()
				var unNotifications:[UNNotificationRequest]?
				unUserNotifyCenter.getPendingNotificationRequests(completionHandler: { requests in
					unNotifications = requests
					print("[AlarmManager] iOS 10: Merging nil alarms")
					var removedCount = 0
					for it:Int in 0 ..< (unNotifications!.count) {
						let alarmTmpID:Int = unNotifications![it - removedCount].content.userInfo["id"] as! Int
						if (AlarmManager.getAlarm(alarmTmpID) == nil) {
							//REMOVE LocalNotification
							
							//unschedule
							unUserNotifyCenter.removePendingNotificationRequests(withIdentifiers: [unNotifications![it - removedCount].identifier])
							unNotifications!.remove(at: (it - removedCount))
							removedCount += 1
							print("[AlarmManager] iOS 10: Removed nil alarm ID:", alarmTmpID)
						}
					}
					mergeAlarm(1, notificationsArray: unNotifications)
					/////////////
				}) //end handler block
			} else { ///fallback ios8~9 code.
				var ios9notifications:[UILocalNotification] = UIApplication.shared.scheduledLocalNotifications!
				
				//앱을 삭제한 후 설치하거나, 데이터가 없는 경우에도 로컬알람이 울릴 수 있음.
				//이 경우, Merge했을 때 지워지게 해야함.
				print("[AlarmManager] Merging nil alarms")
				for it:Int in 0 ..< ios9notifications.count {
					let alarmTmpID:Int = ios9notifications[it].userInfo!["id"] as! Int
					if (AlarmManager.getAlarm(alarmTmpID) == nil) {
						//REMOVE LocalNotification
						UIApplication.shared.cancelLocalNotification(ios9notifications[it])
						print("[AlarmManager] Removed nil alarm ID:", alarmTmpID)
					}
				} //end for
				
				//Re-load list
				ios9notifications = UIApplication.shared.scheduledLocalNotifications!
				mergeAlarm(1, notificationsArray: ios9notifications)
			} //end if [iOS10]
			return
		} //end if [mergeProcess is 0]
		
		print("[AlarmManager] Scheduled alarm count", scdAlarm.count);
		for i:Int in 0 ..< scdAlarm.count {
			let alarmTmpUUID:String = scdAlarm[i].notifyUUID == "" ? UUID().uuidString : scdAlarm[i].notifyUUID
			if (scdAlarm[i].notifyUUID == "") {
				scdAlarm[i].notifyUUID = alarmTmpUUID
			} //end if
			
			//없는 사운드에 대해서 첫번째 사운드로 적용
			if (SoundManager.findSoundObjectWithFileName(scdAlarm[i].alarmSound) == nil) {
				//찾고 있는 사운드는 존재하지 않으니, 맨 첫번째 사운드로 바꿈.
				print("[AlarmManager] Merging sound to first element", scdAlarm[i].alarmID)
				scdAlarm[i].alarmSound = SoundManager.list[0].soundFileName
				if (scdAlarm[i].alarmToggle == true) {
					//Toggle 상태면 기존 Notification을 삭제하고 새로 바꿈
					if #available(iOS 10, *) {
						for j:Int in 0 ..< (notificationsArray!.count) {
							let arrTmpID:Int = (notificationsArray![j] as! UNNotificationRequest).content.userInfo["id"] as! Int
							if ( arrTmpID == scdAlarm[i].alarmID) {
								UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(notificationsArray![j] as! UNNotificationRequest).identifier])
							} //end if
						} //end for [notifi]
					} else { //if iOS 9 or below,
						for j:Int in 0 ..< notificationsArray!.count {
							if ((notificationsArray![j] as! UILocalNotification).userInfo!["id"] as! Int == scdAlarm[i].alarmID) {
								UIApplication.shared.cancelLocalNotification(notificationsArray![j] as! UILocalNotification)
							} //end if
						} //end for
						
					} //end if [is iOS10]
					print("[AlarmManager] Removed schedlued alarm in merge");
					
					//iOS8~9는 30초, 1분 간격으로 추가해야하므로 아래 과정
					if ((scdAlarm[i].alarmFireDate.timeIntervalSince1970 <= Date().timeIntervalSince1970
						&& scdAlarm[i].alarmCleared == true) == false) { //말 그대로, Merge대상에 포함이 안되었을 경우만 다시 추가함
						print("[AlarmManager] Adding to schedule alarm", scdAlarm[i].alarmID)
						
						//add new push for next alarm
						var dateForRepeat:Date = Date(timeIntervalSince1970: scdAlarm[i].alarmFireDate.timeIntervalSince1970)
						var tmpNSComp:DateComponents = (Calendar.current as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: dateForRepeat)
						tmpNSComp.second = 0
						dateForRepeat = Calendar.current.date(from: tmpNSComp)!
						
						addLocalNotification(scdAlarm[i].alarmName,	aFireDate: dateForRepeat, gameID: scdAlarm[i].gameSelected,
						                     soundFile: scdAlarm[i].alarmSound, repeatInfo: scdAlarm[i].alarmRepeat, alarmID: scdAlarm[i].alarmID, notifiUUID: alarmTmpUUID)
						
						//add 30sec needed
						dateForRepeat = Date(timeIntervalSince1970: scdAlarm[i].alarmFireDate.timeIntervalSince1970);
						tmpNSComp = (Calendar.current as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: dateForRepeat)
						tmpNSComp.second = 30
						dateForRepeat = Calendar.current.date(from: tmpNSComp)!
						addLocalNotification(scdAlarm[i].alarmName,	aFireDate: dateForRepeat, gameID: scdAlarm[i].gameSelected,
											 soundFile: scdAlarm[i].alarmSound, repeatInfo: scdAlarm[i].alarmRepeat, alarmID: scdAlarm[i].alarmID, notifiUUID: alarmTmpUUID)
						//Add end..
					} //end if [alarm is future]
					
					
				} //end if
			} //end if
			
			//이 다음은, Toggle on된것 대상으로만 검사
			if (scdAlarm[i].alarmToggle == false) {
				print("Scheduled alarm", scdAlarm[i].alarmID, " state off. skipping")
				
				//혹시 모르니 꺼져있는 건 스케줄된 시스템 노티에서 제거.
				//..todo
				
				continue
			}
			print("[AlarmManager] alarm id", scdAlarm[i].alarmID, " firedate", scdAlarm[i].alarmFireDate.timeIntervalSince1970)
			
			if (scdAlarm[i].alarmFireDate.timeIntervalSince1970 <= Date().timeIntervalSince1970
				&& scdAlarm[i].alarmCleared == true ) { /* 시간이 지났어도, 게임을 클리어 해야됨. 게임 클리어시 true로 설정후 merge 한번더 하면됨 */
					print("[AlarmManager] Merge start:", scdAlarm[i].alarmID)
					//알람 merge 대상. 우선 일치하는 ID의 알람을 스케줄에서 삭제함
					if #available(iOS 10, *) {
						for j:Int in 0 ..< (notificationsArray!.count) {
							let arrTmpID:Int = (notificationsArray![j] as! UNNotificationRequest).content.userInfo["id"] as! Int
							if ( arrTmpID == scdAlarm[i].alarmID) {
								print("[AlarmManager] Removing pending notifi:", arrTmpID, "as", (notificationsArray![j] as! UNNotificationRequest).identifier)
								UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(notificationsArray![j] as! UNNotificationRequest).identifier])
							} //end if
							
						}
						
					} else {
						for j:Int in 0 ..< notificationsArray!.count {
							if ((notificationsArray![j] as! UILocalNotification).userInfo!["id"] as! Int == scdAlarm[i].alarmID) {
								UIApplication.shared.cancelLocalNotification(notificationsArray![j] as! UILocalNotification)
							} //end if
						} //end for
					} //end if [iOS10]
			
				//다음 Repeat 대상이 있는지 체크
				let todayDate:DateComponents = Calendar.current.dateComponents( [.weekday] , from: Date())
				
				//현재 날짜로부터 반복을 체크하여 반복을 몇일 뒤에 할지 설정하고, 그것에 대한 오차로 발생한 여러번 울리는건
				//아래 최종적으로 다음 알람 울릴날짜 더할때 알람 날짜와 현재 날짜의 차를 체크하여 더하므로
				//반복 대상은 오늘 날짜를 기준으로 체크하도록 한다.
				
				//TODO - 1. 오늘의 요일을 얻어옴. 2. 다음 날짜 알람 체크. 3. 날짜만큼 더함.
				//단, 오늘날짜가 아니라 다음날짜로 계산해야함. (왜냐면 오늘은 울렸으니깐.)
				var nextAlarmVaild:Int = -1;
				for k:Int in (todayDate.weekday! ==  7 ? 0 : (todayDate.weekday/* 다음날짜부터 */))! ..< scdAlarm[i].alarmRepeat.count {
					//마지막(토요일)에는 다음주 체크
					nextAlarmVaild = scdAlarm[i].alarmRepeat[k] == true ? k : nextAlarmVaild
					if (scdAlarm[i].alarmRepeat[k] == true) {
						break
					} //end if
				} //end for
				if (todayDate.weekday != 7 && nextAlarmVaild == -1) { //찾을 수 없는경우 앞에서부터 다시 검색
					//토요일을 배제하는 이유: 토요일은 이미 일요일부터 다시 돌기 때문.
					for k:Int in 0 ..< scdAlarm[i].alarmRepeat.count {
						nextAlarmVaild = scdAlarm[i].alarmRepeat[k] == true ? k : nextAlarmVaild
						if (scdAlarm[i].alarmRepeat[k] == true) {
							break
						} //end if
					}
				} //end if
				print("[AlarmManager] Next alarm day (0=sunday)", nextAlarmVaild)
				scdAlarm[i].alarmCleared = false // 게임클리어 리셋
					
				//TODO 2
				//다음 알람 날짜에 알람 추가. (몇일 차이나는지 구해서 day만 더해주면됨. 없으면 추가안하고 토글종료)
				if (nextAlarmVaild == -1) {
					//반복 없는 경우 알람 토글 종료
					scdAlarm[i].alarmToggle = false
					print("[AlarmManager] Alarm toggle finished (no-repeat alarm)")
				} else {
					//반복인 경우 다음 반복일 계산
					//단, 다음 반복 날짜가 현재 시간보다 아래인 경우, 계속 반복하여 넘을 때까지 계산해야함..
					//위 문장 16.11.10에 개선사항으로 추가됨
					
					//알람 울린 날짜와 오늘 날짜의 날짜간 차이를 구해서, 더해주면 될듯
					//어차피 위크데이 계산은 오늘 날짜를 기준으로 하므로..
					
					print("[AlarmManager] Alarm toggle will repeat")
					var fireAfterDay:Int = 0
					let firedDateSeconds:Int = Int(scdAlarm[i].alarmFireDate.timeIntervalSince1970)
					
					if (firedDateSeconds < Int(Date().timeIntervalSince1970)) {
						fireAfterDay = Int(floor((Double(Date().timeIntervalSince1970) - Double(firedDateSeconds)) / 86400));
						print("[AlarmManager] Adding days for correct alarm calc:", fireAfterDay)
					} //end if
					
					if (nextAlarmVaild - (todayDate.weekday! - 1) > 0) {
						fireAfterDay += nextAlarmVaild - (todayDate.weekday! - 1)
						print("[AlarmManager] Firedate is over today: ", fireAfterDay)
					} else {
						fireAfterDay += (7 - (todayDate.weekday! - 1)) + nextAlarmVaild;
						print("[AlarmManager] Firedate is before today: ", fireAfterDay)
					} //end if
					
					//alarmdate add
					scdAlarm[i].alarmFireDate = UPUtils.addDays(scdAlarm[i].alarmFireDate, additionalDays: fireAfterDay)
					
					//add new push for next alarm
					var dateForRepeat:Date = Date(timeIntervalSince1970: scdAlarm[i].alarmFireDate.timeIntervalSince1970)
					var tmpNSComp:DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateForRepeat)
					tmpNSComp.second = 0
					dateForRepeat = Calendar.current.date(from: tmpNSComp)!
					
					addLocalNotification(scdAlarm[i].alarmName,	aFireDate: dateForRepeat, gameID: scdAlarm[i].gameSelected,
						soundFile: scdAlarm[i].alarmSound, repeatInfo: scdAlarm[i].alarmRepeat, alarmID: scdAlarm[i].alarmID, notifiUUID: alarmTmpUUID)
					//if #available(iOS 10.0, *) {
					//} else {
					//add 30sec needed
					dateForRepeat = Date(timeIntervalSince1970: scdAlarm[i].alarmFireDate.timeIntervalSince1970)
					tmpNSComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: dateForRepeat)
					tmpNSComp.second = 30
					dateForRepeat = Calendar.current.date(from: tmpNSComp)!
					addLocalNotification(scdAlarm[i].alarmName,	aFireDate: dateForRepeat, gameID: scdAlarm[i].gameSelected,
						soundFile: scdAlarm[i].alarmSound, repeatInfo: scdAlarm[i].alarmRepeat, alarmID: scdAlarm[i].alarmID, notifiUUID: alarmTmpUUID);
					//}
					print("[AlarmManager] Alarm added successfully.")
				} //end vaild chk
				
			//alarm merge check if end
			} else {
				//알람이 켜져있지만, 시간이 지나지 않았거나 게임을 클리어하지 않은 경우
				print("[AlarmManager] Alarm is on but not cleared (or not passed), id:", scdAlarm[i].alarmID)
				//이런 경우 firedate를 먼저 검사해본다.
				print("[AlarmManager] time -> ", scdAlarm[i].alarmFireDate.timeIntervalSince1970, "curr:", Date().timeIntervalSince1970 )
				print("[AlarmManager] is cleared already?", scdAlarm[i].alarmCleared )
				//버그가 생겼을 때 LocalNotification에 나타나지 않았으므로
				//LocalNotification에 등록되어 있는가를 검사한 후, 등록을 시켜주자.
				
			}  //end if
			
		} //for end
		print("[AlarmManager] Merge is done. time to save!")
		DataManager.nsDefaults.set(NSKeyedArchiver.archivedData(withRootObject: alarmsArray), forKey: "alarmsList")
		DataManager.save()
		
		//Badge 표시용
		let toBadgeShow:Bool = DataManager.nsDefaults.bool(forKey: DataManager.settingsKeys.showBadge)
		if (toBadgeShow) {
			var badgeNumber:Int = 0
			for i:Int in 0 ..< alarmsArray.count {
				if (alarmsArray[i].alarmToggle == true) {
					badgeNumber += 1
				}
			}
			UIApplication.shared.applicationIconBadgeNumber = badgeNumber
		} else {
			UIApplication.shared.applicationIconBadgeNumber = 0
		} //end if
		
		isAlarmMergedFirst = true
	} //merge end
	
	//Clear alarm all (for debug?)
	static func clearAlarm() {
		print("[AlarmManager] Clearing saved alarm")
		alarmsArray = []
		DataManager.nsDefaults.set(NSKeyedArchiver.archivedData(withRootObject: alarmsArray), forKey: "alarmsList")
		DataManager.save()
	} //end func
	
	//Find alarm from array by ID
	static func getAlarm(_ alarmID:Int)->AlarmElements? {
		for i:Int in 0 ..< alarmsArray.count {
			if (alarmsArray[i].alarmID == alarmID) {
				return alarmsArray[i];
			}
		}
		
		return nil;
	}
	
	//Toggle alarm (on/off)
	static func toggleAlarm(_ alarmID:Int, alarmStatus:Bool, isListOn:Bool = false) {
		//- 알람이 켜져있는 상태에서 끌 경우, LocalNotification도 같이 종료
		//- 알람이 꺼져있는 상태에서 킬 경우, 상황에 따라 (반복체크후) LocalNotification 추가
		if (!isAlarmMergedFirst) {
			mergeAlarm()
		} //merge first
		
		for i:Int in 0 ..< alarmsArray.count {
			if (alarmsArray[i].alarmID == alarmID) { //target found
				print("[AlarmManager] Toggling. target:", alarmID)
				if (alarmsArray[i].alarmToggle == alarmStatus) {
					print("[AlarmManager] status already same..!!")
					break //상태가 같으므로 변경할 필요 없음
				}
				
				//iOS10의 경우, 종전의 방식을 사용하지 않음
				
				if (alarmStatus == false) { //알람 끄기
					if #available(iOS 10, *) {
						//iOS 10 del
						let unUserNotifyCenter = UNUserNotificationCenter.current()
						var unNotifications:Array<UNNotificationRequest>?
						unUserNotifyCenter.getPendingNotificationRequests(completionHandler: { requests in
							unNotifications = requests
							
							for it:Int in 0 ..< (unNotifications!.count) {
								let alarmTmpID:Int = unNotifications![it].content.userInfo["id"] as! Int
								if (alarmTmpID == alarmsArray[i].alarmID) {
									unUserNotifyCenter.removePendingNotificationRequests(withIdentifiers: [unNotifications![it].identifier])
									print("[AlarmManager] iOS 10: Removed untoggled alarm ID:", alarmTmpID, "as", unNotifications![it].identifier)
								}
							}
						});
					} else {
						//iOS 8~9 del
						var scdNotifications:Array<UILocalNotification> = UIApplication.shared.scheduledLocalNotifications!
						
						for j:Int in 0 ..< scdNotifications.count {
							if (scdNotifications[j].userInfo!["id"] as! Int == alarmsArray[i].alarmID) {
								UIApplication.shared.cancelLocalNotification(scdNotifications[j])
							}
						} //for end
						
					}
					
					alarmsArray[i].alarmToggle = false //alarm toggle to off.
				} else {
					//알람 켜기 (addalarm 재탕)
					var tmpsInfoObj:SoundData?
					
					if (alarmsArray[i].alarmSoundURLString != "") {
						tmpsInfoObj = SoundManager.findSoundObjectWithFileName(alarmsArray[i].alarmSoundURLString, isCustomSound: true)
					} else {
						tmpsInfoObj = SoundManager.findSoundObjectWithFileName(alarmsArray[i].alarmSound)
					}//end if
					
					let tmpNSDate:Date = Date()
					var tmpNSComp:DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tmpNSDate)
					let tComp:DateComponents = Calendar.current.dateComponents([.hour, .minute], from: alarmsArray[i].alarmFireDate as Date)
					tmpNSComp.hour = tComp.hour
					tmpNSComp.minute = tComp.minute
					tmpNSComp.second = 0
					alarmsArray[i].alarmFireDate = Calendar.current.date(from: tmpNSComp)!
					
					print("[AlarmManager] Comp changed date to", alarmsArray[i].alarmFireDate);
					
					let alarmsArrTmpPointer:AlarmElements = alarmsArray[i]
					alarmsArray.remove(at: i)
					addAlarm(alarmsArrTmpPointer.alarmFireDate as Date, funcAlarmTitle: alarmsArrTmpPointer.alarmName,
						funcAlarmMemo: alarmsArrTmpPointer.alarmMemo,
						gameID: alarmsArrTmpPointer.gameSelected,
						alarmLevel: alarmsArrTmpPointer.alarmSoundLevel, soundFile: tmpsInfoObj!,
						repeatArr: alarmsArrTmpPointer.alarmRepeat, insertAt: i, alarmID: alarmsArrTmpPointer.alarmID,
						redrawList: !isListOn)
					
					
					
					//return; //한번더 저장해야됨.
					break //save
				} //end status
				break //해당 ID를 처리했으므로 다음부터의 루프는 무의미
			} //end alarmid target search
		} //end for
		
		//save it
		print("[AlarmManager] Status change saving")
		DataManager.nsDefaults.set(NSKeyedArchiver.archivedData(withRootObject: alarmsArray), forKey: "alarmsList")
		DataManager.save()
	} //end func
	
	//Remove alarm from system
	static func removeAlarm(_ alarmID:Int) {
		if (!isAlarmMergedFirst) {
			mergeAlarm()
		} //merge first
		
		if #available(iOS 10, *) {
			//iOS 10 del
			let unUserNotifyCenter = UNUserNotificationCenter.current()
			var unNotifications:Array<UNNotificationRequest>?
			unUserNotifyCenter.getPendingNotificationRequests(completionHandler: { requests in
				unNotifications = requests
				
				for it:Int in 0 ..< (unNotifications!.count) {
					let alarmTmpID:Int = unNotifications![it].content.userInfo["id"] as! Int
					if (alarmTmpID == alarmID) {
						unUserNotifyCenter.removePendingNotificationRequests(withIdentifiers: [unNotifications![it].identifier])
						print("[AlarmManager] iOS 10: Removed alarm ID:", alarmTmpID, "as", unNotifications![it].identifier)
					}
				}
			});
		} else {
			//iOS 8~9 del
			var scdNotifications:Array<UILocalNotification> = UIApplication.shared.scheduledLocalNotifications!
			
			for i:Int in 0 ..< scdNotifications.count {
				if (scdNotifications[i].userInfo!["id"] as! Int == alarmID) {
					UIApplication.shared.cancelLocalNotification(scdNotifications[i])
				}
			} //for end
			
		} //alarm del from sys
		
		for i:Int in 0 ..< alarmsArray.count {
			if (alarmsArray[i].alarmID == alarmID) {
				alarmsArray.remove(at: i)
				break
			}
		} //remove item from array
		
		//save it
		print("[AlarmManager] Alarm removed from system. saving")
		DataManager.nsDefaults.set(NSKeyedArchiver.archivedData(withRootObject: alarmsArray), forKey: "alarmsList")
		DataManager.save()
	} //end func
	
	//Edit alarm from system
	static func editAlarm(_ alarmID:Int, funcDate:Date, alarmTitle:String, alarmMemo:String, gameID:Int,
	                      soundLevel:Int, soundFile:SoundData, repeatArr:Array<Bool>, toggleStatus:Bool) {
		var date:Date = funcDate;
		if (!isAlarmMergedFirst) {
			mergeAlarm();
		} //merge first
		
		var alarmArrayIndex:Int = 0;
		
		if #available(iOS 10, *) {
			//iOS 10 del
			let unUserNotifyCenter = UNUserNotificationCenter.current();
			var unNotifications:Array<UNNotificationRequest>?;
			unUserNotifyCenter.getPendingNotificationRequests(completionHandler: { requests in
				unNotifications = requests;
				
				for it:Int in 0 ..< (unNotifications!.count) {
					let alarmTmpID:Int = unNotifications![it].content.userInfo["id"] as! Int
					if (alarmTmpID == alarmID) {
						unUserNotifyCenter.removePendingNotificationRequests(withIdentifiers: [unNotifications![it].identifier])
						print("[AlarmManager] iOS 10: Removed alarm ID:", alarmTmpID, "as", unNotifications![it].identifier)
					}
				}
			});
		} else {
			//iOS 8~9 del
			var scdNotifications:Array<UILocalNotification> = UIApplication.shared.scheduledLocalNotifications!
			for i:Int in 0 ..< scdNotifications.count {
				if (scdNotifications[i].userInfo!["id"] as! Int == alarmID) {
					UIApplication.shared.cancelLocalNotification(scdNotifications[i])
				}
			} //for end
			
		} //alarm del from sys
		
		for i:Int in 0 ..< alarmsArray.count {
			if (alarmsArray[i].alarmID == alarmID) {
				alarmsArray.remove(at: i)
				alarmArrayIndex = i
				break
			}
		} //remove item from array
		
		//modify date to today
		let tmpNSDate:Date = Date()
		var tmpNSComp:DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tmpNSDate)
		let tComp:DateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
		tmpNSComp.hour = tComp.hour
		tmpNSComp.minute = tComp.minute
		tmpNSComp.second = 0
		
		date = Calendar.current.date(from: tmpNSComp)!
		
		//addAlarm
		addAlarm(date, funcAlarmTitle: alarmTitle, funcAlarmMemo: alarmMemo,
			gameID: gameID, alarmLevel: soundLevel,
			soundFile: soundFile, repeatArr: repeatArr, insertAt: alarmArrayIndex, alarmID:  alarmID, isToggled: toggleStatus, redrawList: true);
		
	}
	
	//Add alarm to system
	static func addAlarm(_ funcDate:Date, funcAlarmTitle:String, funcAlarmMemo:String, gameID:Int, alarmLevel:Int, soundFile:SoundData, repeatArr:Array<Bool>, insertAt:Int = -1, alarmID:Int = -1, isToggled:Bool = true, redrawList:Bool = true) {
		//repeatarr에 일,월,화,수,목,금,토 순으로 채움
		
		var date:Date = funcDate
		var alarmTitle:String = funcAlarmTitle
		let alarmMemo:String = funcAlarmMemo
		let nUUID:String = UUID().uuidString
		
		if (alarmTitle == "") { //알람 타이틀이 없으면 소리만 울리는 상황이 발생하므로 기본 이름 설정
			alarmTitle = LanguagesManager.$("alarmDefaultName")
		} //end if
		
		//TODO 1 -> 테스트가 필요하지만, 일단 했음.
		//repeat이 있는 경우, 현재일이 아닌 다른일에 알람이 추가된경우 현재일에 울리지 않게 함.
		//해결방안- firedate를 해당 다른일부터 시작하게 만들면 되지 않을까?
		let todayDate:DateComponents = Calendar.current.dateComponents( [Calendar.Component.weekday], from: Date())
		var fireOnce:Int = -1 /* 반복요일 설정이 없는경우 1회성으로 판단하고 date 변화 없음) */
		var fireNextDay:Int = -1 /* 반복이 여러개인 경우, 과거 알람 설정 때 판단을 위한 다음 반복 날짜 구함 */
		var fireSearched:Bool = false
		var fireNextdaySearched:Bool = false
		
		for i:Int in 0 ..< repeatArr.count {
			if (repeatArr[i] == true) {
				fireOnce = i; break
			} //end if
		} //end for
		
		if (fireOnce != -1) { //여러번 울려야 하는 경우 오늘을 포함해서 다음 fireDate까지만 더함
			//오늘부터 검사하는게 맞음.
			//그러니까 이게, 오늘이 토요일이면 다음 루프를 일요일(0)부터 돌고, 
			//그런게 아니라면 루프 시작점이 현재 날짜(-1을 빼는건 weekday는 +1이기 때문임)부터 돌게 되어 있음
			//가령 금요일날 설정한다고 하면, 오늘을 포함해야 제대로ㅓ된 검사가 가능함.
			if (todayDate.weekday == 7) {
				//토요일일 경우 먼저 계산을 함. (루프는 순서대로 돌아야 하기 때문에 예외처리..)
				if (repeatArr[6] == true) { //6은 토요일
					fireOnce = 6
					fireSearched = true
				} else {
					for i:Int in 0 ..< repeatArr.count { //어차피 토요일부터 검사하기 때문에 0으로 해도 상관없음
						if (repeatArr[i] == true) {
							fireOnce = i
							fireSearched = true
							break
						} //end if
					} //end for
				} //end chk sat is true
			} else { //토요일이 아닌 경우 일반적인 방법으로 검사함
				for i:Int in (todayDate.weekday! - 1) ..< repeatArr.count {
					if (repeatArr[i] == true) {
						fireOnce = i
						fireSearched = true
						break
					} //end if
				} //end for
			} //end if [weekday is 7 or not]
			//없을경우 다음주로 넘어간것으로 치고 한번더 루프
			if (!fireSearched) {
				for i:Int in 0  ..< repeatArr.count {
					if (repeatArr[i] == true) {
						fireOnce = i
						fireSearched = true
						break
					} //end if
				} //end for
			} //end if
		} //end if
		
		//fireOnce가 위 과정을 거친 다음에도 -1이 아니면, 그 다음 반복을 검사
		if (fireOnce != -1) {
			for i:Int in (fireOnce == 6 ? 0 : (fireOnce + 1))  ..< repeatArr.count {
				if (repeatArr[i] == true) {
					fireNextDay = i
					fireNextdaySearched = true
					break
				} //end if
			} //end for
			if (!fireNextdaySearched) { //다음 반복일이 없으면 다음주로 넘어간것으로 치고 한번더 루프
				for i:Int in 0 ..< repeatArr.count {
					if (repeatArr[i] == true) {
						fireNextDay = i
						fireNextdaySearched = true
						break
					} //end if
				} //end for
			} //end if
		} //end if
		
		print("[AlarmManager] Today's weekday is ", todayDate.weekday!)
		print("[AlarmManager] Next alarm date is ",fireOnce," (-1: no repeat, 0=sunday)")
		print("[AlarmManager] If this is repeat, repeat vars over 2? =>", fireNextdaySearched)
		print("[AlarmManager] Then when?", fireNextDay, " (-1: no nextday, 0=sunday)")
		
		var fireAfterDay:Int = 0
		if (fireOnce == -1 || (fireSearched && fireOnce == todayDate.weekday! - 1 )) {
			//Firedate modifiy not needed but check time
			//시간이 과거면 알람 추가 안해야함 + 다음날로 넘겨야됨
			if (date.timeIntervalSince1970 <= (Date().timeIntervalSince1970)) {
				//과거의 알람이기 때문에, 다음날로 넘겨야됨!
				
				// <<< >>> 이 부분 수정해야함. 무조건 다음날로 넘기는게 아니라 다음 반복일까지 넘겨야함 (반복이 있을 경우)
				if (fireOnce == -1) { //반복 꺼짐인 경우 그냥 다음날로 넘김.
					print("[AlarmManager] Past alarm!! add 1 day")
					date = UPUtils.addDays(date, additionalDays: 1)
				} else {
					//다음 반복일까지 대기후 추가
					let fireDtIfRepeatValid:Int = fireNextdaySearched == true ? fireNextDay : fireOnce
					
					if (fireDtIfRepeatValid - (todayDate.weekday! - 1) > 0) {
						fireAfterDay = fireDtIfRepeatValid - (todayDate.weekday! - 1)
						print("[AlarmManager] (past) Firedate is over today: ", fireAfterDay)
					} else {
						fireAfterDay = (7 - (todayDate.weekday! - 1)) + fireDtIfRepeatValid
						print("[AlarmManager] (past) Firedate is before today: ", fireAfterDay)
					}
					date = UPUtils.addDays(date, additionalDays: fireAfterDay)
					print("[AlarmManager] Firedate", date)
				} //end if [repeat is on or off]
			} else {
				print("[AlarmManager] This is not past alarm.")
			} //end if
		} else {
			//Firedate modify.
			if (fireOnce - (todayDate.weekday! - 1) > 0) {
				fireAfterDay = fireOnce - (todayDate.weekday! - 1)
				print("[AlarmManager] Firedate is over today: ", fireAfterDay)
			} else {
				fireAfterDay = (7 - (todayDate.weekday! - 1)) + fireOnce
				print("[AlarmManager] Firedate is before today: ", fireAfterDay)
			}
			//Add to date
			date = UPUtils.addDays(date, additionalDays: fireAfterDay)
			print("[AlarmManager] Firedate", date)
		} //end if
		
		let alarmUUID:Int = alarmID == -1 ? Int(Date().timeIntervalSince1970) : alarmID
		
		/////// 커스텀 알람 음을 사용하는 경우, LocalNotifi에 추가하는 알람음은
		//기본 0번째 알람음으로 설정함.
		let soundNameStr:String = soundFile.soundURL == nil ? soundFile.soundFileName : SoundManager.list[0].soundFileName
		
		//초단위 제거
		var tmpNSComp:DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
		tmpNSComp.second = 0
		date = Calendar.current.date(from: tmpNSComp)!
		
		if (isToggled == true) {
			AlarmManager.addLocalNotification(alarmTitle, aFireDate: date, gameID: gameID, soundFile: soundNameStr, repeatInfo: repeatArr, alarmID: alarmUUID, notifiUUID: nUUID)
		}
	
		//30초
		tmpNSComp.second = 30
		date = Calendar.current.date(from: tmpNSComp)!
		
		if (isToggled == true) {
			AlarmManager.addLocalNotification(alarmTitle, aFireDate: date, gameID: gameID, soundFile: soundNameStr, repeatInfo: repeatArr, alarmID: alarmUUID, notifiUUID: nUUID)
		} //end if
		
		//Add alarm to system (array) and save to nsdef
		let tmpAlarmEle:AlarmElements = AlarmElements()
		
		//reset
		tmpNSComp.second = 0
		date = Calendar.current.date(from: tmpNSComp)!
		
		tmpAlarmEle.initObject(alarmTitle, memo: alarmMemo, game: gameID, repeats: repeatArr,
		                       soundSize: alarmLevel, sound: soundFile.soundFileName, alarmDate: date, alarmTool: isToggled, id: alarmUUID, uuid: nUUID)
		if (soundFile.soundURL != nil ) {
			//Custom sound일 경우
			tmpAlarmEle.alarmSound = ""
			tmpAlarmEle.alarmSoundURLString = soundFile.soundURL!.relativePath
		} else {
			tmpAlarmEle.alarmSoundURLString = ""
		} //end if
		
		if (insertAt == -1) {
			//add to arr and save
			alarmsArray += [tmpAlarmEle]
		} else {
			alarmsArray.insert(tmpAlarmEle, at: insertAt)
		}
		
		DataManager.nsDefaults.set(NSKeyedArchiver.archivedData(withRootObject: alarmsArray), forKey: "alarmsList")
		DataManager.save()
		
		//refresh another view
		if (redrawList && AlarmListView.selfView != nil) {
			AlarmListView.selfView!.createTableList()
		} //end if
	} //end func
	
	//내부함수
	static func addLocalNotification(_ aBody:String, aFireDate:Date, gameID:Int, soundFile:String, repeatInfo:Array<Bool>, alarmID:Int, notifiUUID:String = "") {
		
		//Add to system
		if #available(iOS 10.0, *) {
			//iOS 10
			//임시로 9때까지 쓰던걸 쓰자
			/*
			let notifiContent:UNMutableNotificationContent = UNMutableNotificationContent();
			notifiContent.title = aBody;
			//notifiContent.body = "aa";
			notifiContent.sound = UNNotificationSound(named: soundFile);
			notifiContent.userInfo = [
				"id": alarmID,
				"soundFile": soundFile,
				"gameCategory": gameID,
				"repeat": repeatInfo
			];
			let dateComp:DateComponents = Calendar.current.dateComponents([.calendar, .year, .month, .day, .hour, .minute, .second], from: aFireDate);
			let notifiTrigger = UNCalendarNotificationTrigger.init(dateMatching: dateComp, repeats: false);
			let notifiRequest:UNNotificationRequest = UNNotificationRequest.init(identifier: notifiUUID, content: notifiContent, trigger: notifiTrigger);
			UNUserNotificationCenter.current().add(notifiRequest);
			*/
			
			let notification = UILocalNotification()
			notification.alertBody = aBody
			notification.alertAction = LanguagesManager.$("alarmSlideToStartGameSuffix")
			notification.fireDate = aFireDate
			notification.soundName = soundFile
			notification.userInfo = [
				"id": alarmID,"soundFile": soundFile,"gameCategory": gameID,"repeat": repeatInfo
			]
			notification.repeatInterval = .minute //30초 간격 (1분 ~ 30초)
			UIApplication.shared.scheduleLocalNotification(notification)
		} else {
			//iOS 8-9 callback
			let notification = UILocalNotification()
			notification.alertBody = aBody
			notification.alertAction = LanguagesManager.$("alarmSlideToStartGameSuffix") //'밀어서' 고정 아시발.
			notification.fireDate = aFireDate
			notification.soundName = soundFile
			notification.userInfo = [
				"id": alarmID,
				"soundFile": soundFile,
				"gameCategory": gameID,
				"repeat": repeatInfo
			]
			notification.repeatInterval = .minute //30초 간격 (1분 ~ 30초)
			UIApplication.shared.scheduleLocalNotification(notification)
		}
		
		
	} //end func
	
	static func refreshLocalNotifications( _ forceAdd:Bool = false ) -> Void {
		//현재 알람이 울리고 있을 때 사용함.
		//현재 알람 (쓰레드)에서 울리는 소리와, 노티피에서 울리는 소리가
		//겹치는 것을 방지하고 동시에 커스텀 사운드 및 긴 사운드를 사용할수 있도록
		//알람이 울릴때마다 호출하여 노티피를 캔슬했다가 다시 추가해줌
		//(울리고 있는 알람만 해당함)
		
		let currentDate:Date = Date()
		let currentDateComp:DateComponents = Calendar.current.dateComponents([.second], from: currentDate)
		
		//This function will work after mergealarm called
		
		if #available(iOS 10.0, *) {
			let cSecond:Int = currentDateComp.second!
			let unUserNotifyCenter = UNUserNotificationCenter.current()
			var unNotifications:Array<UNNotificationRequest>?
			
			unUserNotifyCenter.getPendingNotificationRequests(completionHandler: { requests in
				unNotifications = requests
				
				//노티피 항목에 있는지를 검사하는 변수 .알람ID~객체 딕셔너리
				var notifiVaildList:[Int:[UNNotificationRequest]] = [:]
				let ringingAlarms:Array<AlarmElements> = getRingingAlarms()
				
				for i:Int in 0 ..< (unNotifications!.count) {
					let targetAlarmID:Int = unNotifications![i].content.userInfo["id"] as! Int
					
					let targetAlarm:AlarmElements? = getAlarm(targetAlarmID)
					if (targetAlarm == nil) {
						continue
					} //end if
					if (targetAlarm!.alarmToggle == false || targetAlarm!.alarmCleared == true ||
						targetAlarm!.alarmFireDate.timeIntervalSince1970 > currentDate.timeIntervalSince1970) {
						continue
					} //end if
					
					///노티피 항목에 있으므로 배열에 표시.
					if (notifiVaildList[ targetAlarm!.alarmID ] == nil) {
						//print("Creating new array of alarm id:", targetAlarm!.alarmID)
						notifiVaildList[ targetAlarm!.alarmID ] = []
					}
					
					//print("Adding new notification:", unNotifications![i].identifier)
					notifiVaildList[ targetAlarm!.alarmID ]!.append(unNotifications![i])
				} //end for
				
				// iOS 10에서는 알람이 울리기 직전 그냥 노티피를 삭제하는 방법밖에는 없음.
				if (((cSecond > 28 && cSecond <= 30) || (cSecond > 58 || cSecond == 0)) && forceAdd == false) {
					//Delete notification if exists
					for i:Int in 0 ..< ringingAlarms.count {
						if (notifiVaildList[ ringingAlarms[i].alarmID ] == nil) {
							continue
						} //end if
						//REMOVE notification (temporaliy)
						
						for j:Int in 0 ..< notifiVaildList[ ringingAlarms[i].alarmID ]!.count {
							let tID = notifiVaildList[ ringingAlarms[i].alarmID ]![j].identifier
							
							unUserNotifyCenter.removePendingNotificationRequests(withIdentifiers: [tID])
							unUserNotifyCenter.removeDeliveredNotifications(withIdentifiers: [tID])
							
							//print("Removed pending notifications:", tID)
						} //end for
						
					} //end for
				} else {
					//Add notification if not exists
					for i:Int in 0 ..< ringingAlarms.count {
						if (notifiVaildList[ ringingAlarms[i].alarmID ] != nil) {
							continue
						} //end if
						
						let nTitle:String = ringingAlarms[i].alarmName
						var nDate:Date = ringingAlarms[i].alarmFireDate
						
						//removed. and add notification again
						var tComp:DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nDate)
						
						tComp.second = 0
						nDate = Calendar.current.date(from: tComp)!
						
						//print("Adding pending notification")
						addLocalNotification(
							nTitle,
							aFireDate: nDate,
							gameID: ringingAlarms[i].gameSelected,
							soundFile: ringingAlarms[i].alarmSound,
							repeatInfo: ringingAlarms[i].alarmRepeat,
							alarmID: ringingAlarms[i].alarmID)
						////////////// Add 30sec
						
						tComp.second = 30
						nDate = Calendar.current.date(from: tComp)!
						
						addLocalNotification(
							nTitle,
							aFireDate: nDate,
							gameID: ringingAlarms[i].gameSelected,
							soundFile: ringingAlarms[i].alarmSound,
							repeatInfo: ringingAlarms[i].alarmRepeat,
							alarmID: ringingAlarms[i].alarmID)
						
					} //end for
				} //end if
				
			}) //end handler
			
			
			//////////////////
		} else {
			//iOS 8, 9
			
			var currLNotifi:Array<UILocalNotification> = UIApplication.shared.scheduledLocalNotifications!
			for i:Int in 0 ..< currLNotifi.count {
				let targetAlarmID:Int = currLNotifi[i].userInfo!["id"] as! Int
				let targetAlarm:AlarmElements? = getAlarm(targetAlarmID)
				if (targetAlarm == nil) {
					continue
				} //endif
				if (targetAlarm!.alarmToggle == false || targetAlarm!.alarmCleared == true ||
					targetAlarm!.alarmFireDate.timeIntervalSince1970 > currentDate.timeIntervalSince1970) {
					continue
				} //endif
				
				UIApplication.shared.cancelLocalNotification(currLNotifi[i])
				//removed. and add notification again
				addLocalNotification(
					currLNotifi[i].alertBody!,
					aFireDate: currLNotifi[i].fireDate!,
					gameID: currLNotifi[i].userInfo!["gameCategory"] as! Int,
					soundFile: currLNotifi[i].userInfo!["soundFile"] as! String,
					repeatInfo: currLNotifi[i].userInfo!["repeat"] as! Array<Bool>,
					alarmID: targetAlarmID)
			} //for end
			
		} //end if
		
		print("[AlarmManager] Recreated active notifications")
	} //end func
	
	
	////// 반복 배열에 따른 라벨 획득
	static func fetchRepeatLabel( _ repeatInfo:Array<Bool>, loadType:Int ) -> String {
		//loadtype: 리스트용이냐, Add용이냐.
		//0 - 추가용, 1 - 리스트용
		
		var repeatCount:Int = 0
		var repeatDayNum:Int = -1
		
		for i:Int in 0 ..< repeatInfo.count {
			if (repeatInfo[i] == true) {
				repeatCount += 1
				repeatDayNum = i
			} //end if
		} //end for
		
		//영어도 짧게해야하게 생겨서 걍 전체 짧은거 사용
		let shortPara:String = "Short"
		
		if (repeatCount == 7) { //everyday
			return LanguagesManager.$("alarmRepeatFreqEveryday" + shortPara)
		} else if (repeatInfo[0] == false && repeatInfo[1] == true && repeatInfo[2] == true &&
			repeatInfo[3] == true && repeatInfo[4] == true && repeatInfo[5] == true && repeatInfo[6] == false) { //weekday
			return LanguagesManager.$("alarmRepeatFreqWeekday" + shortPara)
		} else if (repeatInfo[0] == true && repeatInfo[1] == false && repeatInfo[2] == false && repeatInfo[3] == false &&
			repeatInfo[4] == false && repeatInfo[5] == false && repeatInfo[6] == true) { //weekend
			return LanguagesManager.$("alarmRepeatFreqWeekend" + shortPara)
		} else if (repeatInfo[0] == false && repeatInfo[1] == false && repeatInfo[2] == false && repeatInfo[3] == false &&
			repeatInfo[4] == false && repeatInfo[5] == false && repeatInfo[6] == false) {
			return loadType == 0 ? LanguagesManager.$("alarmRepeatFreqOnce") : "" //no repeats
		} else if (repeatCount == 1) { //하루만 있는 경우는, 해당 하루의 요일을 표시함
			print("rep:", repeatDayNum)
			switch(repeatDayNum) {
				case 0: return LanguagesManager.$("alarmRepeatSun" + shortPara)
				case 1: return LanguagesManager.$("alarmRepeatMon" + shortPara)
				case 2: return LanguagesManager.$("alarmRepeatTue" + shortPara)
				case 3: return LanguagesManager.$("alarmRepeatWed" + shortPara)
				case 4: return LanguagesManager.$("alarmRepeatThu" + shortPara)
				case 5: return LanguagesManager.$("alarmRepeatFri" + shortPara)
				case 6: return LanguagesManager.$("alarmRepeatSat" + shortPara)
					
				default: break
			} //end switch
		} //end if
		
		return loadType == 0 ? LanguagesManager.$("alarmRepeatFreqOn") : LanguagesManager.$("timeRepeatOn") //unselected
	} //end func
	
}
