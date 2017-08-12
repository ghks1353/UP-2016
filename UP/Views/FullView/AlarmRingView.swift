//
//  AlarmRingView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 25..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import pop

class AlarmRingView:UPUIViewController {
	
	//알람이 울렸을 때, 진입되는 뷰컨트롤러.
	/*
		각 게임에 대한 View를 따로 두기로 함
			- 이 뷰는 각 게임의 시작 부분에 대한 루트 뷰
	*/
	
	static var selfView:AlarmRingView?
	
	//게임 서브 뷰들
	static var jumpUPStartupViewController:GameTitleViewJumpUP?
	
	//알람 Element
	var currentAlarmElement:AlarmElements?
	var gameSelectedNumber:Int = 0
	
	//Asleep func
	var userAsleepCount:Int = 0 //중간에 존 횟수를 여기다 추가하도록 함
	var liePhoneDownCount:Int = 0 //자이로 움직임을 판단해서 터치를 해도 누워있다고 판단하는 카운트
	
	var lastActivatedTimeAfter:Int = 0
	var asleepTimer:Timer?
	
	//가속도센서를 이용해서 누워있는 경우 플레이할 수 없게
	var cMotionManager:CMMotionManager?
	var accelSensorWorks:Bool = false
	var isLied:Bool = false
	
	/// 광고보기 전용에서 따로 체크하는 값
	var isLiedSysCheck:Bool = false
	
	//광고를 보고있거나 기타 등의 이유로 일부 기능을 작동하지 않게 해야할 경우
	//예 : 광고 보는중 타이머 지나서 울림, 혹은 누워서 제한
	var ignoresActiveSound:Bool = false
	// 위와 같으나 광고로 알람 해제 기능에만 적용되며 센서는 사용.
	var ignoresActiveSoundWithADOff:Bool = false
	
	/// 광고로 알람 해제 기능 enabled status
	private var adModeEnabled:Bool = false
	
	var adModeTitleLabel:UILabel = UILabel()
	var adModeDescriptionLabel:UILabel = UILabel()
	
	var adModeAutoStartVal:Int = 0
	var adRunning:Bool = false
	var adWarningCount:Int = 0
	
	var adFinished:Bool = false
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.black
		AlarmRingView.selfView = self
		
		adModeTitleLabel.text = LanguagesManager.$("alarmForceOffNowLabel")
		adModeTitleLabel.numberOfLines = 0
		
		adModeTitleLabel.font = UIFont.systemFont(ofSize: 15)
		adModeTitleLabel.textColor = UIColor.white
		adModeTitleLabel.textAlignment = .center
		
		// Description
		adModeDescriptionLabel.text = ""
		adModeDescriptionLabel.numberOfLines = 0
		
		adModeDescriptionLabel.font = UIFont.systemFont(ofSize: 13)
		adModeDescriptionLabel.textColor = UIColor.white
		adModeDescriptionLabel.textAlignment = .center
		
		self.view.addSubview(adModeTitleLabel)
		self.view.addSubview(adModeDescriptionLabel)
		
