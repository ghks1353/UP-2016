//
//  JumpUPGame.swift
//  UP
//
//  Created by ExFl on 2016. 3. 1..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import AVFoundation;
import SpriteKit;
import UIKit;
import SQLite;

class JumpUPGame:SKScene {
	
	/* 
		Size ref:
		game_jumpup_assets_time_box: 24.8 X 21.8
		game_jumpup_assets_time_box2: 34.75 X 60.35
		game_jumpup_assets_time_cloud_1~4: 94.05 X 24.4
		game_jumpup_assets_time_trap: -
		
		아스트로 모든 모션: 44 X 65 -> 변경됨
	*/
	
	//게임 실행 타입 (0= 알람, 1= 메인화면 실행)
	var gameStartupType:Int = 0;
	
	//아래는 알람으로 게임진행 중일 때 사용하는 값임
	var gameAlarmFirstGoalTime:Int = 40; // 처음 목표로 하는 시간
	var gameLevelAverageTime:Int = 20; //난이도가 높아지는 시간
	var gameTimerMaxTime:Int = 60; //알람으로 게임 진행 중일 때 시간이 추가될 수 있는 최대 수치
	var gameRetireTime:Int = 240; //포기 버튼이 나타나는 시간
	var gameRetireTimeCount:Int = 0; //포기 버튼 카운트
	
	var gameFinishedBool:Bool = false; // 게임이 완전히 끝나면 타이머 다시 늘어나는 등의 동작 없음
	
	//뒤 배경
	var backgroundCoverImageTexture:SKTexture = SKTexture(imageNamed: "game_jumpup_assets_time_background.png");
	var backgroundCoverImage:SKSpriteNode?;
	
	//게임 끝나거나 포기 버튼
	var buttonRetireSprite:SKSpriteNode = SKSpriteNode( texture: SKTexture( imageNamed: "game_jumpup_assets_time_retire.png" ) );
	var buttonAlarmOffSprite:SKSpriteNode = SKSpriteNode( texture: SKTexture( imageNamed: "game_jumpup_assets_time_alram_off.png" ) );
	var buttonAlarmOnSprite:SKSpriteNode = SKSpriteNode( texture: SKTexture( imageNamed: "game_jumpup_assets_time_alram_reset.png" ) );
	
	var gameTipTextField:UILabel = UILabel();
	
	//게임 종료 / 포기 버튼이 생기는 Y위치
	var buttonYAxis:CGFloat = 0;
	
	//time 또는 score 표시 부분
	var gameScoreTitleImageTexture:SKTexture?;
	var gameScoreTitleImage:SKSpriteNode?;
	//time / score에 대한 숫자 관련 텍스쳐 배열
	var gameNumberTexturesArray:Array<SKTexture> = []; // 0~9 10개
	var gameNumberSpriteNodesArray:Array<SKSpriteNode> = []; //000 3개
	
	//score (혹은 time으로 사용.)
	var gameScore:Int = 0; var gameScoreStr:String = "";
	var gameUserJumpCount:Int = 0; //점프 횟수
	
	//1초 tick (알람용)
	var gameSecondTickTimer:NSTimer?;
	
	//Game variables
	var gameStageYAxis:CGFloat = 0; var gameStageYHeight:CGFloat = 0;
	var gameScrollSpeed:Double = 1; //왼쪽으로 흘러가는 게임 스크롤 스피드.
	
	let gameCloudAddDelayMAX:Int = 60; // original: 60
	var gameCloudDecorationAddDelay:Int = 0; //구름 생성 딜레이
	
	let gameEnemyGenerateDelayMAX:Int = 120; // original: 120
	var gameEnemyGenerateDelay:Int = 0; //장애물 생성 딜레이
	
	var gameCharacterUnlimitedLife:Int = 0; //캐릭터 무적 시간. (있을 경우)
	var gameScreenShakeEventDelay:Int = 0; //화면 흔들림 효과를 위한 딜레이.
	var gameRdmElementNum:Int = 0; //랜덤으로 나오는 장애물 고유 번호. (메모리 절약을 위해 재사용)
	
	//Game node arrays
	var gameNodesArray:Array<JumpUpElements?> = [];
	//Game elements textures (for *optimize*)
	var gameNodesTexturesArray:Array<SKTexture> = [];
	
	//AI Move sktextures (for optimize.)
	var gameTexturesAIMoveTexturesArray:Array<SKTexture> = [];
	var gameTexturesAIJMoveTexturesArray:Array<SKTexture> = [];
	var gameTexturesAIJJumpTexturesArray:Array<SKTexture> = [];
	//AI Effect sktextures array
	var gameTexturesAIEffectsArray:Array<Array<SKTexture>> = [];
	
	//Character element
	var characterElement:JumpUpElements?;// = JumpUpElements();
	//판정 완화의 정도
	let characterRatherbox:CGFloat = 18 * DeviceGeneral.scrRatioC;
	
	/////// 통계를 위한 데이터 변수
	
	//아래 시작 종료 시간의 경우, 통계시에는 게임 시작까지 걸린 시간 / 게임 진행 시간으로 재집계
	var stats_gameStartedTimeStamp:Int = 0; //게임 시작 시간
	var stats_gameFinishedTimeStamp:Int = 0; //게임 종료 시간
	
	var stats_gameDiedCount:Int = 0; //맞은 횟수
	var stats_gameIsFailed:Bool = false; //리타이어한 경우
	var stats_gameTouchCount:Int = 0; //전체 터치 횟수
	var stats_gameValidTouchCount:Int = 0; //유효 터치 횟수
	var stats_gameToBackgroundCount:Int = 0; //게임 중 백그라운드로 간 횟수
	
	//View initial function
	override func didMoveToView(view: SKView) {
		print("Game view inited");
		self.backgroundColor = UIColor.blackColor();
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_GAME_JUMPUP);
		
		//variable initialize
		gameCloudDecorationAddDelay = gameCloudAddDelayMAX; //초기값
		//reset character element
		if (characterElement != nil) {
			characterElement = nil;
		}
		gameFinishedBool = false;
		gameEnemyGenerateDelay = 0;
		gameCloudDecorationAddDelay = 0;
		
		//게임 백그라운드 화면 추가
		backgroundCoverImage = SKSpriteNode( texture: backgroundCoverImageTexture );
		backgroundCoverImage!.size = CGSizeMake( self.view!.frame.width, 226.95 * DeviceGeneral.scrRatioC );
		backgroundCoverImage!.position.x = self.view!.frame.width / 2; backgroundCoverImage!.position.y = self.view!.frame.height / 2;
		self.addChild(backgroundCoverImage!);
		
