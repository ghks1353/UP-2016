//
//  AlarmRingView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 25..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;
import CoreMotion;

class AlarmRingView:UIViewController {
	
	//알람이 울렸을 때, 진입되는 뷰컨트롤러.
	/*
		각 게임에 대한 View를 따로 두기로 함
			- 이 뷰는 각 게임의 시작 부분에 대한 루트 뷰
	*/
	
	static var selfView:AlarmRingView?
	
	internal var userAsleepCount:Int = 0 //중간에 존 횟수를 여기다 추가하도록 함
	
	//게임 서브 뷰는 예외적으로 이 뷰에 포함.
	static var jumpUPStartupViewController:GameTitleViewJumpUP?
	internal var currentAlarmElement:AlarmElements?
	var gameSelectedNumber:Int = 0
	
	//Asleep func
	var lastActivatedTimeAfter:Int = 0
	var asleepTimer:Timer?
	
	//가속도센서를 이용해서 누워있는 경우 플레이할 수 없게
	var cMotionManager:CMMotionManager?
	var accelSensorWorks:Bool = false
	var isLied:Bool = false
	var liePhoneDownCount:Int = 0 //자이로 움직임을 판단해서 터치를 해도 누워있다고 판단하는 카운트
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.black
		AlarmRingView.selfView = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		userAsleepCount = 0
		if (asleepTimer != nil) {
			asleepTimer!.invalidate()
			asleepTimer = nil
		}
		if (cMotionManager != nil) {
			cMotionManager!.stopAccelerometerUpdates()
			cMotionManager!.stopGyroUpdates()
			cMotionManager = nil
		}
		
