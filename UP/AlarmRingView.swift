//
//  AlarmRingView.swift
//  UP
//
//  Created by ExFl on 2016. 2. 25..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
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
	
	//게임 서브 뷰는 예외적으로 이 뷰에 포함.
	static var jumpUPStartupViewController:GameTitleViewJumpUP?;
	
	
	internal var currentAlarmElement:AlarmElements?;
	var gameSelectedNumber:Int = 0;
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.blackColor();
		AlarmRingView.selfView = self;
		
	}
	
	override func viewDidAppear(animated: Bool) {
		if (currentAlarmElement != nil) {
			
			//알람 사운드 울림중일때 끔
			AlarmManager.stopSoundAlarm();
			
			//세로로 화면 돌림
			
			//Rotate this view to portrait
			let value = UIInterfaceOrientation.Portrait.rawValue;
			UIDevice.currentDevice().setValue(value, forKey: "orientation");
			//PS: this is unsecure use of APIs
			// http://stackoverflow.com/questions/26357162/how-to-force-view-controller-orientation-in-ios-8
			
			//게임을 분류하여 각각 맞는 view를 present
			if (currentAlarmElement?.gameSelected == -1) {
				gameSelectedNumber = Int(arc4random_uniform( UInt32(UPAlarmGameLists.list.count) ));
			} //rdm sel end
			
			print("view appreared and preparing to present a new view controller");
			UPUtils.setTimeout(0.5, block: {
				print("selected ->", self.gameSelectedNumber);
				switch( self.gameSelectedNumber ) {
					case 0: //점프업
						if (AlarmRingView.jumpUPStartupViewController == nil) {
							AlarmRingView.jumpUPStartupViewController = GameTitleViewJumpUP();
						} else {
							AlarmRingView.jumpUPStartupViewController = nil;
							AlarmRingView.jumpUPStartupViewController = GameTitleViewJumpUP(); //게임 초기화가 귀찮다 ㅗ
						}
						self.presentViewController(AlarmRingView.jumpUPStartupViewController!, animated: false, completion: nil);
						break;
						
					default:
						print("game code", self.gameSelectedNumber, "not found err");
						break;
				}
			});
			
			
			
		}
		
	}
	
	override func viewWillAppear(animated: Bool) {
		//뷰가 열릴 직전에.
		
		currentAlarmElement = AlarmManager.getRingingAlarm();
		if (currentAlarmElement == nil) {
			print("alarm element is nil");
		} else {
			
			
		} //end if
		
		
		
		
	} //end func
	
	override func viewWillDisappear(animated: Bool) {
		//view disappear event handler
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// Lock rotation and fix
	override func shouldAutorotate() -> Bool {
		return false; //Lock autorotate in this view
	}
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		//Lock it to Portrait
		return .Portrait;
	}
	
	
	
}