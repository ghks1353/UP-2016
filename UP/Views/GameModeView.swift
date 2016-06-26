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
	
	//선택된 게임 번호
	static var gameSelectedNumber:Int = 0;
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.blackColor();
		GameModeView.selfView = self;
	}
	
	override func viewDidAppear(animated: Bool) {
		let sel:Int = GameModeView.gameSelectedNumber; //선택된 게임 번호
		
		switch(sel) {
			case 0: //점프업
				changeRotation(0);
				
				GameModeView.jumpUPStartupViewController = nil;
				GameModeView.jumpUPStartupViewController = GameTitleViewJumpUP();
				GameModeView.jumpUPStartupViewController!.isGameMode = true;
				
				presentViewController(GameModeView.jumpUPStartupViewController!, animated: false, completion: nil);
				break;
			default: break;
		}
		
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
	
	//Set game!
	static func setGame(gameID:Int) {
		//외부에서 게임 정하고 들어옴. 게임시작뷰에서 어디로부터 시작됐는지도 알아야하는데.
		gameSelectedNumber = gameID;
	}
	
}