		// Default
		adModeTitleLabel.isHidden = true
		adModeDescriptionLabel.isHidden = true
		
	} // end func
	
	override func viewWillAppear(_ animated: Bool) {
		// Fit frames
		fitFrames()
	} // end func
	
	override func viewDidAppear(_ animated: Bool) {
		if (adModeEnabled && !adFinished) {
			print("AD Mode enabled. enabling elements")
			
			adModePhase()
			return
		} // end if
		
		userAsleepCount = 0
		removeAllSensor()
		
		//알림이 울린지 얼마나 지났나 시간을 체크한 후
		//1시간이 지났으면 로드 과정을 잠시 멈추고 즉시 해제할 건지 물어봄.
		let nextfieInSeconds:Int = AlarmManager.getNextAlarmFireInSeconds()
		let nextAlarmLeft:Int = nextfieInSeconds == -1 ? -1 : (nextfieInSeconds - Int(Date().timeIntervalSince1970))
		if (nextfieInSeconds != -1 && nextAlarmLeft < AlarmManager.alarmForceStopAvaliableSeconds * -1) {
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
		} else { //즉시 해제 불가. 바로 게임으로
			alarmViewLoadProcced()
		} //end if [old alarm]
		
	} //end func
	
	//////////// alarmRingView init
	//load games
	func alarmViewLoadProcced() {
		currentAlarmElement = AlarmManager.getRingingAlarm()
		ignoresActiveSound = false
		adModeEnabled = false
		
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
				addSensor()
			} // end if
			
			print("selected ->", gameSelectedNumber)
			switch( gameSelectedNumber ) {
				case 0: //점프업
					changeRotation(0)
					
					AlarmRingView.jumpUPStartupViewController = nil
					AlarmRingView.jumpUPStartupViewController = GameTitleViewJumpUP() //게임 강제 초기화. (TitleView)
					
					present(AlarmRingView.jumpUPStartupViewController!, animated: false, completion: nil)
					break
				default:
					print("game code", self.gameSelectedNumber, "not found err")
					break
			} //end switch
			
			//게임 중간에 조는 것 + 가속도센서 체크 관련한 핸들링
			addTimer()
		} //end element chk
		
	} //end func
	
	
	func disposeView() {
		//view disappear event handler
		removeAllSensor()
		
		//Refresh tables if avail
		AlarmListView.selfView?.createTableList()
	} //end func
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//Rotation set
	func changeRotation(_ rotationNum:Int) {
		
		//세로로 화면 돌림
		
		//Rotate this view to portrait
		let portraitOriention = UIInterfaceOrientation.portrait.rawValue
		let landscapeOriention = UIInterfaceOrientation.landscapeRight.rawValue
		
		if (rotationNum == 0) { // 0 - 세로, 1 - 가로
			UIDevice.current.setValue(portraitOriention, forKey: "orientation")
		} else {
			UIDevice.current.setValue(landscapeOriention, forKey: "orientation")
		} // end if
		
		fitFrames()
		
		//PS: this is unsecure use of APIs
		// http://stackoverflow.com/questions/26357162/how-to-force-view-controller-orientation-in-ios-8
	} //end func
	
	
	// Lock rotation and fix
	override var shouldAutorotate : Bool {
		return false //Lock autorotate in this view
	}
	
	//Check last touch
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		print("In alarm, Touched!")
		
		touchHandler()
	} // end func
	
	func touchHandler() {
		if (lastActivatedTimeAfter > 120) {
			//한번 졸았다고 체크함
			userAsleepCount += 1
		}
		if (isLied == false && liePhoneDownCount <= 14) {
			
			if (AlarmManager.alarmSoundPlaying) {
				// 게임에서 필요한 경우 알람에서 깨어남을 알려주도록 호출
				AlarmRingView.jumpUPStartupViewController?.forceRestartGame()
			} // end if
			
			AlarmManager.stopSoundAlarm() //터치시에만 꺼지게..
			SoundManager.pauseResumeBGMSound( true )
		} // end if
		
		lastActivatedTimeAfter = 0
	} // end func
	
	//Check if asleep or not + acc check
	func asleepTimeCheckFunc() {
		if (ignoresActiveSound == true) {
			return
		} // end if
		if (currentAlarmElement == nil) {
			//remove it
			removeAllSensor()
			return
		} // End if
		
		/// non-touch check
		lastActivatedTimeAfter += 1
		if ((lastActivatedTimeAfter > 120 || liePhoneDownCount > 14) && !ignoresActiveSoundWithADOff) {
			SoundManager.pauseResumeBGMSound( false )
			AlarmManager.ringSoundAlarm(currentAlarmElement, useVibrate: true)
		} //end if
		
		// Accel check
		if (cMotionManager?.accelerometerData != nil) {
			//print ("x",cMotionManager!.accelerometerData!.acceleration.x,"y",cMotionManager!.accelerometerData!.acceleration.y,"z",cMotionManager!.accelerometerData!.acceleration.z)
			
			if (cMotionManager!.accelerometerData!.acceleration.z >= 0.5
				|| abs(cMotionManager!.accelerometerData!.acceleration.y) <= 0.2
				|| abs(cMotionManager!.accelerometerData!.acceleration.x) >= 0.85) {
				//print ("LIE")
				isLiedSysCheck = true
			} else {
				isLiedSysCheck = false
			} //end if [Liyng or not]
		} else {
			isLiedSysCheck = false
		} // end if
		
		// 광고로 알람 해제일 때
		if (isLiedSysCheck && adModeEnabled) {
			adModeAutoStartFunc( false ) // 누웠을 경우
		} else if (!isLiedSysCheck && adModeEnabled) {
			adModeAutoStartFunc( true ) // 안 누운 경우
		} // end if
		
		if (accelSensorWorks) {
			if (isLiedSysCheck) {
				isLied = true
				
				// ring alarm when lie user
				SoundManager.pauseResumeBGMSound( false )
				AlarmManager.ringSoundAlarm(currentAlarmElement, useVibrate: true)
			} else {
				isLied = false
			} // end if [Liyng or not]
			if (UIDevice.current.userInterfaceIdiom == .pad) {
				//Gyro ignore on Pad series
				liePhoneDownCount = 0
			} else {
				//Gyro check works only Phone/Pod
				if (abs(cMotionManager!.gyroData!.rotationRate.x) + abs(cMotionManager!.gyroData!.rotationRate.y) + abs(cMotionManager!.gyroData!.rotationRate.z) < 0.05) {
					print("Not moving")
					liePhoneDownCount += 1
				} else {
					liePhoneDownCount = 0
				} //end if [Gyro movement]
			} //end if [UIDevice iPad]
		} //end if [accelSensorWorks]
	} //end func
	
	/// Ad unlock mode는 다른 뷰로 넘어가지 않고 여기서 광고 처리를 하도록
	func enableAdUnlock() {
		currentAlarmElement = AlarmManager.getRingingAlarm()
		SoundManager.stopBGMSound()
		adModeEnabled = true
		adRunning = false
		adFinished = false
		
		adWarningCount = 0
		adModeAutoStartVal = 0
		
		// 나머지는 appear 이후 처리
		adModeTitleLabel.isHidden = false
		adModeDescriptionLabel.isHidden = false
		
		fitFrames()
	} // end func
	
	func adModePhase() {
		// 센서 활성화. 광고 체크 겸용
		addTimer()
		addSensor()
		
	} // end func
	
	/// Fit elements
	func fitFrames() {
		
		adModeTitleLabel.sizeToFit()
		adModeDescriptionLabel.sizeToFit()
		
		adModeTitleLabel.frame = CGRect(x: 0, y: self.view.frame.height / 2 - adModeTitleLabel.frame.height / 2, width: self.view.frame.width, height: adModeTitleLabel.frame.height)
		adModeDescriptionLabel.frame = CGRect(x: 0, y: self.view.frame.height - adModeDescriptionLabel.frame.height - 24, width: self.view.frame.width, height: adModeDescriptionLabel.frame.height)
		
	} // end func
	
	func adModeAutoStartFunc( _ stats:Bool ) {
		
		// 누운 경우
		if (!stats) {
			SoundManager.playEffectSound(SoundManager.bundleSystemSounds.systemAdBeep.rawValue)
			adModeAutoStartVal = 0
			
			if (adRunning) {
				// 광고 실행중인 경우는 warning 카운트 추가
				adWarningCount += 1
				return
			} // end if
			
			adModeDescriptionLabel.text = LanguagesManager.$("alarmForceOffNowFixLabel")
			fitFrames()
			return
		} // end if
		adModeAutoStartVal += 1
		lastActivatedTimeAfter = 0 // 논터치 타이머도 리셋.
		
		adModeDescriptionLabel.text = LanguagesManager.$("alarmForceOffNowAdLabel")
		fitFrames()
		
		if (adModeAutoStartVal >= 5 * 2 && !adRunning) { // 초 * 2
			// 광고 실행
			adRunning = true
			adModeAutoStartVal = 0
			lastActivatedTimeAfter = 0
			
			UnityAdsManager.showUnityAD(self, placementID: UnityAdsManager.PlacementAds.gameContinueAD.rawValue, callbackFunction: adsFinishedHandler, showFailCallbackFunction: internetConnectionConfirmHandler)
		} // end if
		
	} // end func
	
	/// 광고 시청 종료
	func adsFinishedHandler() {
		if (adWarningCount >= 3) {
			// 광고 시청 중 경고 카운트가 늘어난 경우
			
			adModeAutoStartVal = 0
			adWarningCount = 0
			lastActivatedTimeAfter = 0
			
			adRunning = false
			adFinished = false
			
			adModeTitleLabel.text = LanguagesManager.$("alarmForceOffNowRetryNeeded")
			adModeDescriptionLabel.text = ""
			fitFrames()
			
			return
		} // end if
		
		adFinished = true
		
		removeAllSensor()
		unlockAlarmForce()
		
		
	} // end func
	/// 광고 시청 불가능한 경우
	func internetConnectionConfirmHandler() {
		adRunning = false
		removeAllSensor()
		
		self.alert(cTitle: LanguagesManager.$("generalError"), subject: LanguagesManager.$("generalCheckInternetConnection"), confirmTitle: LanguagesManager.$("generalRetry"), cancelTitle: LanguagesManager.$("generalCancel"), confirmCallback: retryAdsHandler, cancelCallback: returnTitleHandler)
		
	} // end func
	
	func retryAdsHandler() {
		lastActivatedTimeAfter = 0
		adModeAutoStartVal = 0
		
		adModeEnabled = true
		adRunning = false
		adFinished = false
		
		adWarningCount = 0
		adModeAutoStartVal = 0
		
		addTimer()
		addSensor()
		
	} // end func
	func returnTitleHandler() {
		
		removeAllSensor()
		alarmViewLoadProcced()
		
	} // end func
	
	/// 모션 인식용 센서
	func addSensor() {
		cMotionManager = CMMotionManager()
		cMotionManager!.startAccelerometerUpdates()
		cMotionManager!.startGyroUpdates()
	} // end func
	func addTimer() {
		if (asleepTimer != nil) {
			asleepTimer!.invalidate()
			asleepTimer = nil
		} // end if
		
		asleepTimer = UPUtils.setInterval(0.5, block: asleepTimeCheckFunc)
	} // end func
	
	func removeAllSensor() {
		// removes also timer
		if (asleepTimer != nil) {
			asleepTimer!.invalidate()
			asleepTimer = nil
		} // end if
		
		cMotionManager?.stopAccelerometerUpdates()
		cMotionManager?.stopGyroUpdates()
		cMotionManager = nil
	} // end func
	
	/// force unlock alarm
	func unlockAlarmForce() {
		//Stops bgm if needed
		SoundManager.stopBGMSound()
		
		// Remove sensor listeners
		removeAllSensor()
		
		//Force-clear alarm
		AlarmManager.gameClearToggle( Date(), cleared: true )
		
		AlarmManager.mergeAlarm() //Merge it
		AlarmManager.alarmRingActivated = false
		
		dismiss(animated: false, completion: nil)
		GlobalSubView.alarmRingViewcontroller.dismiss(animated: true, completion: nil)
		
		ViewController.selfView!.alarmFinishedSetup(withGame: false)
	} //end func
	
	
	
}