		//실제 게임 스테이지 y값
		gameStageYAxis = backgroundCoverImage!.position.y + (backgroundCoverImage!.size.height / 2);
		gameStageYHeight = backgroundCoverImage!.frame.height;
		
		//게임 팁 표시할 텍스트 추가
		gameTipTextField.textColor = UIColor.whiteColor();
		gameTipTextField.frame = CGRectMake(
			12 * DeviceGeneral.scrRatioC,
			gameStageYAxis + (48 * DeviceGeneral.scrRatioC),
			self.view!.frame.width - (12 * DeviceGeneral.scrRatioC),
			24 * DeviceGeneral.scrRatioC
		);
		gameTipTextField.text = "테스트 텍스트";
		gameTipTextField.textAlignment = .Center;
		gameTipTextField.font = UIFont.systemFontOfSize(18); //절대 크기로 사용
		self.view!.addSubview(gameTipTextField);
		
		//time 혹은 score 추가 (실행 타입에 따라 바뀜)
		gameScoreStr = "";
		
		//아이패드의 경우, 게임 스크롤 속도를 강제로 올려야 함
		if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
			gameScrollSpeed = 2;
		}
		
		//컴포넌트 위치조정을 위한 값
		var movPositionY:CGFloat = 0;
		var gameScoreMovPositionY:CGFloat = 0;
		
		if (gameStartupType == 0) {
			//time
			gameScoreTitleImageTexture = SKTexture( imageNamed: "game_jumpup_assets_time_time.png" );
			gameScoreTitleImage = SKSpriteNode( texture: gameScoreTitleImageTexture );
			
			if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
				//iPhone 전용 사이즈
				gameScoreTitleImage!.size = CGSizeMake( 87.65 * DeviceGeneral.scrRatioC, 38.35 * DeviceGeneral.scrRatioC );
				
				//4/4s의 경우, 세로길이가 부족하므로 기존 아이폰과 다른 y위치 지정
				if (DeviceGeneral.scrSize?.height <= 480.0) {
					//4/4s fallback
					movPositionY = self.view!.frame.height - (63 * DeviceGeneral.scrRatioC);
				} else {
					movPositionY = self.view!.frame.height - (96 * DeviceGeneral.scrRatioC);
				}
				
				gameScoreMovPositionY = movPositionY - (72 * DeviceGeneral.scrRatioC);
			} else {
				//iPad 전용 사이즈 (고정)
				gameScoreTitleImage!.size = CGSizeMake( 122.15, 53.35 );
				movPositionY = self.view!.frame.height - (52 * DeviceGeneral.scrRatioC);
				gameScoreMovPositionY = movPositionY - 94;
			}
			
			gameScore = gameAlarmFirstGoalTime; //초반 120초 부여
			addCountdownTimerForAlarm();
		} else {
			//score
			
		}
		
		gameScoreTitleImage!.position.x = self.view!.frame.width / 2;
		self.addChild(gameScoreTitleImage!);
		
		let moveEffect = SKTMoveEffect(node: gameScoreTitleImage!, duration: 0.5,
			startPosition: CGPointMake( self.view!.frame.width / 2, self.view!.frame.height + gameScoreTitleImage!.frame.height / 2),
			endPosition: CGPointMake( self.view!.frame.width / 2, movPositionY));
		moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut;
		gameScoreTitleImage!.runAction(SKAction.actionWithEffect(moveEffect));
		
		//time / score에 대한 데이터 처리
		if (gameNumberTexturesArray.count == 0) {
			for i:Int in 0 ..< 10 {
				gameNumberTexturesArray += [ SKTexture( imageNamed: SkinManager.getDefaultAssetPresets() + String(i) + ".png" ) ];
			} //0~9에 대한 숫자 데이터 텍스쳐
			for i:Int in 0 ..< 3 {
				gameNumberSpriteNodesArray += [ SKSpriteNode( texture: gameNumberTexturesArray[0] ) ];
				if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) { //iPhone 전용 크기 (가변)
					gameNumberSpriteNodesArray[i].size = CGSizeMake(50 * DeviceGeneral.scrRatioC , 70 * DeviceGeneral.scrRatioC);
					gameNumberSpriteNodesArray[i].position.y = movPositionY - (120 * DeviceGeneral.scrRatioC);
				} else { //iPad 전용 크기 (고정)
					gameNumberSpriteNodesArray[i].size = CGSizeMake(69.7, 97.4);
					gameNumberSpriteNodesArray[i].position.y = movPositionY - 120;
				}
				
				gameNumberSpriteNodesArray[i].position.x =
					self.view!.frame.width / 2 - (CGFloat(i) * (gameNumberSpriteNodesArray[i].size.width + 12 * DeviceGeneral.maxScrRatioC))
					/* align to center */
					+ ((gameNumberSpriteNodesArray[i].size.width + 12 * DeviceGeneral.maxScrRatioC));
				
				self.addChild( gameNumberSpriteNodesArray[i] );
				
				//숫자 밑에서 위로 올라오는 효과 주기
				gameNumberSpriteNodesArray[i].alpha = 0;
				let moveEffect = SKTMoveEffect(node: gameNumberSpriteNodesArray[i], duration: 0.5 ,
					startPosition: CGPointMake( gameNumberSpriteNodesArray[i].position.x, movPositionY - (120 * DeviceGeneral.scrRatioC)),
					endPosition: CGPointMake( gameNumberSpriteNodesArray[i].position.x, gameScoreMovPositionY));
				moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut;
				//gameNumberSpriteNodesArray[i].runAction();
				gameNumberSpriteNodesArray[i].runAction(
					SKAction.group( [
						SKAction.afterDelay(Double(2-i) * 0.1, performAction: SKAction.actionWithEffect(moveEffect)),
						SKAction.fadeInWithDuration(0.5)
				]));
				
			} //숫자 표시용 디지털 숫자 노드 3개
		} //end of chk
		
		if (gameNodesTexturesArray.count == 0) {
			//texture creation
			gameNodesTexturesArray += [
				/* 0 - normal cloud!
					1 - trap
					2 - box
					3 - box (high)
					4 - smile cloud
					5 - more smile cloud
					6 - fucking cloud
				*/
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_1.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_trap.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_box.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_box2.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_2.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_3.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_4.png" )
			];
			
			//Preload textures
			for i:Int in 0 ..< gameNodesTexturesArray.count {
				gameNodesTexturesArray[i].preloadWithCompletionHandler({});
			}
			
		} //end of creation txt
		
		if (gameTexturesAIEffectsArray.count == 0) {
			//texture effect creation
			gameTexturesAIEffectsArray += [ Array<SKTexture>() ]; //빈 텍스쳐 배열을 만들고 그 안에 텍스쳐들 넣음.
			for i in 0 ..< 22 {
				gameTexturesAIEffectsArray[0] += [
					SKTexture( imageNamed: "game_jumpup_assets_time_ai_j_astro_effect" + String(i) + ".png")
				];
				// Preload texture (reduce fps drop)
				(gameTexturesAIEffectsArray[0][i] as SKTexture).preloadWithCompletionHandler({});
			}
			
		} //end of effet create
		
		//기존 배열에 노드가 있을경우 삭제
		delAllElementsFromArray();
		
		//캐릭터 추가
		characterElement = JumpUpElements();
		characterElement!.size = CGSizeMake(60 * DeviceGeneral.scrRatioC, 70 * DeviceGeneral.scrRatioC); //Create astro size
		characterElement!.position.x = 64 * DeviceGeneral.scrRatioC; //캐릭터의 왼쪽. 초기위치 잡음
		characterElement!.position.y = gameStageYAxis - gameStageYHeight + (characterElement!.size.height / 2); // * DeviceGeneral.scrRatioC;
		
		//////// Make textures for Character (Player)
		if (characterElement!.motions_walking.count == 0) {
			for i:Int in 0 ..< 6 {
				characterElement!.motions_walking += [
					SKTexture( imageNamed: "game_jumpup_astro_move" + String(i) + ".png" )
				]; //Character motions preload
				(characterElement!.motions_walking[i] as SKTexture).preloadWithCompletionHandler({});
			}
		} //walking motion end for *character*
		if (characterElement!.motions_jumping.count == 0) {
			for i:Int in 0 ..< 8 {
				characterElement!.motions_jumping += [
					SKTexture( imageNamed: "game_jumpup_astro_jump" + String(i) + ".png" )
				]; //Character motions preload
				(characterElement!.motions_jumping[i] as SKTexture).preloadWithCompletionHandler({});
			}
		} //jumping motion end for *character*
		
		///////////// Make textures for AI
		if (gameTexturesAIMoveTexturesArray.count == 0) {
			for i:Int in 0 ..< 6 {
				gameTexturesAIMoveTexturesArray += [
					SKTexture( imageNamed: "game_jumpup_ai_astro_move" + String(i) + ".png" )
				];
				(gameTexturesAIMoveTexturesArray[i] as SKTexture).preloadWithCompletionHandler({});
			}
		} //jumping motion end for *ai move*
		if (gameTexturesAIJMoveTexturesArray.count == 0) {
			for i:Int in 0 ..< 6 {
				gameTexturesAIJMoveTexturesArray += [
					SKTexture( imageNamed: "game_jumpup_ai_j_astro_move" + String(i) + ".png" )
				];
				(gameTexturesAIJMoveTexturesArray[i] as SKTexture).preloadWithCompletionHandler({});
			}
		} //jumping motion end for *ai_j move*
		if (gameTexturesAIJJumpTexturesArray.count == 0) {
			for i:Int in 0 ..< 7 {
				gameTexturesAIJJumpTexturesArray += [
					SKTexture( imageNamed: "game_jumpup_ai_j_astro_jump" + String(i) + ".png" )
				];
				(gameTexturesAIJJumpTexturesArray[i] as SKTexture).preloadWithCompletionHandler({});
			}
		} //jumping motion end for *ai_j jump*
		
		
		//Character to front
		characterElement!.zPosition = 2;
		self.addChild(characterElement!);
		
		// 일시정지 / 재생 혹은 버그 (나와도 타이머 흐름) 방지를 위한 코드
		let nCenter = NSNotificationCenter.defaultCenter();
		nCenter.addObserver(self, selector: #selector(JumpUPGame.appEnteredToBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil);
		nCenter.addObserver(self, selector: #selector(JumpUPGame.appEnteredToForeground), name: UIApplicationDidBecomeActiveNotification, object: nil);
		
		
		//버튼 배치
		if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
			//아이폰 (상대크기)
			buttonRetireSprite.size = CGSizeMake( 242.05 * DeviceGeneral.scrRatioC, 70.75 * DeviceGeneral.scrRatioC );
			if (DeviceGeneral.scrSize!.height > 480.0) { //iPhone 4, 4s 이외
				buttonYAxis = gameStageYAxis - gameStageYHeight - (128 * DeviceGeneral.scrRatioC);
			} else { //iPhone 4시리즈
				buttonYAxis = gameStageYAxis - gameStageYHeight - (86 * DeviceGeneral.scrRatioC);
			}
		} else { //아이패드 (절대크기)
			buttonRetireSprite.size = CGSizeMake( 336.75, 98.45 );
			buttonYAxis = gameStageYAxis - gameStageYHeight - ((self.size.height - gameStageYHeight) / 4);
		}
		
		buttonRetireSprite.position.x = self.view!.frame.width / 2;
		buttonRetireSprite.position.y = -buttonRetireSprite.size.height / 2; //화면 밖에 배치
		buttonRetireSprite.alpha = 0; //나옴/안나옴 플래그 대신 사용
		self.addChild(buttonRetireSprite);
		buttonRetireSprite.name = "button_retire";
		
		//알람끄기 버튼.
		buttonAlarmOffSprite.size = buttonRetireSprite.size;
		buttonAlarmOffSprite.position.x = self.view!.frame.width / 2;
		buttonAlarmOffSprite.position.y = -buttonAlarmOffSprite.size.height / 2; //화면 밖에 배치
		buttonAlarmOffSprite.alpha = 0;
		self.addChild(buttonAlarmOffSprite);
		buttonAlarmOffSprite.name = "button_alarm_off";
		
		
		/////////////////
		//Game starttime 기록
		stats_gameStartedTimeStamp = Int(NSDate().timeIntervalSince1970);
	}
	
	func appEnteredToBackground() {
		//App -> Background
		
		if (gameStartupType == 0) {
			//알람으로 게임이 켜졌을 때 **타이머 종료 **
			if (gameSecondTickTimer != nil) {
				gameSecondTickTimer!.invalidate();
				gameSecondTickTimer = nil;
			}
		}
	} //end func
	
	func appEnteredToForeground() {
		//App -> Foreground
		
		if (gameStartupType == 0 && gameFinishedBool == false) {
			//알람으로 게임이 켜졌을 때, 졸거나 하는 등으로 화면이 꺼지거나 백그라운드로 나갔다 오면 시간은 리셋.
			gameScore = gameAlarmFirstGoalTime;
			gameRetireTimeCount = gameRetireTimeCount / 2; //리타이어 수작일수도 있으니 이거도 조절함
			stats_gameToBackgroundCount += 1;
			
			//리타이어 버튼이 이미 나와있는 경우, 다시 없앰
			if (buttonRetireSprite.alpha == 1) {
				let moveEffect = SKTMoveEffect(node: buttonRetireSprite, duration: 0.5 ,
					startPosition: CGPointMake( buttonRetireSprite.position.x, buttonRetireSprite.position.y ),
					endPosition: CGPointMake( buttonRetireSprite.position.x, -buttonRetireSprite.frame.height/2)
				);
				moveEffect.timingFunction = SKTTimingFunctionCircularEaseIn;
				buttonRetireSprite.runAction(
					SKAction.group( [
						SKAction.actionWithEffect(moveEffect), SKAction.fadeOutWithDuration(0.5)
						])
				);
			}
			
			addCountdownTimerForAlarm(); //타이머 재시작
		} //end if gametype 0
	} //end func
	
	
	func addCountdownTimerForAlarm() {
		if (gameSecondTickTimer != nil) {
			gameSecondTickTimer!.invalidate();
			gameSecondTickTimer = nil;
		}
		gameSecondTickTimer = UPUtils.setInterval(1, block: updateWithSeconds); //1초간 실행되는 tick
	}
	
	func delAllElementsFromArray() {
		for i:Int in 0 ..< gameNodesArray.count {
			gameNodesArray[i]!.removeFromParent();
			gameNodesArray[i] = nil;
		} //end for
		gameNodesArray = [];
		
		print("deleted all nodes from array");
	}
	
	override func update(interval: CFTimeInterval) {
		//Update per frame
		if (gameFinishedBool == true) {
			// 게임 끝. update 정지
			
			return;
		}
		
		if (gameScreenShakeEventDelay > 0) {
			
			if (gameScreenShakeEventDelay % 3 == 0) {
				self.view?.frame.origin.x =
					( self.view?.frame.origin.x < 0 ? (12 * (CGFloat(gameScreenShakeEventDelay) / 60)) : -(12 * (CGFloat(gameScreenShakeEventDelay) / 60)) ) * DeviceGeneral.scrRatioC;
			}
			gameScreenShakeEventDelay -= 1;
		} else {
			gameScreenShakeEventDelay = 0;
			self.view?.frame.origin.x = 0;
		}
		
		//Render time(or score)
		gameScoreStr = String(gameScore);
		//화면에 배열된 점수 순서: --> 2 1 0
		gameNumberSpriteNodesArray[2].alpha = gameScoreStr.characters.count < 3 ? (max(0.5, gameNumberSpriteNodesArray[2].alpha - 0.04)) : (min(1.0, gameNumberSpriteNodesArray[2].alpha + 0.04));
		gameNumberSpriteNodesArray[1].alpha = gameScoreStr.characters.count < 2 ? (max(0.5, gameNumberSpriteNodesArray[1].alpha - 0.04)) : (min(1.0, gameNumberSpriteNodesArray[1].alpha + 0.04));
		//Render text
		gameNumberSpriteNodesArray[0].texture = gameNumberTexturesArray[ Int(gameScoreStr[ gameScoreStr.characters.count - 1 ])! ];
		gameNumberSpriteNodesArray[1].texture =
			gameScoreStr.characters.count < 2 ? gameNumberTexturesArray[0] : gameNumberTexturesArray[ Int(gameScoreStr[ gameScoreStr.characters.count - 2 ])! ];
		gameNumberSpriteNodesArray[2].texture =
			gameScoreStr.characters.count < 3 ? gameNumberTexturesArray[0] : gameNumberTexturesArray[ Int(gameScoreStr[ gameScoreStr.characters.count - 3 ])! ];
		
		
		//Add decoration elements
		if (gameCloudDecorationAddDelay <= 0) { //add queue
			if (Int(arc4random_uniform(10)) < 8) { //add
				addNodes( 0 ); //0 is decoration cloud
			}
			gameCloudDecorationAddDelay = gameCloudAddDelayMAX;
		} else {
			gameCloudDecorationAddDelay -= 1;
		} //end of decoration cloud add
		
		//Add enemy elements
		if (gameEnemyGenerateDelay <= 0){
			//랜덤 확률로 gen... 일단은 50% 보다 약간 낮은 확률 -> 없앰
			//if (Double(Float(arc4random()) / Float(UINT32_MAX)) < 0.7) {
			//장애물 소환
			//addNodes( 1 + Int(arc4random_uniform( 3 )) );
			
			gameRdmElementNum = 1 + Int(arc4random_uniform( 5 )); //0번은 데코용 구름이라 제외함
			
			//가시나 트랩이 나올 때, 50초 미만으로 남았을 때, 알람으로 켜졌을 때, 약 40% 미만의 확률로 발동
			if ((gameRdmElementNum == 1 || gameRdmElementNum == 2) && gameScore < gameLevelAverageTime && gameStartupType == 0) {
				if (Double(Float(arc4random()) / Float(UINT32_MAX)) <= 0.5) {
					self.addNodes( 6 ); //구름
					self.addNodes( 1 + Int(arc4random_uniform( 2 ))); //가시 + 박스

				} else if (Double(Float(arc4random()) / Float(UINT32_MAX)) <= 0.3) {
					self.addNodes( 3 + Int(arc4random_uniform( 3 )));
				} else {
					self.addNodes( gameRdmElementNum );
				}
			} else {
				self.addNodes( gameRdmElementNum );
			}
			
			//if (Double(Float(arc4random()) / Float(UINT32_MAX)) < 0.2) {
				//낮은 확률로 걸어다니는 로봇 소환
				//addNodes( 4 );
			//}
			//} //gen end
			
			//딜레이 설정
			if (gameStartupType == 0) {
				//딜레이 최대치를 시간이 갈때마다 줄임 (알람으로 켜졌을 때.)
				gameEnemyGenerateDelay = gameEnemyGenerateDelayMAX - Int((gameAlarmFirstGoalTime - gameScore) / 2);
			} //end if
			
		} else {
			gameEnemyGenerateDelay -= 1;
		} //end of generate
		
		
		//Node motion queue
		// - CharacterMotionQueue
		if (characterElement!.motions_frame_delay_left <= 0) {
			characterElement!.motions_current_frame += 1;
			switch( characterElement!.motions_current ) {
				case 0: //walking motion
					characterElement!.texture = characterElement!.motions_walking[characterElement!.motions_current_frame];
					characterElement!.motions_frame_delay_left = 5; //per 5f
					if (characterElement!.motions_current_frame >= characterElement!.motions_walking.count - 1) {
						characterElement!.motions_current_frame = -1; //frame reset to 0 (-1 > next frame < 0)
					}
					break;
				case 1: //Jump motion
					characterElement!.texture = characterElement!.motions_jumping[characterElement!.motions_current_frame];
					characterElement!.motions_frame_delay_left = 5; //per 5f
					if (characterElement!.motions_current_frame >= characterElement!.motions_jumping.count - 1) {
						characterElement!.motions_current_frame = -1; //frame reset to 0 (-1 > next frame < 0)
					}
					break;
				default: break;
			}
		} else {
			//delay min
			characterElement!.motions_frame_delay_left -= 1;
		}
		
		//Character jump queue
		characterElement!.position.y += (characterElement!.ySpeed / 2) * DeviceGeneral.scrRatioC;
							/// 1을 더하는 이유는 기종마다 미세한 픽셀 차이로 인해 모션이 안나오는 버그가 있기 때문임
		if (characterElement!.position.y <= 1 + gameStageYAxis - gameStageYHeight + (characterElement!.size.height / 2)) {
			characterElement!.position.y = gameStageYAxis - gameStageYHeight + (characterElement!.size.height / 2);
			characterElement!.ySpeed = 0;
			characterElement!.changeMotion(0); //walking motion
			characterElement!.jumpFlaggedCount = 0; //점프횟수 초기화
		} else {
			characterElement!.ySpeed -= 0.5;
			characterElement!.changeMotion(1); //jumping motion
		}
		
		//캐릭터 무적 처리
		if (gameCharacterUnlimitedLife > 0) {
			gameCharacterUnlimitedLife -= 1;
			
			characterElement!.alpha = characterElement!.alpha == 0 ? 1 : 0;
			
		} else if (gameCharacterUnlimitedLife <= 0) {
			characterElement!.alpha = 1;
		} //end if
		
		
		//Scroll nodes + Motion queue (w/o character)
		for i:Int in 0 ..< gameNodesArray.count {
			if (i >= gameNodesArray.count) {
				break;
			}
			
			//위치관련
			//print("Checking element type - ", gameNodesArray[i]!.elementType, JumpUpElements.TYPE_EFFECT);
			switch(gameNodesArray[i]!.elementType) {
				case JumpUpElements.TYPE_DECORATION: // ... cloud?
					gameNodesArray[i]!.position.x -= CGFloat(gameScrollSpeed * gameNodesArray[i]!.elementSpeed);
					break;
				case JumpUpElements.TYPE_STATIC_ENEMY, JumpUpElements.TYPE_DYNAMIC_ENEMY: // 고정형 장애물, 움직
					gameNodesArray[i]!.position.x -= CGFloat(gameScrollSpeed * gameNodesArray[i]!.elementSpeed);
					break;
				case JumpUpElements.TYPE_EFFECT:
					//print("Effect status", gameNodesArray[i]!.elementTargetElement);
					if (gameNodesArray[i]!.elementTargetElement != nil) {
						gameNodesArray[i]!.position.x = gameNodesArray[i]!.elementTargetElement!.position.x + gameNodesArray[i]!.elementTargetPosFix!.width;
						gameNodesArray[i]!.position.y = gameNodesArray[i]!.elementTargetElement!.position.y + gameNodesArray[i]!.elementTargetPosFix!.height;
						//print("Moving effect to target.");
					}
					
					break;
				
				default: break;
			} //end switch
			
			//If node is not visible, remove it
			if (gameNodesArray[i]!.position.x < -gameNodesArray[i]!.size.width / 2) { //remove
				gameNodesArray[i]!.removeFromParent();
				gameNodesArray[i] = nil;
				gameNodesArray.removeAtIndex(i);
				continue;
			} //end of remove
			
			//do motion queue
			if (
				gameNodesArray[i]!.elementType == JumpUpElements.TYPE_DYNAMIC_ENEMY ||
				gameNodesArray[i]!.elementType == JumpUpElements.TYPE_EFFECT
				) {
				if (gameNodesArray[i]!.motions_frame_delay_left <= 0) {
					gameNodesArray[i]!.motions_current_frame += 1;
					switch( gameNodesArray[i]!.motions_current ) {
						case 0: //walking motion
							gameNodesArray[i]!.texture = gameNodesArray[i]!.motions_walking[gameNodesArray[i]!.motions_current_frame];
							gameNodesArray[i]!.motions_frame_delay_left = 5; //per 5f
							if (gameNodesArray[i]!.motions_current_frame >= gameNodesArray[i]!.motions_walking.count - 1) {
								gameNodesArray[i]!.motions_current_frame = -1; //frame reset to 0 (-1 > next frame < 0)
							}
							break;
						case 1: //Jump motion
							gameNodesArray[i]!.texture = gameNodesArray[i]!.motions_jumping[gameNodesArray[i]!.motions_current_frame];
							gameNodesArray[i]!.motions_frame_delay_left = 5; //per 5f
							if (gameNodesArray[i]!.motions_current_frame >= gameNodesArray[i]!.motions_jumping.count - 1) {
								gameNodesArray[i]!.motions_current_frame = -1; //frame reset to 0 (-1 > next frame < 0)
							}
							break;
						case 2: //effect
							gameNodesArray[i]!.texture = gameNodesArray[i]!.motions_effect[gameNodesArray[i]!.motions_current_frame];
							gameNodesArray[i]!.motions_frame_delay_left = 0; //per 0f
							if (gameNodesArray[i]!.motions_current_frame >= gameNodesArray[i]!.motions_effect.count - 1) {
								//motion over -> dispose (remove)
								gameNodesArray[i]!.removeFromParent(); gameNodesArray[i] = nil;
								gameNodesArray.removeAtIndex(i);
								continue;
							} //end if
							break;
						default: break;
					}
				} else {
					//delay min
					gameNodesArray[i]!.motions_frame_delay_left -= 1;
				}
			}
			
			//Character coll detection check
			switch(gameNodesArray[i]!.elementType) {
				case JumpUpElements.TYPE_STATIC_ENEMY, JumpUpElements.TYPE_DYNAMIC_ENEMY: // 고정형 장애물 및 움직 장애물
					
					//적 점프 queue
					if (gameNodesArray[i]!.elementFlag != 2) { //고정형 장애물은 물리 무시
						gameNodesArray[i]!.position.y += (gameNodesArray[i]!.ySpeed / 2) * DeviceGeneral.scrRatioC;
						if (gameNodesArray[i]!.position.y <= 1 + gameStageYAxis - gameStageYHeight + (gameNodesArray[i]!.size.height / 2)) {
							gameNodesArray[i]!.position.y = gameStageYAxis - gameStageYHeight + (gameNodesArray[i]!.size.height / 2);
							gameNodesArray[i]!.ySpeed = 0;
							gameNodesArray[i]!.changeMotion(0); //walking motion
							gameNodesArray[i]!.jumpFlaggedCount = 0; //점프횟수 초기화
						} else {
							gameNodesArray[i]!.ySpeed -= 0.5;
							gameNodesArray[i]!.changeMotion(1); //jumping motion
						}
					}
					
					
					
					if ( //캐릭터 - 적간 충돌판정 (조금 완화 함.)
						characterElement!.containsPoint( gameNodesArray[i]!.position ) ||
							characterElement!.containsPoint( CGPoint( x: (gameNodesArray[i]!.position.x - gameNodesArray[i]!.frame.width / 2) + characterRatherbox, y: (gameNodesArray[i]!.position.y - gameNodesArray[i]!.frame.height / 2) + characterRatherbox  ) ) ||
							characterElement!.containsPoint( CGPoint( x: (gameNodesArray[i]!.position.x + gameNodesArray[i]!.frame.width / 2) - characterRatherbox, y: (gameNodesArray[i]!.position.y - gameNodesArray[i]!.frame.height / 2) + characterRatherbox ) ) ||
							characterElement!.containsPoint( CGPoint( x: (gameNodesArray[i]!.position.x - gameNodesArray[i]!.frame.width / 2) + characterRatherbox, y: (gameNodesArray[i]!.position.y + gameNodesArray[i]!.frame.height / 2) - characterRatherbox ) ) ||
							characterElement!.containsPoint( CGPoint( x: (gameNodesArray[i]!.position.x - gameNodesArray[i]!.frame.width / 2) + characterRatherbox, y: (gameNodesArray[i]!.position.y - gameNodesArray[i]!.frame.height / 2) + characterRatherbox ) )
						) {
							if (gameCharacterUnlimitedLife == 0) {
								print("Character collision");
								gameCharacterUnlimitedLife = 120; //무적시간 부여
								gameScreenShakeEventDelay = 60; //화면 흔들림 효과
								
								//진동
								AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate));
								
								//통계값 추가
								stats_gameDiedCount += 1;
								
								if (gameStartupType == 0) {
									//알람으로 켜진 경우, 최대 120초까지 커지도록 시간 추가
									if (gameScore <= gameLevelAverageTime) {
										gameScore = min( gameScore + 4, gameTimerMaxTime);
									} else {
										gameScore = min( gameScore + 8, gameTimerMaxTime);
									}
									
								} //end if
							} //end if
					} //end if
					
					break;
				default: break;
			} //end switch
			
			//특수한 적의 경우 특별한 경우 점프를 하도록 만듬. 아래 적은 점프하느 ㄴ적의 경우.
			//점프할거라는 신호를 먼저 주고 점프해야 함. addNodes( 10000 );
			if (gameNodesArray[i]!.elementFlag == 1 && gameNodesArray[i]!.elementTickFlag == 0
				&& gameNodesArray[i]!.position.x < 260 * DeviceGeneral.scrRatioC ) {
				addNodes( 10000, posX: gameNodesArray[i]!.position.x, posY: gameNodesArray[i]!.position.y, targetElement: gameNodesArray[i] );
				gameNodesArray[i]!.elementTickFlag = 1;
			} else if (gameNodesArray[i]!.elementFlag == 1 && gameNodesArray[i]!.elementTickFlag == 1
				&& gameNodesArray[i]!.position.x < 160 * DeviceGeneral.scrRatioC ) {
				gameNodesArray[i]!.ySpeed = 14;
				gameNodesArray[i]!.elementTickFlag = 2;
			}
			
			
			
		} //end for
		
	} //end of tick
	
	//node add func
	func addNodes( elementType:Int, posX:CGFloat = 0, posY:CGFloat = 0, targetElement:SKSpriteNode? = nil ) {
		var toAddelement:JumpUpElements?; // = JumpUpElements();
		switch(elementType){
			case 0: //0 - Cloud for decoration
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[0] );
				toAddelement!.elementType = JumpUpElements.TYPE_DECORATION;
				toAddelement!.size = CGSizeMake( 94.05 * DeviceGeneral.scrRatioC , 24.4 * DeviceGeneral.scrRatioC );
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) - (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 56) * DeviceGeneral.scrRatioC);
				//구름 종류 증식 (찌그러짐 ^^)
				toAddelement!.yScale = 1.0 - CGFloat(Float(arc4random()) / Float(UINT32_MAX)) / 3;
				
				toAddelement!.elementSpeed = 1.1 + Double(Float(arc4random()) / Float(UINT32_MAX)) / 9;
				break;
			case 1, 2, 3:
				/* 1 - fuc**ng trap
					2 - **cking box
					3 - triple-fu**ing box */
				/*
				game_jumpup_assets_time_box: 24.8 X 21.8
				game_jumpup_assets_time_box2: 34.75 X 60.35
				*/
				
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[elementType] );
				switch(elementType) {
					case 1:
						toAddelement!.size = CGSizeMake( 39.4 * DeviceGeneral.scrRatioC , 9.2 * DeviceGeneral.scrRatioC );
						break;
					case 2:
						toAddelement!.size = CGSizeMake( 24.8 * DeviceGeneral.scrRatioC , 21.8 * DeviceGeneral.scrRatioC );
						break;
					case 3:
						toAddelement!.size = CGSizeMake( 34.75 * DeviceGeneral.scrRatioC , 60.35 * DeviceGeneral.scrRatioC );
						break;
					default: break;
				}
				
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
											/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2);
				toAddelement!.elementSpeed = 1.8; //속도.
				
				break;
			
			case 4:
				//AI Astro (점프 안하고 걸어오는)
				toAddelement = JumpUpElements(); //텍스쳐는 모션으로 정할 것임.
				toAddelement!.size = CGSizeMake( 60 * DeviceGeneral.scrRatioC , 70 * DeviceGeneral.scrRatioC );
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2);
				toAddelement!.elementSpeed = 2.8; //속도.

				toAddelement!.motions_current = 0;
				toAddelement!.motions_walking = gameTexturesAIMoveTexturesArray;
				
				break;
			
			case 5:
				//AI Astro (점프)
				toAddelement = JumpUpElements(); //텍스쳐는 모션으로 정할 것임.
				toAddelement!.size = CGSizeMake( 60 * DeviceGeneral.scrRatioC , 70 * DeviceGeneral.scrRatioC );
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2);
				toAddelement!.elementSpeed = 2.8; //속도.
				
				toAddelement!.motions_current = 0;
				toAddelement!.motions_walking = gameTexturesAIJMoveTexturesArray;
				toAddelement!.motions_jumping = gameTexturesAIJJumpTexturesArray;
				
				toAddelement!.elementFlag = 1; //점프하는 장애물 (flag)
				
				break;
			
			case 6:
				//페이크 구름
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[6] );
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY;
				toAddelement!.size = CGSizeMake( 94.05 * DeviceGeneral.scrRatioC , 24.4 * DeviceGeneral.scrRatioC );
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) - (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 56) * DeviceGeneral.scrRatioC);
				//구름 종류 증식 (찌그러짐 ^^)
				toAddelement!.yScale = 1.0 - CGFloat(Float(arc4random()) / Float(UINT32_MAX)) / 3;
				
				toAddelement!.elementSpeed = 1.8; // + Double(Float(arc4random()) / Float(UINT32_MAX)) / 9;
				toAddelement!.elementFlag = 2; //고정형 (물리 안받음)
				
				break;
			
			case 10000:
				//AI 폭발 효과
				toAddelement = JumpUpElements();
				toAddelement!.elementType = JumpUpElements.TYPE_EFFECT;
				toAddelement!.size = CGSizeMake( 150 * DeviceGeneral.scrRatioC , 150 * DeviceGeneral.scrRatioC );
				toAddelement!.position.x = posX; toAddelement!.position.y = posY; //정해진 위치로
				
				//약간의 위치조정.
				toAddelement!.elementTargetPosFix = CGSizeMake( 0, 10 * DeviceGeneral.scrRatioC );
				toAddelement!.elementTargetElement = targetElement;
				
				if (targetElement == nil) {
					print("boom effect target is null.");
				}
				
				toAddelement!.elementSpeed = 0; //타겟이 정해져있는경우 타겟에 맞춰서 움직일테니.
				toAddelement!.motions_current = 2; //폭발효과는 2번
				toAddelement!.motions_effect = gameTexturesAIEffectsArray[0]; //텍스쳐 배열의 텍스쳐 배열 (이중배열)
				
				break;
			
			default: break;
		}
		
		toAddelement!.zPosition = 1; //behind of character
		self.addChild(toAddelement!);
		gameNodesArray += [toAddelement];
		
		
	}
	
	
	/////////////
	func updateWithSeconds() {
		//알람 게임으로 실행되었을 때, 1초마다 주기적으로 실행되는 함수 (시간 체크시만 사용함)
		//이 함수의 문제점: *앱이 백그라운드에 돌아가도 작동함!!*
		/*if (DeviceGeneral.appIsBackground == true) {
			return;
		} *///앱이 백그라운드에 있으면 함수 진행 자체를 캔슬함.
		
		if (gameScore <= 0) {
			print("Game is over");
			gameFinishedBool = true;
			
			gameSecondTickTimer?.invalidate();
			gameSecondTickTimer = nil;
			
			//게임 끝. 알람끄기 버튼 표시.
			
			//리타이어 버튼이 이미 나와있는 경우, 다시 없앰
			if (buttonRetireSprite.alpha == 1) {
				let moveEffect = SKTMoveEffect(node: buttonRetireSprite, duration: 0.5 ,
					startPosition: CGPointMake( buttonRetireSprite.position.x, buttonRetireSprite.position.y ),
					endPosition: CGPointMake( buttonRetireSprite.position.x, -buttonRetireSprite.frame.height/2)
				);
				moveEffect.timingFunction = SKTTimingFunctionCircularEaseIn;
				buttonRetireSprite.runAction(
					SKAction.group( [
						SKAction.actionWithEffect(moveEffect), SKAction.fadeOutWithDuration(0.5)
						])
				);
			}
			
			print("Showing off button");
			buttonAlarmOffSprite.alpha = 1;
			let moveEffect = SKTMoveEffect(node: buttonAlarmOffSprite, duration: 0.5 ,
				startPosition: CGPointMake( buttonAlarmOffSprite.position.x, buttonAlarmOffSprite.position.y ),
				endPosition: CGPointMake( buttonAlarmOffSprite.position.x, buttonYAxis)
			);
			moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut;
			buttonAlarmOffSprite.runAction(
				SKAction.actionWithEffect(moveEffect));
			
			
			//게임 끝났으니 알람 끄기(임시)
			//exitJumpUPGame();
			
		} else {
			gameScore -= 1;
			gameRetireTimeCount = min(gameRetireTimeCount + 1, gameRetireTime); //포기 버튼을 띄워야 할 때 필요
		}
		
		//포기 버튼을 띄워야하면 띄움. 점프횟수가 60번을 넘어야함
		if (gameRetireTimeCount >= gameRetireTime && buttonRetireSprite.alpha == 0 && gameUserJumpCount > 60) {
			print("Showing retire button");
			buttonRetireSprite.alpha = 1;
			let moveEffect = SKTMoveEffect(node: buttonRetireSprite, duration: 0.5 ,
				startPosition: CGPointMake( buttonRetireSprite.position.x, buttonRetireSprite.position.y ),
				endPosition: CGPointMake( buttonRetireSprite.position.x, buttonYAxis)
				);
			moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut;
			buttonRetireSprite.runAction(
				SKAction.actionWithEffect(moveEffect));
		}
		
	}
	
	//////// touch evt handler
	//Swift 2용
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for touch in touches {
			let location = (touch as UITouch).locationInNode(self);
			if let chkButtonName:SKNode = self.nodeAtPoint(location) {
				if (chkButtonName.name == "button_retire" || chkButtonName.name == "button_alarm_off") {
					//포기 버튼일 때 혹은 알람끄기 일 때
					
					//포기 여부 체크.
					stats_gameIsFailed = chkButtonName.name == "button_retire" ? true : false;
					
					exitJumpUPGame();
					
				} else {
					//기타 터치
					
					//터치 통계값 추가
					stats_gameTouchCount += 1;
					
					if (gameFinishedBool == false) { //게임이 진행중일 때만 점프 가능.
						if (characterElement!.jumpFlaggedCount < 2) { //캐릭터 점프횟수 제한
							characterElement!.ySpeed = 11;
							characterElement!.jumpFlaggedCount += 1;
							gameUserJumpCount += 1; //점프 횟수 카운트
							
							//통계값 추가 (유효터치)
							stats_gameValidTouchCount += 1;
						}
					}
				}
			}
		} //end for
		
		
		super.touchesBegan(touches, withEvent:event)
	}
	
	/* 
	var stats_gameStartedTimeStamp:Int = 0; //게임 시작 시간
	var stats_gameFinishedTimeStamp:Int = 0; //게임 종료 시간
	
	var stats_gameDiedCount:Int = 0; //맞은 횟수
	var stats_gameIsFailed:Bool = false; //리타이어한 경우
	var stats_gameTouchCount:Int = 0; //전체 터치 횟수
	var stats_gameValidTouchCount:Int = 0; //유효 터치 횟수
	
	*/
	
	//게임 포기 혹은 종료.
	func exitJumpUPGame() {
		print("Game finished");
		
		gameFinishedBool = true;
		let currentDateTimeStamp:Int64 = Int64(NSDate().timeIntervalSince1970);
		stats_gameFinishedTimeStamp = Int(currentDateTimeStamp);
		
		AnalyticsManager.untrackScreen(); //untrack to previous screen
		
		/// .. and send result for tracking.
		AnalyticsManager.makeEvent(
			AnalyticsManager.E_CATEGORY_GAMEDATA,
			action: AnalyticsManager.E_ACTION_GAME_JUMPUP,
			label: AnalyticsManager.E_LABEL_JUMPUP_PLAYTIME,
			value: stats_gameFinishedTimeStamp - stats_gameStartedTimeStamp);
		
		
		//// 알람으로 켜진 경우에만 로그를 남김
		if (gameStartupType == 0) {
			do {
				//DB -> 알람 기록 저장 (게임 시작 전까지 걸린 시간)
				try DataManager.db()!.run(
					DataManager.statsTable().insert(
						//type -> 게임 로그 데이터 저장
						Expression<Int64>("type") <- Int64(DataManager.statsType.TYPE_ALARM_START_TIME),
						Expression<Int64>("date") <- currentDateTimeStamp,
						Expression<Int64?>("statsDataInt") <-
						Int64(stats_gameStartedTimeStamp - Int(AlarmManager.getAlarm(AlarmRingView.selfView!.currentAlarmElement!.alarmID)!.alarmFireDate.timeIntervalSince1970))
						/* 게임 시작까지 걸린 시간 (시작시간 - 현재 울리고있는 알람의 알람 발생 시각) */
					)
				); //end try
				
				//DB -> 알람 기록 저장 (게임 플레이 시간)
				try DataManager.db()!.run(
					DataManager.statsTable().insert(
						//type -> 게임 로그 데이터 저장
						Expression<Int64>("type") <- Int64(DataManager.statsType.TYPE_ALARM_CLEAR_TIME),
						Expression<Int64>("date") <- currentDateTimeStamp,
						Expression<Int64?>("statsDataInt") <-
							Int64(stats_gameFinishedTimeStamp - stats_gameStartedTimeStamp)
						/* 게임 플레이 경과시간 */
					)
				); //end try
				
				//DB -> 게임 기록 저장
				/*t.column( Expression<Int64>("id") , primaryKey: .Autoincrement) //uid.
				t.column( Expression<Int64>("gameid")) //게임 ID
				t.column( Expression<Int64>("date")) //통계 저장 날짜
				t.column( Expression<Int64>("startedTimeStamp")) //게임 시작 시간 (타임스탬프)
				t.column( Expression<Int64>("playTime")) //게임 플레이 시간
				t.column( Expression<Int64>("resultMissCount")) //게임오버 등에 해당하는 값
				t.column( Expression<Int64>("touchAll")) //전체 행동수
				t.column( Expression<Int64>("touchValid")) //유효 행동수
				t.column( Expression<Int64>("backgroundExitCount")) //중간에 백그라운드로 나간 횟수*/
				
				
				try DataManager.db()!.run(
					DataManager.gameResultTable().insert(
						//통계 저장 날짜 저장 (timestamp)
						Expression<Int64>("date") <- currentDateTimeStamp, /* 데이터 기록 타임스탬프 */
						Expression<Int64>("gameid") <- 0, /* 게임 ID */
						Expression<Int64>("gameCleared") <- (stats_gameIsFailed == false ? 1 : 0), /* 클리어 여부. 1 = 클리어 */
						Expression<Int64>("startedTimeStamp") <- Int64(stats_gameStartedTimeStamp), /* 게임 시작 시간 */
						Expression<Int64>("playTime") <- Int64(stats_gameFinishedTimeStamp - stats_gameStartedTimeStamp), /* 플레이 시간 */
						Expression<Int64>("resultMissCount") <- Int64(stats_gameDiedCount), /* 뒈짓 */
						Expression<Int64>("touchAll") <- Int64(stats_gameTouchCount), /* 총 터치수 */
						Expression<Int64>("touchValid") <- Int64(stats_gameValidTouchCount), /* 유효 터치수 */
						Expression<Int64>("backgroundExitCount") <- Int64(stats_gameToBackgroundCount) /* 백그라운드 탈출횟수 */
					) /* insert end */
				); // run end
				
				print("DB Statement successful");
				//covertToStringArray
			} catch {
				print("DB Statement error in JumpUP");
			}
			
			
		} // end if
		
		AlarmManager.gameClearToggleAlarm( AlarmRingView.selfView!.currentAlarmElement!.alarmID, cleared: true );
		AlarmManager.mergeAlarm(); //Merge it
		AlarmManager.alarmRingActivated = false;
		//Refresh tables
		AlarmListView.selfView?.createTableList();
		
		AlarmRingView.selfView!.dismissViewControllerAnimated(false, completion: nil);
		GlobalSubView.alarmRingViewcontroller.dismissViewControllerAnimated(true, completion: nil);
		
	}
	
} //end of class