		//알림이 울린지 얼마나 지났나 시간을 체크한 후
		//1시간이 지났으면 로드 과정을 잠시 멈추고 즉시 해제할 건지 물어봄.
		let nextfieInSeconds:Int = AlarmManager.getNextAlarmFireInSeconds()
		let nextAlarmLeft:Int = nextfieInSeconds == -1 ? -1 : (nextfieInSeconds - Int(Date().timeIntervalSince1970))
		if (abs(nextAlarmLeft) > AlarmManager.alarmForceStopAvaliableSeconds) {
			//알람이 울린 후 특정 시간이 지나 오래된 경우
			
			//즉시 해제할거냐?
			let unlockForceConfirmAlert:UIAlertController =
				UIAlertController(title: LanguagesManager.$("alarmOldWarningTitle"), message: LanguagesManager.$("alarmOldWarningDescription"), preferredStyle: UIAlertControllerStyle.alert)
			unlockForceConfirmAlert.addAction(UIAlertAction(title: LanguagesManager.$("alarmOldOffNow"), style: .default, handler: { (action: UIAlertAction!) in
				//Unlock now
				self.unlockAlarmForce()
			}))
			unlockForceConfirmAlert.addAction(UIAlertAction(title: LanguagesManager.$("generalCancel"), style: .cancel, handler: { (action: UIAlertAction!) in
				//Play game
				self.alarmViewLoadProcced()
			}))
			present(unlockForceConfirmAlert, animated: true, completion: nil)
			
		} else {
			alarmViewLoadProcced()
		}
		
		
		
	} //end func
	
	//////////// alarmRingView init
	//load games
	func alarmViewLoadProcced() {
		currentAlarmElement = AlarmManager.getRingingAlarm()
		
		if (currentAlarmElement != nil) {
			//게임을 분류하여 각각 맞는 view를 present
			if (currentAlarmElement?.gameSelected == -1) {
				gameSelectedNumber = Int(arc4random_uniform( UInt32(GameManager.list.count) ))
			} //rdm sel end
			
			//알람 사운드 울림중일때 끔
			AlarmManager.stopSoundAlarm()
			//가속도 센서를 이용한 잠듦 경고 등
			accelSensorWorks = DataManager.nsDefaults.bool(forKey: DataManager.EXPERIMENTS_USE_NOLIEDOWN_KEY)
			if (accelSensorWorks) {
				cMotionManager = CMMotionManager()
				cMotionManager!.startAccelerometerUpdates()
				cMotionManager!.startGyroUpdates()
			}
			
			print("selected ->", gameSelectedNumber)
			switch( gameSelectedNumber ) {
			case 0: //점프업
				changeRotation(0);
				
				AlarmRingView.jumpUPStartupViewController = nil
				AlarmRingView.jumpUPStartupViewController = GameTitleViewJumpUP() //게임 강제 초기화. (TitleView)
				
				present(AlarmRingView.jumpUPStartupViewController!, animated: false, completion: nil)
				break;
				
			default:
				print("game code", self.gameSelectedNumber, "not found err")
				break;
			} //end switch
			
			//게임 중간에 조는 것 + 가속도센서 체크 관련한 핸들링
			asleepTimer = UPUtils.setInterval(0.5, block: asleepTimeCheckFunc)
		} //end element chk
		
	} //end func
	
	
	func disposeView() {
		//view disappear event handler
		if (asleepTimer != nil) {
			asleepTimer!.invalidate();
			asleepTimer = nil;
		}
		if (cMotionManager != nil) {
			cMotionManager!.stopAccelerometerUpdates();
			cMotionManager!.stopGyroUpdates();
			cMotionManager = nil;
		}
		
		//Refresh tables
		AlarmListView.selfView!.createTableList();
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//Rotation set
	func changeRotation(_ rotationNum:Int) {
		
		//세로로 화면 돌림
		
		//Rotate this view to portrait
		let portraitOriention = UIInterfaceOrientation.portrait.rawValue;
		let landscapeOriention = UIInterfaceOrientation.landscapeRight.rawValue;
		
		if (rotationNum == 0) { // 0 - 세로, 1 - 가로
			UIDevice.current.setValue(portraitOriention, forKey: "orientation");
		} else {
			UIDevice.current.setValue(landscapeOriention, forKey: "orientation");
		}
		
		//PS: this is unsecure use of APIs
		// http://stackoverflow.com/questions/26357162/how-to-force-view-controller-orientation-in-ios-8
	}
	
	
	// Lock rotation and fix
	override var shouldAutorotate : Bool {
		return false; //Lock autorotate in this view
	}
	
	//Check last touch
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		print("In alarm, Touched!");
		
		if (lastActivatedTimeAfter > 120) {
			//한번 졸았다고 체크함
			userAsleepCount += 1
		}
		if (isLied == false && liePhoneDownCount <= 14) {
			AlarmManager.stopSoundAlarm() //터치시에만 꺼지게..
			SoundManager.pauseResumeBGMSound( true )
		}
		
		lastActivatedTimeAfter = 0
	}
	
	//Check if asleep or not + acc check
	func asleepTimeCheckFunc() {
		//print("Asleep check process is running");
		if (currentAlarmElement == nil) {
			//remove it
			if (asleepTimer != nil) {
				asleepTimer!.invalidate()
				asleepTimer = nil
			}
			return
		}
		/////////////////////////////////////
		lastActivatedTimeAfter += 1
		if (lastActivatedTimeAfter > 120 || liePhoneDownCount > 14) {
			SoundManager.pauseResumeBGMSound( false )
			AlarmManager.ringSoundAlarm(currentAlarmElement, useVibrate: true)
		} //end if
		/////////////////////// Accel check
		if (accelSensorWorks) {
			if (cMotionManager!.accelerometerData!.acceleration.z >= 0.5
				|| abs(cMotionManager!.accelerometerData!.acceleration.x) >= 0.85) {
				print ("LIE");
				isLied = true;
				
				//ring alarm when lie user
				SoundManager.pauseResumeBGMSound( false )
				AlarmManager.ringSoundAlarm(currentAlarmElement, useVibrate: true);
			} else {
				isLied = false;
			} //end if [Liyng or not]
			if (UIDevice.current.userInterfaceIdiom == .pad) {
				//Gyro ignore on Pad series
				liePhoneDownCount = 0
			} else {
				//Gyro check works only Phone/Pod
				if (abs(cMotionManager!.gyroData!.rotationRate.x) + abs(cMotionManager!.gyroData!.rotationRate.y) + abs(cMotionManager!.gyroData!.rotationRate.z) < 0.05) {
					print("Not moving");
					liePhoneDownCount += 1
				} else {
					liePhoneDownCount = 0
				} //end if [Gyro movement]
			} //end if [UIDevice iPad]
		} //end if [accelSensorWorks]
	} //end func
	
	/// force unlock alarm
	func unlockAlarmForce() {
		//Stops bgm if needed
		SoundManager.stopBGMSound()
		
		//Force-clear alarm
		AlarmManager.gameClearToggle( Date(), cleared: true )
		
		AlarmManager.mergeAlarm() //Merge it
		AlarmManager.alarmRingActivated = false
		
		dismiss(animated: false, completion: nil)
		GlobalSubView.alarmRingViewcontroller.dismiss(animated: true, completion: nil)
	} //end func
	
	
	
}
