//
//  GameModeView.swift
//  UP
//
//  Created by ExFl on 2016. 6. 23..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class GameModeView:UIViewController {
	
	static var selfView:GameModeView?;
	
	//게임 서브 뷰
	static var jumpUPStartupViewController:GameTitleViewJumpUP?;
	
	var gameSelectedNumber:Int = 0;
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.blackColor();
		GameModeView.selfView = self;
		
	}
	
	override func viewDidAppear(animated: Bool) {
		
		//게임선택을 바깥쪽에서 하고 들어오게해야함
		//gameSelectedNumber 활용
		
		
		
		/*
		AlarmRingView.jumpUPStartupViewController = nil;
		AlarmRingView.jumpUPStartupViewController = GameTitleViewJumpUP(); //게임 강제 초기화. (TitleView)
		
		presentViewController(AlarmRingView.jumpUPStartupViewController!, animated: false, completion: nil);
		*/
		
	} //end func
	
	
	override func viewWillDisappear(animated: Bool) {
		//view disappear event handler
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//Rotation set
	func changeRotation(rotationNum:Int) {
		//세로로 화면 돌림
		let portraitOriention = UIInterfaceOrientation.Portrait.rawValue;
		let landscapeOriention = UIInterfaceOrientation.LandscapeRight.rawValue;
		
		if (rotationNum == 0) { // 0 - 세로, 1 - 가로
			UIDevice.currentDevice().setValue(portraitOriention, forKey: "orientation");
		} else {
			UIDevice.currentDevice().setValue(landscapeOriention, forKey: "orientation");
		}
	}
	
	
	// Lock rotation and fix
	override func shouldAutorotate() -> Bool {
		return false; //Lock autorotate in this view
	}
	
}