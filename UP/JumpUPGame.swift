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
		game_jumpup_assets_time_trap: -
		
		아스트로 모든 모션: 44 X 65
	*/
	
	//게임 실행 타입 (0= 알람, 1= 메인화면 실행)
	var gameStartupType:Int = 0;
	var gameAlarmFirstGoalTime:Int = 120; // 처음 목표로 하는 시간
	var gameFinishedBool:Bool = false; // 게임이 완전히 끝나면 타이머 다시 늘어나는 등의 동작 없음
	
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
	
	//1초 tick (알람용)
	var gameSecondTickTimer:NSTimer?;
	
	//Game variables
	var gameStageYAxis:CGFloat = 0; var gameStageYHeight:CGFloat = 0;
	var gameScrollSpeed:Double = 1; //왼쪽으로 흘러가는 게임 스크롤 스피드.
	
	let gameCloudAddDelayMAX:Int = 60;
	var gameCloudDecorationAddDelay:Int = 0; //구름 생성 딜레이
	
	let gameEnemyGenerateDelayMAX:Int = 120;
	var gameEnemyGenerateDelay:Int = 0; //장애물 생성 딜레이
	
	var gameCharacterUnlimitedLife:Int = 0; //캐릭터 무적 시간. (있을 경우)
	
	//Game node arrays
	var gameNodesArray:Array<JumpUpElements?> = [];
	//Game elements textures (for *optimize*)
	var gameNodesTexturesArray:Array<SKTexture> = [];
	
	//AI Move sktextures (for optimize.)
	var gameTexturesAIMoveTexturesArray:Array<SKTexture> = [];
	var gameTexturesAIJMoveTexturesArray:Array<SKTexture> = [];
	var gameTexturesAIJJumpTexturesArray:Array<SKTexture> = [];
	
	
	//Character element
	var characterElement:JumpUpElements?;// = JumpUpElements();
	
	override func didMoveToView(view: SKView) {
		//View inited
		print("Game view inited");
		self.backgroundColor = UIColor.blackColor();
		
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
		backgroundCoverImage!.size = CGSizeMake( DeviceGeneral.scrSize!.width, 226.95 * DeviceGeneral.scrRatioC );
		backgroundCoverImage!.position.x = DeviceGeneral.scrSize!.width / 2; backgroundCoverImage!.position.y = DeviceGeneral.scrSize!.height / 2;
		self.addChild(backgroundCoverImage!);
		
		//실제 게임 스테이지 y값
		gameStageYAxis = backgroundCoverImage!.position.y + (backgroundCoverImage!.size.height / 2);
		gameStageYHeight = backgroundCoverImage!.frame.height;
		
		//time 혹은 score 추가 (실행 타입에 따라 바뀜)
		gameScoreStr = "";
		if (gameStartupType == 0) {
			//time
			gameScoreTitleImageTexture = SKTexture( imageNamed: "game_jumpup_assets_time_time.png" );
			gameScoreTitleImage = SKSpriteNode( texture: gameScoreTitleImageTexture );
			gameScoreTitleImage!.size = CGSizeMake( 87.65 * DeviceGeneral.scrRatioC, 38.35 * DeviceGeneral.scrRatioC );
			
			gameScore = gameAlarmFirstGoalTime; //초반 120초 부여
			addCountdownTimerForAlarm();
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
		if (gameNumberTexturesArray.count == 0) {
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
		} //end of chk
		
		if (gameNodesTexturesArray.count == 0) {
			//texture creation
			gameNodesTexturesArray += [
				/* 0 - normal cloud!
					1 - trap
					2 - box
					3 - box (high)
				*/
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_1.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_trap.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_box.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_box2.png" )
				
			];
			
		} //end of creation txt
		
		//기존 배열에 노드가 있을경우 삭제
		delAllElementsFromArray();
		
		//캐릭터 추가
		characterElement = JumpUpElements();
		characterElement!.size = CGSizeMake(48 * DeviceGeneral.scrRatioC, 65 * DeviceGeneral.scrRatioC); //Create astro size
		characterElement!.position.x = 64 * DeviceGeneral.scrRatioC; //캐릭터의 왼쪽. 초기위치 잡음
		characterElement!.position.y = gameStageYAxis - gameStageYHeight + (characterElement!.size.height / 2); // * DeviceGeneral.scrRatioC;
		
		//////// 캐릭터 모션 만들기
		if (characterElement!.motions_walking.count == 0) {
			for (var i:Int = 0; i < 6; ++i) {
				characterElement!.motions_walking += [
					SKTexture( imageNamed: "game_jumpup_astro_move" + String(i) + ".png" )
				];
			}
		} //walking motion end for *character*
		if (characterElement!.motions_jumping.count == 0) {
			for (var i:Int = 0; i < 8; ++i) {
				characterElement!.motions_jumping += [
					SKTexture( imageNamed: "game_jumpup_astro_jump" + String(i) + ".png" )
				];
			}
		} //jumping motion end for *character*
		
		/*
		var gameTexturesAIMoveTexturesArray:Array<SKTexture> = [];
		var gameTexturesAIJMoveTexturesArray:Array<SKTexture> = [];
		var gameTexturesAIJJumpTexturesArray:Array<SKTexture> = [];
		*/
		if (gameTexturesAIMoveTexturesArray.count == 0) {
			for (var i:Int = 0; i < 6; ++i) {
				gameTexturesAIMoveTexturesArray += [
					SKTexture( imageNamed: "game_jumpup_ai_astro_move" + String(i) + ".png" )
				];
			}
		} //jumping motion end for *ai move*
		if (gameTexturesAIJMoveTexturesArray.count == 0) {
			for (var i:Int = 0; i < 6; ++i) {
				gameTexturesAIJMoveTexturesArray += [
					SKTexture( imageNamed: "game_jumpup_ai_j_astro_move" + String(i) + ".png" )
				];
			}
		} //jumping motion end for *ai_j move*
		if (gameTexturesAIJJumpTexturesArray.count == 0) {
			for (var i:Int = 0; i < 7; ++i) {
				gameTexturesAIJJumpTexturesArray += [
					SKTexture( imageNamed: "game_jumpup_ai_j_astro_jump" + String(i) + ".png" )
				];
			}
		} //jumping motion end for *ai_j jump*
		
		
		//Character to front
		characterElement!.zPosition = 2;
		self.addChild(characterElement!);
		
		// 일시정지 / 재생 혹은 버그 (나와도 타이머 흐름) 방지를 위한 코드
		let nCenter = NSNotificationCenter.defaultCenter();
		nCenter.addObserver(self, selector: "appEnteredToBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil);
		nCenter.addObserver(self, selector: "appEnteredToForeground", name: UIApplicationDidBecomeActiveNotification, object: nil);
  
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
			//알람으로 게임이 켜졌을 때
			//감히 멀티태스킹을 했겠다. 120초 다시줌
			gameScore = gameAlarmFirstGoalTime;
			addCountdownTimerForAlarm(); //타이머 재시작
		}
	} //end func
	
	
	func addCountdownTimerForAlarm() {
		if (gameSecondTickTimer != nil) {
			gameSecondTickTimer!.invalidate();
			gameSecondTickTimer = nil;
		}
		gameSecondTickTimer = UPUtils.setInterval(1, block: updateWithSeconds); //1초간 실행되는 tick
	}
	
	func delAllElementsFromArray() {
		for (var i:Int = 0; i < gameNodesArray.count; ++i) {
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
			
			addNodes( 1 + Int(arc4random_uniform( 4 )) );
			
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
		characterElement!.position.y += characterElement!.ySpeed / 2;
		if (characterElement!.position.y <= gameStageYAxis - gameStageYHeight + (characterElement!.size.height / 2)) {
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
		for (var i:Int = 0; i < gameNodesArray.count; ++i) {
			switch(gameNodesArray[i]!.elementType) {
				case JumpUpElements.TYPE_DECORATION: // ... cloud?
					gameNodesArray[i]!.position.x -= CGFloat(gameScrollSpeed * gameNodesArray[i]!.elementSpeed);
					break;
				case JumpUpElements.TYPE_STATIC_ENEMY, JumpUpElements.TYPE_DYNAMIC_ENEMY: // 고정형 장애물, 움직
					gameNodesArray[i]!.position.x -= CGFloat(gameScrollSpeed * gameNodesArray[i]!.elementSpeed);
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
			if (gameNodesArray[i]!.elementType == JumpUpElements.TYPE_DYNAMIC_ENEMY) {
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
						gameNodesArray[i]!.texture = gameNodesArray[i]!.motions_jumping[characterElement!.motions_current_frame];
						gameNodesArray[i]!.motions_frame_delay_left = 5; //per 5f
						if (gameNodesArray[i]!.motions_current_frame >= gameNodesArray[i]!.motions_jumping.count - 1) {
							gameNodesArray[i]!.motions_current_frame = -1; //frame reset to 0 (-1 > next frame < 0)
						}
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
					
					if ( //캐릭터 - 적간 충돌판정
						characterElement!.containsPoint( gameNodesArray[i]!.position ) ||
							characterElement!.containsPoint( CGPoint( x: gameNodesArray[i]!.position.x - gameNodesArray[i]!.frame.width / 2, y: gameNodesArray[i]!.position.y - gameNodesArray[i]!.frame.height / 2) ) ||
							characterElement!.containsPoint( CGPoint( x: gameNodesArray[i]!.position.x + gameNodesArray[i]!.frame.width / 2, y: gameNodesArray[i]!.position.y - gameNodesArray[i]!.frame.height / 2) ) ||
							characterElement!.containsPoint( CGPoint( x: gameNodesArray[i]!.position.x - gameNodesArray[i]!.frame.width / 2, y: gameNodesArray[i]!.position.y + gameNodesArray[i]!.frame.height / 2) ) ||
							characterElement!.containsPoint( CGPoint( x: gameNodesArray[i]!.position.x - gameNodesArray[i]!.frame.width / 2, y: gameNodesArray[i]!.position.y - gameNodesArray[i]!.frame.height / 2) )
						) {
							if (gameCharacterUnlimitedLife == 0) {
								print("Character collision");
								gameCharacterUnlimitedLife = 120; //무적시간 부여
								
								if (gameStartupType == 0) {
									//알람으로 켜진 경우, 최대 120초까지 커지도록 시간 추가
									gameScore = min( gameScore + 12, 120);
								}
							}
					} //end if
					
					break;
				default: break;
			}
			
			
			
		} //end for
		
	} //end of tick
	
	//node add func
	func addNodes( elementType:Int ) {
		var toAddelement:JumpUpElements?; // = JumpUpElements();
		switch(elementType){
			case 0: //0 - Cloud for decoration
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[0] );
				toAddelement!.elementType = JumpUpElements.TYPE_DECORATION;
				toAddelement!.size = CGSizeMake( 94.05 * DeviceGeneral.scrRatioC , 24.4 * DeviceGeneral.scrRatioC );
				toAddelement!.position.x = DeviceGeneral.scrSize!.width + toAddelement!.size.width;
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
				toAddelement!.position.x = DeviceGeneral.scrSize!.width + toAddelement!.size.width;
											/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2);
				toAddelement!.elementSpeed = 1.8; //속도.
				
				break;
			
			case 4:
				//AI Astro (점프 안하고 걸어오는)
				toAddelement = JumpUpElements(); //텍스쳐는 모션으로 정할 것임.
				toAddelement!.size = CGSizeMake( 45 * DeviceGeneral.scrRatioC , 65 * DeviceGeneral.scrRatioC ); //사이즈 = 캐릭터 사이즈
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
				toAddelement!.position.x = DeviceGeneral.scrSize!.width + toAddelement!.size.width;
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2);
				toAddelement!.elementSpeed = 2.8; //속도.

				toAddelement!.motions_walking = gameTexturesAIMoveTexturesArray;
				
				
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
			
		} else {
			gameScore -= 1;
		}
	}
	
	//////// touch evt handler
	//Swift 2용
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let _ = touches.first {
			if (gameFinishedBool == false) { //게임이 진행중일 때만 점프 가능.
				if (characterElement!.jumpFlaggedCount < 2) { //캐릭터 점프횟수 제한
					characterElement!.ySpeed = 10;
					characterElement!.jumpFlaggedCount += 1;
				}
			}
		}
		super.touchesBegan(touches, withEvent:event)
	}
	
} //end of class
