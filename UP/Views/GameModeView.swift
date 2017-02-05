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
	
	//게임 종료 모드시, viewdidappear부분에 대한 실행을 안 함
	static var isGameExiting:Bool = false;
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.black
		GameModeView.selfView = self
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if (GameModeView.isGameExiting == true) {
			return
		}
		
		let sel:Int = GameModeView.gameSelectedNumber //선택된 게임 번호
		
		switch(sel) {
			case 0: //점프업
				changeRotation(0)
				
				GameModeView.jumpUPStartupViewController = nil
				GameModeView.jumpUPStartupViewController = GameTitleViewJumpUP()
				GameModeView.jumpUPStartupViewController!.isGameMode = true
				
				present(GameModeView.jumpUPStartupViewController!, animated: false, completion: nil)
				break
			default: break
		} //end switch
		
		
	} //end func
	
	
	override func viewWillDisappear(_ animated: Bool) {
		//view disappear event handler
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//Rotation set
	func changeRotation(_ rotationNum:Int) {
		//세로로 화면 돌림
		let portraitOriention = UIInterfaceOrientation.portrait.rawValue;
		let landscapeOriention = UIInterfaceOrientation.landscapeRight.rawValue;
		
		if (rotationNum == 0) { // 0 - 세로, 1 - 가로
			UIDevice.current.setValue(portraitOriention, forKey: "orientation")
		} else {
			UIDevice.current.setValue(landscapeOriention, forKey: "orientation")
		}
		
		//화면을 돌릴 때 돌린 화면 크기 반영 필요
		if (UIScreen.main.bounds.width > UIScreen.main.bounds.height && rotationNum == 0) {
			DeviceManager.changeDeviceSizeWith( CGSize(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width) )
		} else {
			DeviceManager.changeDeviceSizeWith( CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height) )
		} //end if
	} //end if
	
	// Lock rotation and fix
	override var shouldAutorotate : Bool {
		return false //Lock autorotate in this view
	}
	
	//Set game!
	static func setGame(_ gameID:Int) {
		//외부에서 게임 정하고 들어옴. 게임시작뷰에서 어디로부터 시작됐는지도 알아야하는데.
		gameSelectedNumber = gameID
		isGameExiting = false
	}
	
}
