//
//  JumpUPGame.swift
//  UP
//
//  Created by ExFl on 2016. 3. 1..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit
import UIKit

class JumpUPGame:SKScene {
	
	/* 
		Size ref:
		game_jumpup_assets_time_box: 24.8 X 21.8
		game_jumpup_assets_time_box2: 34.75 X 60.35
		game_jumpup_assets_time_cloud_1~4: 94.05 X 24.4
		game_jumpup_assets_time_trap: 60.8 X 9.2
		
		아스트로 모든 모션: 44 X 65
	*/
	
	//게임 실행 타입 (0= 알람, 1= 메인화면 실행)
	var gameStartupType:Int = 0;
	
	//뒤 배경
	var backgroundCoverImageTexture:SKTexture = SKTexture(imageNamed: "game_jumpup_assets_time_background.png");
	var backgroundCoverImage:SKSpriteNode?;
	
	//time 또는 score 표시 부분
	var gameScoreTitleImageTexture:SKTexture?;
	var gameScoreTitleImage:SKSpriteNode?;
	//time / score에 대한 숫자 관련 텍스쳐 배열
	var gameNumberTexturesArray:Array<SKTexture> = []; // 0~9 10개
	var gameNumberSpriteNodesArray:Array<SKSpriteNode> = []; //000 3개
	
	//score (혹은 time으로 사용.)
	var gameScore:Int = 0; var gameScoreStr:String = "";
	
	override func didMoveToView(view: SKView) {
		//View inited
		print("Game view inited");
		self.backgroundColor = UIColor.blackColor();
		
		//게임 백그라운드 화면 추가
		backgroundCoverImage = SKSpriteNode( texture: backgroundCoverImageTexture );
		backgroundCoverImage!.size = CGSizeMake( DeviceGeneral.scrSize!.width, 226.95 * DeviceGeneral.scrRatioC );
		backgroundCoverImage!.position.x = DeviceGeneral.scrSize!.width / 2; backgroundCoverImage!.position.y = DeviceGeneral.scrSize!.height / 2;
		self.addChild(backgroundCoverImage!);
		
		//time 혹은 score 추가 (실행 타입에 따라 바뀜)
		if (gameStartupType == 0) {
			//time
			gameScoreTitleImageTexture = SKTexture( imageNamed: "game_jumpup_assets_time_time.png" );
			gameScoreTitleImage = SKSpriteNode( texture: gameScoreTitleImageTexture );
			gameScoreTitleImage!.size = CGSizeMake( 87.65 * DeviceGeneral.scrRatioC, 38.35 * DeviceGeneral.scrRatioC );
			
		} else {
			//score
			
		}
		gameScoreTitleImage!.position.x = DeviceGeneral.scrSize!.width / 2;
		
		if (DeviceGeneral.scrSize?.height <= 480.0) {
			//4/4s fallback
			gameScoreTitleImage!.position.y = DeviceGeneral.scrSize!.height - (63 * DeviceGeneral.scrRatioC);
		} else {
			gameScoreTitleImage!.position.y = DeviceGeneral.scrSize!.height - (96 * DeviceGeneral.scrRatioC);
		}
		self.addChild(gameScoreTitleImage!);
		
		//time / score에 대한 데이터 처리
		for (var i:Int = 0; i < 10; ++i) {
			gameNumberTexturesArray += [ SKTexture( imageNamed: String(i) + ".png" ) ];
		} //0~9에 대한 숫자 데이터 텍스쳐
		for (var i:Int = 0; i < 3; ++i) {
			gameNumberSpriteNodesArray += [ SKSpriteNode( texture: gameNumberTexturesArray[0] ) ];
			gameNumberSpriteNodesArray[i].size = CGSizeMake(50 * DeviceGeneral.scrRatioC , 70 * DeviceGeneral.scrRatioC);
			gameNumberSpriteNodesArray[i].position.x =
				DeviceGeneral.scrSize!.width / 2 - (CGFloat(i) * (gameNumberSpriteNodesArray[i].size.width + 12 * DeviceGeneral.scrRatioC))
				/* align to center */
				+ ((gameNumberSpriteNodesArray[i].size.width + 12 * DeviceGeneral.scrRatioC));
			gameNumberSpriteNodesArray[i].position.y = gameScoreTitleImage!.position.y - (72 * DeviceGeneral.scrRatioC);
			self.addChild( gameNumberSpriteNodesArray[i] );
		} //숫자 표시용 디지털 숫자 노드 3개
		
		
		
	}
	
	override func update(interval: CFTimeInterval) {
		//Update per frame
		
		//Render time(or score)
		gameScoreStr = String(gameScore);
		//화면에 배열된 점수 순서: --> 2 1 0
		gameNumberSpriteNodesArray[2].alpha = gameScoreStr.characters.count < 3 ? 0.5 : 1;
		gameNumberSpriteNodesArray[1].alpha = gameScoreStr.characters.count < 2 ? 0.5 : 1;
		//Render text
		gameNumberSpriteNodesArray[0].texture = gameNumberTexturesArray[ Int(gameScoreStr[ gameScoreStr.characters.count - 1 ])! ];
		gameNumberSpriteNodesArray[1].texture =
			gameScoreStr.characters.count < 2 ? gameNumberTexturesArray[0] : gameNumberTexturesArray[ Int(gameScoreStr[ gameScoreStr.characters.count - 2 ])! ];
		gameNumberSpriteNodesArray[2].texture =
			gameScoreStr.characters.count < 3 ? gameNumberTexturesArray[0] : gameNumberTexturesArray[ Int(gameScoreStr[ gameScoreStr.characters.count - 3 ])! ];
		
		
		gameScore += Int(arc4random_uniform(10)) == 0 ? 1 : 0;
		
		
	}
	
} //end of class
