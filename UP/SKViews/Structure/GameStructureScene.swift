//
//  GameStructureScene.swift
//  UP
//
//  Created by ExFl on 2016. 10. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import SpriteKit;

class GameStructureScene:SKScene {
	
	let MATHPI:CGFloat = 3.141592;
	
	//게임 실행 타입 (0= 알람, 1= 메인화면 실행)
	var gameStartupType:Int = 0;
	
	//score (혹은 time으로 사용.)
	var gameScore:Int = 0; var gameScoreStr:String = "";
	var isGamePaused:Bool = true; //일시정지된 경우.
	
	
	//Preloader
	var preloadCompleteCout:Int = 0;
	var preloadCurrentCompleted:Int = 0;
	var preloadCompleteHandler:(() -> Void)? = nil;
	
	
	//////////////////////////UI Menu
	var uiContents:GeneralMenuUI?;
	
	
	
	func preloadEventCall() {
		preloadCurrentCompleted += 1;
		if (preloadCurrentCompleted >= preloadCompleteCout) {
			if (preloadCompleteHandler != nil) {
				preloadCompleteHandler!();
			}
		}
		print("Preload status:", preloadCurrentCompleted,"/",preloadCompleteCout);
	}
	
}
