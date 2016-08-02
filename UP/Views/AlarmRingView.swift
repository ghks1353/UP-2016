//
//  AlarmRingView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 25..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit;

class AlarmRingView:UIViewController {
	
	//알람이 울렸을 때, 진입되는 뷰컨트롤러.
	/*
		각 게임에 대한 View를 따로 두기로 함
			- 이 뷰는 각 게임의 시작 부분에 대한 루트 뷰
	*/
	
	static var selfView:AlarmRingView?;
	
	internal var userAsleepCount:Int = 0; //중간에 존 횟수를 여기다 추가하도록 함
	
	//게임 서브 뷰는 예외적으로 이 뷰에 포함.
	static var jumpUPStartupViewController:GameTitleViewJumpUP?;
	internal var currentAlarmElement:AlarmElements?;
	var gameSelectedNumber:Int = 0;
	
	var lastActivatedTimeAfter:Int = 0;
	var asleepTimer:NSTimer?;
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.blackColor();
		AlarmRingView.selfView = self;
		
	}
	
	override func viewDidAppear(animated: Bool) {
		currentAlarmElement = AlarmManager.getRingingAlarm();
		userAsleepCount = 0;
		if (asleepTimer != nil) {
			asleepTimer!.invalidate();
			asleepTimer = nil;
		}
		
		if (currentAlarmElement != nil) {
			//게임을 분류하여 각각 맞는 view를 present
			if (currentAlarmElement?.gameSelected == -1) {
				gameSelectedNumber = Int(arc4random_uniform( UInt32(GameManager.list.count) ));
			} //rdm sel end
			
			//알람 사운드 울림중일때 끔
			AlarmManager.stopSoundAlarm();
			
			print("selected ->", gameSelectedNumber);
			switch( gameSelectedNumber ) {
				case 0: //점프업
					changeRotation(0);
					
					AlarmRingView.jumpUPStartupViewController = nil;
					AlarmRingView.jumpUPStartupViewController = GameTitleViewJumpUP(); //게임 강제 초기화. (TitleView)
					
					presentViewController(AlarmRingView.jumpUPStartupViewController!, animated: false, completion: nil);
					break;
					
				default:
					print("game code", self.gameSelectedNumber, "not found err");
					break;
			} //end switch
			
			//게임 중간에 조는 것 관련한 핸들링
			asleepTimer = UPUtils.setInterval(1, block: asleepTimeCheckFunc);
			
		} //end element chk
		
	} //end func
	
	
	override func viewWillDisappear(animated: Bool) {
		//view disappear event handler
		if (asleepTimer != nil) {
			asleepTimer!.invalidate();
			asleepTimer = nil;
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//Rotation set
	func changeRotation(rotationNum:Int) {
		
		//세로로 화면 돌림
		
		//Rotate this view to portrait
		let portraitOriention = UIInterfaceOrientation.Portrait.rawValue;
		let landscapeOriention = UIInterfaceOrientation.LandscapeRight.rawValue;
		
		if (rotationNum == 0) { // 0 - 세로, 1 - 가로
			UIDevice.currentDevice().setValue(portraitOriention, forKey: "orientation");
		} else {
			UIDevice.currentDevice().setValue(landscapeOriention, forKey: "orientation");
		}
		
		//PS: this is unsecure use of APIs
		// http://stackoverflow.com/questions/26357162/how-to-force-view-controller-orientation-in-ios-8
	}
	
	
	// Lock rotation and fix
	override func shouldAutorotate() -> Bool {
		return false; //Lock autorotate in this view
	}
	
	//Check last touch
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		print("In alarm, Touched!");
		
		if (lastActivatedTimeAfter > 60) {
			//한번 졸았다고 체크함
			userAsleepCount += 1;
		}
		
		AlarmManager.stopSoundAlarm(); //터치시에만 꺼지게..
		lastActivatedTimeAfter = 0;
	}
	
	//Check if asleep or not
	func asleepTimeCheckFunc() {
		if (currentAlarmElement == nil) {
			//remove it
			if (asleepTimer != nil) {
				asleepTimer!.invalidate();
				asleepTimer = nil;
			}
			return;
		}
		lastActivatedTimeAfter += 1;
		if (lastActivatedTimeAfter > 60) {
			AlarmManager.ringSoundAlarm(currentAlarmElement);
		}
	}
	
	
	
}