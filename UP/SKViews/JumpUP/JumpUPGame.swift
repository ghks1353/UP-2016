//
//  JumpUPGame.swift
//  UP
//
//  Created by ExFl on 2016. 3. 1..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import AVFoundation;
import SpriteKit;
import UIKit;
import SQLite;

class JumpUPGame:SKScene, UIScrollViewDelegate {
	
	let MATHPI:CGFloat = 3.141592;
	
	//게임 실행 타입 (0= 알람, 1= 메인화면 실행)
	var gameStartupType:Int = 0;
	
	var gameScoreNm:Int = 3; //스코어 자리수. (알람=3, 일반=5)
	
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
	//var buttonAlarmOnSprite:SKSpriteNode = SKSpriteNode( texture: SKTexture( imageNamed: "game_jumpup_assets_time_alram_reset.png" ) );
	
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
	var isGamePaused:Bool = false; //일시정지된 경우
	var isMenuVisible:Bool = true; //알파 효과를 위함
	
	var mapObject:SKNode = SKNode(); //효과, 흔들림 등으로 쓸 맵 오브젝트
	
	var gameStageYAxis:CGFloat = 0; var gameStageYHeight:CGFloat = 0;
	var gameScrollSpeed:Double = 1; //왼쪽으로 흘러가는 게임 스크롤 스피드.
	var additionalGameScrollSpeed:Double = 1; //추가 게임 스크롤 스피드
	
	var gameGravity:Double = 1; //추가 게임 중력.
	
	let gameCloudAddDelayMAX:Int = 60; // original: 60
	var gameCloudDecorationAddDelay:Int = 0; //구름 생성 딜레이
	
	var gameEnemyGenerateDelayMAX:Int = 120; // original: 120
	var gameEnemyGenerateDelay:Int = 0; //장애물 생성 딜레이
	
	var gameCharacterUnlimitedLife:Int = 0; //캐릭터 무적 시간. (있을 경우)
	var gameScreenShakeEventDelay:Int = 0; //화면 흔들림 효과를 위한 딜레이.
	var gameRdmElementNum:Int = 0; //랜덤으로 나오는 장애물 고유 번호. (메모리 절약을 위해 재사용)
	
	var previousEnemyNumber:Int = -1; //이전에 바로 나온 노드 번호
	
	var characterMinYAxis:CGFloat = 0; //캐릭터가 땅에 닿았을 때의 좌표
	
	//Game vars in GAMEMODE.
	var scoreUPDelayMax:Double = 60.0; //스코어 상승 간격
	var scoreUPDelayCurrent:Int = 0; //간격 딜레이
	var scoreUPLevel:Double = 0.0; //현재 게임 레벨
	var scoreNodesRandomArray:Array<Int>?; //스코어모드에서의 적 랜덤 출현 배열
	
	var swipeTouchLayer:SKSpriteNode = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 0,height: 0));
	var touchesLatestPoint:CGPoint = CGPoint(x: 0, y: 0);
	var swipeGestureMoved:CGFloat = 0; //위 혹은 아래로 이동한 양. 순식간에 사라지도록 해야함
	var swipeGestureValid:CGFloat = 50 * DeviceManager.maxScrRatioC; //이동한 양에 대한 허용치. scrRatioC로만 하면 패드에서 힘들어질듯
	
	var maxScoreGameLife:Int = 0; //최대 라이프 (수치상)
	var scoreGameLife:Int = 0; //현재 게임 라이프. (목숨)
	var externalLifeLeft:Int = 0; //추가로 살아날 수 있는 라이프 개수
	
	//피버모드.. 가 아니라 헬게이트 오픈시 바뀌는 배경색
	var hellMode:Bool = false; //일정 레벨 도달시 오픈
	var hellModeBackgroundColours:Array<UIColor> = [
		UPUtils.colorWithHexString("#790000")
		, UPUtils.colorWithHexString("#007700")
		, UPUtils.colorWithHexString("#00006D")
	];
	var hellModeBackgroundCurrentDelay:Int = 0; var hellModeBackgroundCurrentIndex:Int = 0;
	var hellModeScreenReversed:Bool = false; //헬모드 뒤집힘.
	
	//Game node arrays
	var gameNodesArray:Array<JumpUpElements?> = [];
	//Game elements textures (for *optimize*)
	var gameNodesTexturesArray:Array<SKTexture> = [];
	
	//AI Move sktextures (for optimize.)
	var gameTexturesAIMoveTexturesArray:Array<SKTexture> = [];
	var gameTexturesAIJMoveTexturesArray:Array<SKTexture> = [];
	var gameTexturesAIJJumpTexturesArray:Array<SKTexture> = [];
	
	var gameTexturesAIFlyTexturesArray:Array<SKTexture> = [];
	var gameTexturesAIJFlyTexturesArray:Array<SKTexture> = [];
	//AI Effect sktextures array
	var gameTexturesAIEffectsArray:Array<Array<SKTexture>> = [];
	
	//Life nodes
	var gameLifeNodesArray:Array<SKSpriteNode> = []; // 생성해놓고 상태 변화에 따라 그림의 변경을 줌.
	var gameLifeOnTexture:SKTexture = SKTexture(imageNamed: "game_jumpup_assets_life_on.png");
	var gameLifeOffTexture:SKTexture = SKTexture(imageNamed: "game_jumpup_assets_life_off.png");
	
	//Character element
	var characterElement:JumpUpElements?;// = JumpUpElements();
	
	//캐릭터 경고등
	var characterWarningSprite:SKSpriteNode = SKSpriteNode( texture: SKTexture( imageNamed: "game_jumpup_assets_warning.png" ) );
	
	//판정 완화의 정도
	let characterRatherboxX:CGFloat = 140 * DeviceManager.scrRatioC;
	let characterRatherboxY:CGFloat = 125 * DeviceManager.scrRatioC;
	let nodeRatherboxX:CGFloat = 3 * DeviceManager.scrRatioC;
	let nodeRatherboxY:CGFloat = 3 * DeviceManager.scrRatioC;
	
	/////// 통계를 위한 데이터 변수
	
	//아래 시작 종료 시간의 경우, 통계시에는 게임 시작까지 걸린 시간 / 게임 진행 시간으로 재집계
	var stats_gameStartedTimeStamp:Int = 0; //게임 시작 시간
	var stats_gameFinishedTimeStamp:Int = 0; //게임 종료 시간
	
	var stats_gameDiedCount:Int = 0; //맞은 횟수
	var stats_gameIsFailed:Bool = false; //리타이어한 경우
	var stats_gameTouchCount:Int = 0; //전체 터치 횟수
	var stats_gameValidTouchCount:Int = 0; //유효 터치 횟수
	//var stats_gameToBackgroundCount:Int = 0; //게임 중 백그라운드로 간 횟수
	
	//////////////////////////UI Menu
	var uiContents:GeneralMenuUI?;
	
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
		
		//맵오브젝트 생성
		mapObject.position = CGPointMake(0, 0);
		self.addChild(mapObject);
		
		//게임 백그라운드 화면 추가
		backgroundCoverImage = SKSpriteNode( texture: backgroundCoverImageTexture );
		backgroundCoverImage!.size = CGSizeMake( self.view!.frame.width, 226.95 * DeviceManager.scrRatioC );
		backgroundCoverImage!.position.x = self.view!.frame.width / 2; backgroundCoverImage!.position.y = self.view!.frame.height / 2;
		mapObject.addChild(backgroundCoverImage!);
		
		//실제 게임 스테이지 y값
		gameStageYAxis = backgroundCoverImage!.position.y + (backgroundCoverImage!.size.height / 2);
		gameStageYHeight = backgroundCoverImage!.frame.height;
		
		//게임 팁 표시할 텍스트 추가
		gameTipTextField.textColor = UIColor.whiteColor();
		gameTipTextField.frame = CGRectMake(
			12 * DeviceManager.scrRatioC,
			gameStageYAxis + (48 * DeviceManager.scrRatioC),
			self.view!.frame.width - (12 * DeviceManager.scrRatioC),
			24 * DeviceManager.scrRatioC
		);
		gameTipTextField.text = "테스트 텍스트";
		gameTipTextField.textAlignment = .Center;
		gameTipTextField.font = UIFont.systemFontOfSize(18); //절대 크기로 사용
		self.view!.addSubview(gameTipTextField);
		
		//영상을 위해 잠시 가림
		gameTipTextField.hidden = true;
		
		//time 혹은 score 추가 (실행 타입에 따라 바뀜)
		gameScoreStr = "";
		
		//컴포넌트 위치조정을 위한 값
		var movPositionY:CGFloat = 0;
		var gameScoreMovPositionY:CGFloat = 0;
		
		if (gameStartupType == 0) {
			//time
			gameScoreTitleImageTexture = SKTexture( imageNamed: "game_jumpup_assets_time_time.png" );
			gameScoreTitleImage = SKSpriteNode( texture: gameScoreTitleImageTexture );
			
			if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
				//iPhone 전용 사이즈
				gameScoreTitleImage!.size = CGSizeMake( 87.65 * DeviceManager.scrRatioC, 38.35 * DeviceManager.scrRatioC );
				
				//4/4s의 경우, 세로길이가 부족하므로 기존 아이폰과 다른 y위치 지정
				if (DeviceManager.scrSize?.height <= 480.0) {
					//4/4s fallback
					movPositionY = self.view!.frame.height - (63 * DeviceManager.scrRatioC);
				} else {
					movPositionY = self.view!.frame.height - (96 * DeviceManager.scrRatioC);
				}
				
				gameScoreMovPositionY = movPositionY - (72 * DeviceManager.scrRatioC);
			} else {
				//iPad 전용 사이즈 (고정)
				gameScoreTitleImage!.size = CGSizeMake( 122.15, 53.35 );
				movPositionY = self.view!.frame.height - (52 * DeviceManager.scrRatioC);
				gameScoreMovPositionY = movPositionY - 94;
			}
			
			gameScore = gameAlarmFirstGoalTime; //초반 120초 부여
			addCountdownTimerForAlarm();
		} else {
			//score
			gameScoreTitleImageTexture = SKTexture( imageNamed: "game_jumpup_assets_time_score.png" );
			gameScoreTitleImage = SKSpriteNode( texture: gameScoreTitleImageTexture );
			
			if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
				//iPhone 전용 사이즈
				gameScoreTitleImage!.size = CGSizeMake( 135.15 * DeviceManager.scrRatioC, 27.45 * DeviceManager.scrRatioC );
				
				//4/4s의 경우, 세로길이가 부족하므로 기존 아이폰과 다른 y위치 지정
				if (DeviceManager.scrSize?.height <= 480.0) {
					//4/4s fallback
					movPositionY = self.view!.frame.height - (63 * DeviceManager.scrRatioC);
				} else {
					movPositionY = self.view!.frame.height - (96 * DeviceManager.scrRatioC);
				}
				
				gameScoreMovPositionY = movPositionY - (72 * DeviceManager.scrRatioC);
			} else {
				//iPad 전용 사이즈 (고정)
				gameScoreTitleImage!.size = CGSizeMake( 135.15, 27.45 );
				movPositionY = self.view!.frame.height - (52 * DeviceManager.scrRatioC);
				gameScoreMovPositionY = movPositionY - 94;
			}
			
			gameScore = 0; maxScoreGameLife = 3; //기본 최대 라이프
			scoreGameLife = maxScoreGameLife;
			externalLifeLeft = 1; //연장 1회
			
			//// 라이프 구성
			for i:Int in 0 ..< maxScoreGameLife {
				// 최대 라이프만큼 슬롯 만들기
				let lifeNode:SKSpriteNode = SKSpriteNode( texture: gameLifeOnTexture );
				let xIndexCalcuated:CGFloat = ((CGFloat(i)-1) * ((48+22 /* 22: margin */) * DeviceManager.maxScrRatioC));
				lifeNode.size = CGSizeMake( 48 * DeviceManager.maxScrRatioC, 84 * DeviceManager.maxScrRatioC );
				
				lifeNode.position = CGPointMake(
					(self.view!.frame.width / 2 - xIndexCalcuated)
					, gameStageYAxis - gameStageYHeight - (48 + 42 + 13) * DeviceManager.maxScrRatioC );
				
				gameLifeNodesArray += [lifeNode];
				self.addChild( lifeNode );
			}
		} //게임모드 / 알람모드 구분 끝
		
		
		gameScoreTitleImage!.position.x = self.view!.frame.width / 2;
		self.addChild(gameScoreTitleImage!);
		
		let moveEffect = SKTMoveEffect(node: gameScoreTitleImage!, duration: 0.5,
			startPosition: CGPointMake( self.view!.frame.width / 2, self.view!.frame.height + gameScoreTitleImage!.frame.height / 2),
			endPosition: CGPointMake( self.view!.frame.width / 2, movPositionY));
		moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut;
		gameScoreTitleImage!.runAction(SKAction.actionWithEffect(moveEffect));
		
		//time / score에 대한 데이터 처리
		gameScoreNm = (gameStartupType == 0 ? 3 : 5);
		
		if (gameNumberTexturesArray.count == 0) {
			for i:Int in 0 ..< 10 {
				gameNumberTexturesArray += [ SKTexture( imageNamed: SkinManager.getDefaultAssetPresets() + String(i) + ".png" ) ];
			} //0~9에 대한 숫자 데이터 텍스쳐
			for i:Int in 0 ..< gameScoreNm {
				gameNumberSpriteNodesArray += [ SKSpriteNode( texture: gameNumberTexturesArray[0] ) ];
				if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) { //iPhone 전용 크기 (가변)
					gameNumberSpriteNodesArray[i].size = CGSizeMake(50 * DeviceManager.scrRatioC , 70 * DeviceManager.scrRatioC);
					gameNumberSpriteNodesArray[i].position.y = movPositionY - (120 * DeviceManager.scrRatioC);
				} else { //iPad 전용 크기 (고정)
					gameNumberSpriteNodesArray[i].size = CGSizeMake(69.7, 97.4);
					gameNumberSpriteNodesArray[i].position.y = movPositionY - 120;
				}
				
				gameNumberSpriteNodesArray[i].position.x =
					self.view!.frame.width / 2 - (CGFloat( (gameStartupType == 0 ? i : i - 1) ) * (gameNumberSpriteNodesArray[i].size.width + 12 * DeviceManager.maxScrRatioC))
					/* align to center */
					+ ((gameNumberSpriteNodesArray[i].size.width + 12 * DeviceManager.maxScrRatioC));
				
				self.addChild( gameNumberSpriteNodesArray[i] );
				
				//숫자 밑에서 위로 올라오는 효과 주기
				gameNumberSpriteNodesArray[i].alpha = 0;
				let moveEffect = SKTMoveEffect(node: gameNumberSpriteNodesArray[i], duration: 0.5 ,
					startPosition: CGPointMake( gameNumberSpriteNodesArray[i].position.x, movPositionY - (120 * DeviceManager.scrRatioC)),
					endPosition: CGPointMake( gameNumberSpriteNodesArray[i].position.x, gameScoreMovPositionY));
				moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut;
				//gameNumberSpriteNodesArray[i].runAction();
				gameNumberSpriteNodesArray[i].runAction(
					SKAction.group( [
						SKAction.afterDelay(Double((gameStartupType == 0 ? 2 : 4) - i) * 0.1, performAction: SKAction.actionWithEffect(moveEffect)),
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
					7 - trap (fly)
				*/
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_1.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_trap.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_box.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_box2.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_2.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_3.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_cloud_4.png" ),
				SKTexture( imageNamed: "game_jumpup_assets_time_trap_2.png" )
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
		
		characterMinYAxis = gameStageYAxis - gameStageYHeight + (32 * DeviceManager.scrRatioC);
		
		//캐릭터 추가
		characterElement = JumpUpElements(); //60, 70이 원래 크기였음
		characterElement!.size = CGSizeMake(300 * DeviceManager.scrRatioC, 300 * DeviceManager.scrRatioC); //Create astro size
		characterElement!.position.x = 64 * DeviceManager.scrRatioC; //캐릭터의 왼쪽. 초기위치 잡음
		characterElement!.position.y = characterMinYAxis; //gameStageYAxis - gameStageYHeight + (characterElement!.size.height / 2); // * DeviceManager.scrRatioC;
		
		//캐릭터 경고등 추가
		characterWarningSprite.size = CGSizeMake( 33.6 * DeviceManager.scrRatioC, 30.8 * DeviceManager.scrRatioC );
		characterWarningSprite.position.x = characterElement!.position.x;
		mapObject.addChild(characterWarningSprite); characterWarningSprite.hidden = true;
		
		//////// Make textures for Character (Player)
		if (characterElement!.motions_walking.count == 0) {
			for i:Int in 0 ..< 6 {
				characterElement!.motions_walking += [
					SKTexture( imageNamed: "game_jumpup_astro_" + SkinManager.getSelectedSkinCharacter() + "_move_" + String(i) + ".png" )
				]; //Character motions preload
				(characterElement!.motions_walking[i] as SKTexture).preloadWithCompletionHandler({});
			}
		} //walking motion end for *character*
		if (characterElement!.motions_jumping.count == 0) {
			for i:Int in 0 ..< 8 {
				characterElement!.motions_jumping += [
					SKTexture( imageNamed: "game_jumpup_astro_" + SkinManager.getSelectedSkinCharacter() + "_jump_" + String(i) + ".png" )
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
		if (gameTexturesAIFlyTexturesArray.count == 0) {
			for i:Int in 0 ..< 6 {
				gameTexturesAIFlyTexturesArray += [
					SKTexture( imageNamed: "game_jump_ai_astro_fly" + String(i) + ".png" )
				];
				(gameTexturesAIFlyTexturesArray[i] as SKTexture).preloadWithCompletionHandler({});
			}
		} //flying motion end for *ai fly*
		if (gameTexturesAIJFlyTexturesArray.count == 0) {
			for i:Int in 0 ..< 6 {
				gameTexturesAIJFlyTexturesArray += [
					SKTexture( imageNamed: "game_jump_ai_j_astro_fly" + String(i) + ".png" )
				];
				(gameTexturesAIJFlyTexturesArray[i] as SKTexture).preloadWithCompletionHandler({});
			}
		} //flying motion end for *ai_j fly*
		
		//Character to front
		characterElement!.zPosition = 2;
		mapObject.addChild(characterElement!);
		
		// 일시정지 / 재생 혹은 버그 (나와도 타이머 흐름) 방지를 위한 코드
		let nCenter = NSNotificationCenter.defaultCenter();
		nCenter.addObserver(self, selector: #selector(JumpUPGame.appEnteredToBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil);
		nCenter.addObserver(self, selector: #selector(JumpUPGame.appEnteredToForeground), name: UIApplicationDidBecomeActiveNotification, object: nil);
		
		
		//버튼 배치
		if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
			//아이폰 (상대크기)
			buttonRetireSprite.size = CGSizeMake( 242.05 * DeviceManager.scrRatioC, 70.75 * DeviceManager.scrRatioC );
			if (DeviceManager.scrSize!.height > 480.0) { //iPhone 4, 4s 이외
				buttonYAxis = gameStageYAxis - gameStageYHeight - (128 * DeviceManager.scrRatioC);
			} else { //iPhone 4시리즈
				buttonYAxis = gameStageYAxis - gameStageYHeight - (86 * DeviceManager.scrRatioC);
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
		buttonRetireSprite.zPosition = 3;
		
		//알람끄기 버튼.
		buttonAlarmOffSprite.size = buttonRetireSprite.size;
		buttonAlarmOffSprite.position.x = self.view!.frame.width / 2;
		buttonAlarmOffSprite.position.y = -buttonAlarmOffSprite.size.height / 2; //화면 밖에 배치
		buttonAlarmOffSprite.alpha = 0;
		self.addChild(buttonAlarmOffSprite);
		buttonAlarmOffSprite.name = "button_alarm_off";
		buttonAlarmOffSprite.zPosition = 3;
		
		//터치 레이어 만들기 (스와이프)
		swipeTouchLayer.name = "touchlayer";
		swipeTouchLayer.size = CGSizeMake( self.view!.frame.width, self.view!.frame.height );
		swipeTouchLayer.position = CGPointMake( self.view!.frame.width / 2 , self.view!.frame.height / 2);
		swipeTouchLayer.alpha = 0;
		swipeTouchLayer.zPosition = 2;
		self.addChild(swipeTouchLayer);
		
		/////////// UI 구성 (메뉴, 가이드, 게임오버 등)
		
		//알람이 아닌 경우만 추가함
		if (gameStartupType == 1) {
			uiContents = GeneralMenuUI( frame: CGRectMake(0, 0, self.view!.frame.width, self.view!.frame.height ) );
			uiContents!.userInteractionEnabled = true;
			
			uiContents!.setGame(0); //jumpup
			uiContents!.initUI( uiContents!.frame );
			self.view!.addSubview(uiContents!);
			
			//set callback functions
			uiContents!.pauseResumeBtnCallback = togglePause;
			uiContents!.gameForceStopCallback = gameForceStopCallb;
			uiContents!.gameOverCallback = gameOverCallb;
			uiContents!.restartCallback = gameRestartCallb;
		}
		
		
		
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
			gameScore = max(gameAlarmFirstGoalTime, gameScore); //남은 시간이 더 크면 유지
			gameRetireTimeCount = gameRetireTimeCount / 2; //리타이어 수작일수도 있으니 이거도 조절함
			AlarmRingView.selfView!.userAsleepCount += 1;
			//stats_gameToBackgroundCount += 1;
			
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
		if (isGamePaused == true) {
			return; //게임 일시정지 된 경우 틱 정지
		}
		
		//제스처 처리
		if (abs(swipeGestureMoved) > 0 && gameStartupType == 1) {
			if (abs(swipeGestureMoved) > swipeGestureValid) {
				if (swipeGestureMoved > 0) {
					// 아래로 스와이프
					
					//급강하 (체공 중일때만 가능)
					if (characterElement!.jumpFlaggedCount != 0 && !characterElement!.shadow_on_air) {
						characterElement!.ySpeed = -20;
						// 그림자 효과
						characterElement!.shadow_on_air = true;
						characterElement!.shadow_on_frame = 0;
						characterElement!.shadow_per_frame_current = 0;
					}
					
				} else {
					//위로 스와이프
					
					//슈퍼점프 (스와이프로)
					if (characterElement!.jumpFlaggedCount < 2) { //점프 가능 횟수가 남아있을 경우
						characterElement!.ySpeed = 16 * max(1, CGFloat(gameGravity / 1.25));
						characterElement!.jumpFlaggedCount += 2;
						
						// 체공중 그림자 효과
						characterElement!.shadow_on_air = false;
						characterElement!.shadow_on_frame = 30;
						characterElement!.shadow_per_frame_current = 0;
					}
					
				}
			}
			
			swipeGestureMoved *= 0.75;
			if (abs(swipeGestureMoved) < 0.1) {
				swipeGestureMoved = 0;
			}
		} //////// 제스처 처리 끝
		
		//화면 흔들림 효과
		let defWid:CGFloat = (mapObject.zRotation / MATHPI) * (self.view!.frame.width);
		if (gameScreenShakeEventDelay > 0) {
			if (gameScreenShakeEventDelay % 2 == 0) {
				
				mapObject.position.x =
					( mapObject.position.x < defWid ? (12 * (CGFloat(gameScreenShakeEventDelay) / 60)) : -(12 * (CGFloat(gameScreenShakeEventDelay) / 60)) ) * DeviceManager.scrRatioC;
				mapObject.position.x += defWid;
			}
			gameScreenShakeEventDelay -= 1;
		} else {
			gameScreenShakeEventDelay = 0;
			mapObject.position.x = defWid;
		}
		mapObject.position.y = (mapObject.zRotation / MATHPI) * (self.view!.frame.height);
		
		//화면 회전 효과
		if ( hellModeScreenReversed == false ) {
			if (mapObject.zRotation > 0) {
				mapObject.zRotation -= MATHPI / 16;
				if (mapObject.zRotation <= 0) {
					mapObject.zRotation = 0;
				}
			}
		} else {
			if (mapObject.zRotation < MATHPI) {
				mapObject.zRotation += MATHPI / 16;
				if (mapObject.zRotation >= MATHPI) {
					mapObject.zRotation = MATHPI;
				}
			}
		}
		
		//라이프 인디케이터 갱신
		if (maxScoreGameLife > 0) {
			//MAX라이프가 있을 때.
			for i:Int in 0 ..< gameLifeNodesArray.count {
				if ((scoreGameLife-1) >= i) { //라이프 있음 체크
					if (gameLifeNodesArray[(gameLifeNodesArray.count-1) - i].texture == gameLifeOffTexture) {
						gameLifeNodesArray[(gameLifeNodesArray.count-1) - i].texture = gameLifeOnTexture;
					}
				} else { //라이프 없음 체크
					if (gameLifeNodesArray[(gameLifeNodesArray.count-1) - i].texture == gameLifeOnTexture) {
						gameLifeNodesArray[(gameLifeNodesArray.count-1) - i].texture = gameLifeOffTexture;
					}
				} //라이프 체크 끝
			} //반복문 종료
		} //라이프 인디케이터 갱신 끝.
		
		//게임모드일 시 스코어 상승과 레벨링
		if (gameStartupType == 1) {
			
			//헬모드 효과 (..)
			if (hellMode == true) {
				if (hellModeBackgroundCurrentDelay <= 0) {
					self.backgroundColor = hellModeBackgroundColours[hellModeBackgroundCurrentIndex];
					hellModeBackgroundCurrentIndex += 1;
					if (hellModeBackgroundCurrentIndex >= hellModeBackgroundColours.count) {
						hellModeBackgroundCurrentIndex = 0;
					}
					hellModeBackgroundCurrentDelay = 8;
				} else {
					hellModeBackgroundCurrentDelay -= 1;
				}
			} //헬모드 효과 끝
			
			if (scoreUPDelayCurrent <= 0) {
				scoreUPDelayCurrent = Int(round(scoreUPDelayMax));
				
				if (scoreUPLevel > 10) {
					gameScore += min(9, Int(round(scoreUPLevel / 5)));
				} else {
					gameScore += 1;
				}
				
				if (gameScore >= 10000 && hellMode == false) {
					//헬모드 트리거 조건: 게임 점수 1만점 이상
					hellMode = true;
				} else {
					//헬모드 중일 때
					if (gameScore >= 50000 && backgroundCoverImage!.alpha >= 1) {
						//가운데도 없애버려.
						backgroundCoverImage!.alpha = 0.05; //알파를 뼈대로 남김
					}
				}
				
				scoreUPDelayMax -= 0.5;
				scoreUPDelayMax = max(max(0, 10 - scoreUPLevel), scoreUPDelayMax);
				
				print("Current level:", scoreUPLevel, ",Scroll (x):", additionalGameScrollSpeed, ", Max delay:",
				      max(40, gameEnemyGenerateDelayMAX - Int(round(scoreUPLevel * 12))));
				
			} else {
				scoreUPDelayCurrent -= 1;
			}
			//레벨을 일정 주기로 높임
			scoreUPLevel += 0.0007;
			//스크롤 속도 높임
			if (hellMode == true) {
				additionalGameScrollSpeed = 3.2; //헬모드 속도 고정
			} else if ( additionalGameScrollSpeed < 2.5) { //조금 빠르게 올림
				additionalGameScrollSpeed = min(3, 1.2 + (scoreUPLevel / 4));
			} else { //천천히 올림
				additionalGameScrollSpeed = min(3, additionalGameScrollSpeed + 0.0001 );
			}
			//약간씩 중력 늘림 (스크롤 속도 비례)
			gameGravity = max(1, additionalGameScrollSpeed / 2);
		} // 스코어 관련 끝
		
		//Render time(or score)
		gameScoreStr = String(gameScore);
		//Render text
		for i:Int in 0 ..< gameScoreNm {
			gameNumberSpriteNodesArray[i].texture =
				gameScoreStr.characters.count < (i + 1) ? gameNumberTexturesArray[0] :
					gameNumberTexturesArray[ Int(gameScoreStr[ gameScoreStr.characters.count - (i + 1) ])! ];
			if (i > 0) { //첫번째 자리수는 무조건 알파가 1.
				gameNumberSpriteNodesArray[i].alpha = gameScoreStr.characters.count < (i + 1) ? (max(0.5, gameNumberSpriteNodesArray[i].alpha - 0.04)) : (min(1.0, gameNumberSpriteNodesArray[i].alpha + 0.04));
			}
		}
		
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
			gameRdmElementNum = 1 + Int(arc4random_uniform( 5 )); //0번은 데코용 구름이라 제외함
			let rdmVars:Float = Float(arc4random()) / Float(UINT32_MAX);
			//딜레이 설정 및 노드 생성
			switch(gameStartupType) {
				case 0: //알람 게임
					gameRdmElementNum = 1 + Int(arc4random_uniform( 5 ));
					//가시나 트랩이 나올 때, 50초 미만으로 남았을 때, 알람으로 켜졌을 때, 약 40% 미만의 확률로 발동
					if ((gameRdmElementNum == 1 || gameRdmElementNum == 2) && gameScore < gameLevelAverageTime) {
						if (rdmVars <= 0.5) {
							self.addNodes( 6 ); //구름
							self.addNodes( 1 + Int(arc4random_uniform( 2 ))); //가시 + 박스
						} else if (rdmVars <= 0.3) {
							self.addNodes( 3 + Int(arc4random_uniform( 3 )));
						} else {
							self.addNodes( gameRdmElementNum );
						}
					} else {
						self.addNodes( gameRdmElementNum );
					}
					
					//딜레이 최대치를 시간이 갈때마다 줄임 (알람으로 켜졌을 때.)
					gameEnemyGenerateDelay = gameEnemyGenerateDelayMAX - Int((gameAlarmFirstGoalTime - gameScore) / 4);
					break;
				case 1: //직접 킨 게임
					
					if (hellMode == true) {
						//헬모드가 켜진 경우, 가끔씩 화면을 돌림
						if (Float(arc4random()) / Float(UINT32_MAX) < 0.1) { //10% 확률로 돌림
							
							//180도 플랩
							hellModeScreenReversed = !hellModeScreenReversed;
						}
						
					} //헬모드 처리 끝
					
					if (scoreUPLevel > 9) { //////////////////// 9레벨 등장 패턴
						
						switch(previousEnemyNumber) {
							case 11:
								gameRdmElementNum = 0;
								
								//뒤에서 나오는걸 생성
								self.addNodes( 11 );
								
								characterWarningSprite.hidden = true;
								break;
							default:
								
								if (rdmVars >= 0.95) { //낮은확률로 다음 턴에 뒤로 달리는 로봇 생성.
									//고로 이번턴엔 점프를 안 할만한걸 생성
									scoreNodesRandomArray = [ 9 ];
									gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
									self.addNodes( gameRdmElementNum );
									gameRdmElementNum = 11; // 점등 해제를 위해
									
									//경고등 점등
									characterWarningSprite.hidden = false;
								} else if (rdmVars <= 0.05) { //0.5/10 확률로 떨어지는 구름 생성
									gameRdmElementNum = 7; scoreNodesRandomArray = [ 1, 2, 3 ];
									gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
									self.addNodes( 7 ); //위에 고정되었다 떨어지는 구름
									self.addNodes( gameRdmElementNum ); //작은 박스나 가시로만 구성
								} else if (previousEnemyNumber == 7) {
									//이전에 바로 구름이 나온 경우, 로봇은 소환하지 말자
									scoreNodesRandomArray = [ 1, 2, 3, 9 ];
									gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
									
									self.addNodes( gameRdmElementNum ); //3단 박스 + 날아다니는 로봇
								} else {
									scoreNodesRandomArray = [ 1, 2, 3, 4, 5, 8, 9, 10 ]; //9, 10: 플라잉 로봇. 떨어지는 놈까지
									gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
									self.addNodes( gameRdmElementNum );
								}
								
								break;
						}
						
						
						////////// 9레벨 끝
					} else if (scoreUPLevel > 7) { //////////////////// 7레벨 등장 패턴
						
						if (rdmVars <= 0.05) { //0.5/10 확률로 떨어지는 구름 생성
							gameRdmElementNum = 7; scoreNodesRandomArray = [ 1, 2, 3 ];
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
							self.addNodes( 7 ); //위에 고정되었다 떨어지는 구름
							self.addNodes( gameRdmElementNum ); //작은 박스나 가시로만 구성
						} else if (previousEnemyNumber == 7) {
							//이전에 바로 구름이 나온 경우, 로봇은 소환하지 말자
							scoreNodesRandomArray = [ 1, 2, 3, 9 ];
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
							
							self.addNodes( gameRdmElementNum ); //3단 박스 + 날아다니는 로봇
						} else {
							scoreNodesRandomArray = [ 1, 2, 3, 4, 5, 8, 9 ]; //9 : 플라잉 로봇
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
							self.addNodes( gameRdmElementNum );
						}
						
						////////// 7레벨 끝
					} else if (scoreUPLevel > 4) { //////////////////// 4레벨 등장 패턴
						if (rdmVars <= 0.1) { //1/10 확률로 떨어지는 구름 생성
							gameRdmElementNum = 7;
							
							scoreNodesRandomArray = [ 1, 2, 3 ]; //올라가는 가시가 나오면 안될듯. 3단 박스까지만
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
							
							self.addNodes( 7 ); //위에 고정되었다 떨어지는 구름
							self.addNodes( gameRdmElementNum ); //작은 박스나 가시로만 구성
							
						} else if (previousEnemyNumber == 7) {
							//이전에 바로 구름이 나온 경우, 로봇은 소환하지 말자
							self.addNodes( 1 + Int(arc4random_uniform( 3 ))); //3단 박스까지 생성함.
						} else {
							scoreNodesRandomArray = [ 1, 2, 3, 4, 5 ];
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
							self.addNodes( gameRdmElementNum );
						}
						////////// 4레벨 끝
					} else { //////////////////// 일반 패턴
						scoreNodesRandomArray = [ 1, 2, 3, 4, 5 ];
						gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ];
						self.addNodes( gameRdmElementNum );
					}
					
					gameEnemyGenerateDelay = max(40, gameEnemyGenerateDelayMAX - Int(round(scoreUPLevel * 12)));
					//스코어 레벨에 따라 관리
					//해보니까 빠른속도에 50이하로 내려가긴 힘듬
					
					scoreNodesRandomArray = nil; //GC
					break;
				default: break;
			} //end switch
			
			previousEnemyNumber = gameRdmElementNum;
			
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
					characterElement!.motions_frame_delay_left = max(1, 5 - (Int(round(additionalGameScrollSpeed)) - 1)); //per 5f
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
		characterElement!.position.y += (characterElement!.ySpeed / 2) * DeviceManager.scrRatioC;
							/// 1을 더하는 이유는 기종마다 미세한 픽셀 차이로 인해 모션이 안나오는 버그가 있기 때문임
		if (characterElement!.position.y <= 1 + characterMinYAxis) {
			characterElement!.position.y = characterMinYAxis;
			characterElement!.ySpeed = 0;
			characterElement!.changeMotion(0); //walking motion
			characterElement!.jumpFlaggedCount = 0; //점프횟수 초기화
			characterElement!.shadow_on_air = false; //체공 쉐도우 있으면 해제.
		} else {
			characterElement!.ySpeed -= 0.5 * CGFloat(gameGravity);
			characterElement!.changeMotion(1); //jumping motion
		}
		
		//Character-warning queue
		if (characterWarningSprite.hidden == false) {
			characterWarningSprite.position.y = characterElement!.position.y + characterElement!.size.height / 8 + 18 * DeviceManager.scrRatioC;
		}
		
		//캐릭터 무적 처리
		if (gameCharacterUnlimitedLife > 0) {
			gameCharacterUnlimitedLife -= 1;
			
			characterElement!.alpha = characterElement!.alpha == 0 ? 1 : 0;
			
		} else if (gameCharacterUnlimitedLife <= 0) {
			characterElement!.alpha = 1;
		} //end if
		
		//캐릭터 Shadow효과 처리
		if ( characterElement!.shadow_on_air == true || characterElement!.shadow_on_frame > 0 ) {
			if (characterElement!.shadow_per_frame_current <= 0) {
				//Shadow 추가
				addNodes(10001, posX: 0, posY: 0, targetElement: characterElement!);
				characterElement!.shadow_per_frame_current = characterElement!.shadow_per_frame;
			} else {
				characterElement!.shadow_per_frame_current -= 1;
			}
			characterElement!.shadow_on_frame -= 1;
			if (characterElement!.shadow_on_frame <= 0) {
				characterElement!.shadow_on_frame = 0;
			}
		}
		
		//Scroll nodes + Motion queue (w/o character)
		for i:Int in 0 ..< gameNodesArray.count {
			if (i >= gameNodesArray.count) {
				break;
			}
			
			//위치관련
			//print("Checking element type - ", gameNodesArray[i]!.elementType, JumpUpElements.TYPE_EFFECT);
			switch(gameNodesArray[i]!.elementType) {
				case JumpUpElements.TYPE_DECORATION: // ... cloud?
					gameNodesArray[i]!.position.x -= CGFloat(gameScrollSpeed * gameNodesArray[i]!.elementSpeed * additionalGameScrollSpeed) * DeviceManager.scrRatioC;
					break;
				case JumpUpElements.TYPE_STATIC_ENEMY, JumpUpElements.TYPE_DYNAMIC_ENEMY: // 고정형 장애물, 움직
					gameNodesArray[i]!.position.x -= CGFloat(gameScrollSpeed * gameNodesArray[i]!.elementSpeed * additionalGameScrollSpeed) * DeviceManager.scrRatioC;
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
			switch(gameNodesArray[i]!.elementFlag) {
				case 7: //화면 오른쪽에서 없어짐
					
					if (gameNodesArray[i]!.position.x > self.view!.frame.width + gameNodesArray[i]!.size.width / 2) {
						gameNodesArray[i]!.removeFromParent(); gameNodesArray[i] = nil;
						gameNodesArray.removeAtIndex(i);
						continue;
					} //end of remove
					
					break;
				default: //화면 왼쪽에서 없어짐
					if (gameNodesArray[i]!.position.x < -gameNodesArray[i]!.size.width / 2) { //remove
						gameNodesArray[i]!.removeFromParent(); gameNodesArray[i] = nil;
						gameNodesArray.removeAtIndex(i);
						continue;
					} //end of remove
				break;
			}
			
			
			//do motion queue
			switch(gameNodesArray[i]!.elementType) {
				case JumpUpElements.TYPE_DYNAMIC_ENEMY, JumpUpElements.TYPE_EFFECT:
					if (gameNodesArray[i]!.motions_frame_delay_left <= 0) {
						gameNodesArray[i]!.motions_current_frame += 1;
						switch( gameNodesArray[i]!.motions_current ) {
							case 0: //walking motion
								gameNodesArray[i]!.texture = gameNodesArray[i]!.motions_walking[gameNodesArray[i]!.motions_current_frame];
								switch(gameNodesArray[i]!.elementFlag) {
									case 7: //반대로 달림. 엄청 빠름.
										gameNodesArray[i]!.motions_frame_delay_left = 1; //per 1f
										break;
									default: //일반 노드
										gameNodesArray[i]!.motions_frame_delay_left = max(1, 5 - (Int(round(additionalGameScrollSpeed)) - 1)); //per 5f
										break;
								}
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
					break;
				case JumpUpElements.TYPE_SHADOW:
					//쉐도우 계열은 그냥 알파 줄이다 끝나게
					gameNodesArray[i]!.alpha -= 0.05;
					if (gameNodesArray[i]!.alpha <= 0) {
						gameNodesArray[i]!.removeFromParent(); gameNodesArray[i] = nil;
						gameNodesArray.removeAtIndex(i);
						continue;
					}
					break;
				default: break;
			} //Type분류 애니메이션 끝
			
			//Character coll detection check
			switch(gameNodesArray[i]!.elementType) {
				case JumpUpElements.TYPE_STATIC_ENEMY, JumpUpElements.TYPE_DYNAMIC_ENEMY: // 고정형 장애물 및 움직 장애물
					
					//적 점프 queue
					switch(gameNodesArray[i]!.elementFlag) {
						case 2, 3, 6 ,8: break; //물리 무시
						default:
							gameNodesArray[i]!.position.y += (gameNodesArray[i]!.ySpeed / 2) * DeviceManager.scrRatioC;
							if (gameNodesArray[i]!.position.y <= 1 + gameStageYAxis - gameStageYHeight + (gameNodesArray[i]!.size.height / 2)) {
								gameNodesArray[i]!.position.y = gameStageYAxis - gameStageYHeight + (gameNodesArray[i]!.size.height / 2);
								gameNodesArray[i]!.ySpeed = 0;
								gameNodesArray[i]!.changeMotion(0); //walking motion
								gameNodesArray[i]!.jumpFlaggedCount = 0; //점프횟수 초기화
							} else {
								gameNodesArray[i]!.ySpeed -= 0.5 * CGFloat(gameGravity);
								gameNodesArray[i]!.changeMotion(1); //jumping motion
							}
							break;
					}
					
					//판정 완화용 Rect.
					let nodeTmpRect:CGRect = CGRect(
						x:
						(gameNodesArray[i]!.position.x - gameNodesArray[i]!.size.width / 2) + nodeRatherboxX ,
						y:
						(gameNodesArray[i]!.position.y - gameNodesArray[i]!.size.height / 2) + nodeRatherboxY ,
						width: gameNodesArray[i]!.size.width - (nodeRatherboxX * 2),
						height: max(6 * DeviceManager.scrRatioC, gameNodesArray[i]!.size.height - (nodeRatherboxY * 2))
					);
					
					if ( //캐릭터 - 적간 충돌판정 (조금 완화 함.)
						/*characterElement!.containsPoint( gameNodesArray[i]!.position ) ||*/
							nodeTmpRect.contains( CGPoint( x: (characterElement!.position.x - characterElement!.size.width / 2) + characterRatherboxX, y: (characterElement!.position.y - characterElement!.size.height / 2) + characterRatherboxY  ) ) ||
							nodeTmpRect.contains( CGPoint( x: (characterElement!.position.x + characterElement!.size.width / 2) - characterRatherboxX, y: (characterElement!.position.y - characterElement!.size.height / 2) + characterRatherboxY  ) ) ||
							
							nodeTmpRect.contains( CGPoint( x: (characterElement!.position.x - characterElement!.size.width / 2) + characterRatherboxX, y: (characterElement!.position.y + characterElement!.size.height / 2) - characterRatherboxY  ) ) ||
							nodeTmpRect.contains( CGPoint( x: (characterElement!.position.x + characterElement!.size.width / 2) - characterRatherboxX, y: (characterElement!.position.y + characterElement!.size.height / 2) - characterRatherboxY  ) )
						) {
						
							if (gameCharacterUnlimitedLife == 0) {
								print("Character collision");
								gameCharacterUnlimitedLife = 120; //무적시간 부여
								gameScreenShakeEventDelay = 60; //화면 흔들림 효과
								
								//진동
								AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate));
								
								//통계값 추가
								stats_gameDiedCount += 1;
								
								//scoreGameLife
								switch(gameStartupType) {
									case 0: //알람으로 켜진 경우, 최대 설정된 시간까지 커지도록 시간 추가
										if (gameScore <= gameLevelAverageTime) {
											gameScore = min( gameScore + 4, gameTimerMaxTime);
										} else {
											gameScore = min( gameScore + 6, gameTimerMaxTime);
										}
										break;
									case 1: //게임 모드로 켜짐
										scoreGameLife -= 1;
										if (scoreGameLife <= 0) {
											gameOverRutine(); //라이프가 없으면 게임오버.
											return;
										}
										break;
									default: break;
								}
							} //end if
					} //end if
					
					break;
				default: break;
			} //end switch
			
			//특수한 적의 경우 특별한 경우 점프를 하도록 만듬. 아래 적은 점프하느 ㄴ적의 경우.
			//점프할거라는 신호를 먼저 주고 점프해야 함. addNodes( 10000 );
			switch(gameNodesArray[i]!.elementFlag) {
				case 1: //점프하는 적
					if (gameNodesArray[i]!.elementTickFlag == 0
						&& gameNodesArray[i]!.position.x < (260 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.65))) * DeviceManager.scrRatioC ) {
						addNodes( 10000, posX: gameNodesArray[i]!.position.x, posY: gameNodesArray[i]!.position.y, targetElement: gameNodesArray[i] );
						gameNodesArray[i]!.elementTickFlag = 1;
					} else if (gameNodesArray[i]!.elementTickFlag == 1
						&& gameNodesArray[i]!.position.x < (160 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.85))) * DeviceManager.scrRatioC ) {
						gameNodesArray[i]!.ySpeed = 14 * max(1, CGFloat(gameGravity / 1.3));
						gameNodesArray[i]!.elementTickFlag = 2;
					}
					break;
				case 2: break; //물리 영향 없음
				case 3: //일정 좌표 이후 형태가 변경되는 경우. (구름?)
					if (gameNodesArray[i]!.position.x < (230 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.65))) * DeviceManager.scrRatioC ) {
						//gameNodesArray[i]!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
						gameNodesArray[i]!.elementSpeed = 1.8;
						gameNodesArray[i]!.elementFlag = 0;
					}
					break;
				case 4: //페이크 가시같은 것들
					if (gameNodesArray[i]!.position.x < (260 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.85))) * DeviceManager.scrRatioC ) {
						gameNodesArray[i]!.ySpeed = 21 * max(1, CGFloat(gameGravity / 1.3));
						gameNodesArray[i]!.elementFlag = 5;
						gameNodesArray[i]!.zRotation = 0;
					}
					break;
				case 5: //페이크 가시가 거의 올라가면
					if (gameNodesArray[i]!.ySpeed < 12) {
						if (gameNodesArray[i]!.zRotation < MATHPI) {
							gameNodesArray[i]!.zRotation += MATHPI / 16;
						}
					}
					break;
				case 6: //날아다니는 AI가 중간에 착지하는 경우
					if (gameNodesArray[i]!.position.x < (220 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.8))) * DeviceManager.scrRatioC ) {
						gameNodesArray[i]!.elementSpeed = 2.2;
						gameNodesArray[i]!.elementFlag = 0;
						gameNodesArray[i]!.motions_walking = gameTexturesAIJMoveTexturesArray;
						gameNodesArray[i]!.motions_jumping = gameTexturesAIJJumpTexturesArray;
					}
					break;
				case 7: break; //반대로 달리는 놈.
				default: break;
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
				toAddelement!.size = CGSizeMake( 94.05 * DeviceManager.scrRatioC , 24.4 * DeviceManager.scrRatioC );
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) - (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 56) * DeviceManager.scrRatioC);
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
						toAddelement!.size = CGSizeMake( 39.4 * DeviceManager.scrRatioC , 9.2 * DeviceManager.scrRatioC );
						break;
					case 2:
						toAddelement!.size = CGSizeMake( 18.4 * DeviceManager.scrRatioC , 16.2 * DeviceManager.scrRatioC );
						break;
					case 3:
						toAddelement!.size = CGSizeMake( 34.75 * DeviceManager.scrRatioC , 60.35 * DeviceManager.scrRatioC );
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
				toAddelement!.size = CGSizeMake( 60 * DeviceManager.scrRatioC , 70 * DeviceManager.scrRatioC );
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2);
				
				if (gameStartupType == 1) {
					toAddelement!.elementSpeed = 2.2; //일반게임은 속도를 좀 줄임
				} else {
					toAddelement!.elementSpeed = 2.8; //속도.
				}
				
				toAddelement!.motions_current = 0;
				toAddelement!.motions_walking = gameTexturesAIMoveTexturesArray;
				
				break;
			
			case 5:
				//AI Astro (점프)
				toAddelement = JumpUpElements(); //텍스쳐는 모션으로 정할 것임.
				toAddelement!.size = CGSizeMake( 60 * DeviceManager.scrRatioC , 70 * DeviceManager.scrRatioC );
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2);
				if (gameStartupType == 1) {
					toAddelement!.elementSpeed = 2.2; //일반게임은 속도를 좀 줄임
				} else {
					toAddelement!.elementSpeed = 2.8; //속도.
				}
				
				toAddelement!.motions_current = 0;
				toAddelement!.motions_walking = gameTexturesAIJMoveTexturesArray;
				toAddelement!.motions_jumping = gameTexturesAIJJumpTexturesArray;
				
				toAddelement!.elementFlag = 1; //점프하는 장애물 (flag)
				
				break;
			
			case 6:
				//페이크 구름
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[6] );
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY;
				toAddelement!.size = CGSizeMake( 94.05 * DeviceManager.scrRatioC , 24.4 * DeviceManager.scrRatioC );
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) - (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 56) * DeviceManager.scrRatioC);
				//구름 종류 증식 (찌그러짐 ^^)
				toAddelement!.yScale = 1.0 - CGFloat(Float(arc4random()) / Float(UINT32_MAX)) / 3;
				
				toAddelement!.elementSpeed = 1.8; // + Double(Float(arc4random()) / Float(UINT32_MAX)) / 9;
				toAddelement!.elementFlag = 2; //고정형 (물리 안받음)
				
				break;
			case 7:
				//페이크 구름 2. (떨어지는 구름)
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[4] );
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY; //static이지만 나중에 dynamic으로 바뀜.
				toAddelement!.size = CGSizeMake( 94.05 * DeviceManager.scrRatioC , 24.4 * DeviceManager.scrRatioC );
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width / 2;
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) - (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 32) * DeviceManager.scrRatioC);
				
				toAddelement!.motions_current = -1;
				toAddelement!.elementFlag = 3; //고정형 (물리 안받음), 그리고 중간에 형태 변경
				toAddelement!.elementSpeed = 1.8;
				break;
			case 8:
				//솟구치는 가시 (...)
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[7] );
				toAddelement!.size = CGSizeMake( 54.15 * DeviceManager.scrRatioC , 20.7 * DeviceManager.scrRatioC );
				
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2);
				toAddelement!.elementSpeed = 1.8; //속도.
				toAddelement!.elementFlag = 4; //빠르게 위로 솟구치는 장애물.
				break;
			case 9:
				//날기만 하는 AI
				toAddelement = JumpUpElements();
				toAddelement!.size = CGSizeMake( 60 * DeviceManager.scrRatioC , 70 * DeviceManager.scrRatioC );
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				/* fly */
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) - (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 24) * DeviceManager.scrRatioC);
				
				toAddelement!.elementSpeed = 1.8; //속도.
				toAddelement!.motions_current = 0;
				toAddelement!.motions_walking = gameTexturesAIFlyTexturesArray;
				toAddelement!.elementFlag = 2; //고정형 (물리 안받음)
				
				break;
			case 10:
				//날다가 땅으로 착지해서 평범하게 걸어가는 미친놈
				toAddelement = JumpUpElements();
				toAddelement!.size = CGSizeMake( 60 * DeviceManager.scrRatioC , 70 * DeviceManager.scrRatioC );
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				/* fly */
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) - (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 24) * DeviceManager.scrRatioC);
				
				toAddelement!.elementSpeed = 1.8; //속도.
				toAddelement!.motions_current = 0;
				toAddelement!.motions_walking = gameTexturesAIJFlyTexturesArray;
				toAddelement!.elementFlag = 6; //고정형 및 형태변경. 좀 일찍.
				
				break;
			case 11:
				//이번엔.. 반대로 달리는 미친놈..
				toAddelement = JumpUpElements(); //텍스쳐는 모션으로 정할 것임.
				toAddelement!.size = CGSizeMake( 60 * DeviceManager.scrRatioC , 70 * DeviceManager.scrRatioC );
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY;
				toAddelement!.position.x = -toAddelement!.size.width / 2; //왼쪽에서 시작
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYAxis - gameStageYHeight + (toAddelement!.size.height / 2) + (48 * DeviceManager.scrRatioC);
				toAddelement!.elementSpeed = -1.6; //속도. -로하면 반대로 감
				toAddelement!.xScale = -1;
				toAddelement!.ySpeed = 10 * max(1, CGFloat(gameGravity / 1.3)); //약간 점프한 상태
				
				toAddelement!.motions_current = 0;
				toAddelement!.motions_walking = gameTexturesAIJMoveTexturesArray;
				toAddelement!.motions_jumping = gameTexturesAIJJumpTexturesArray;
				toAddelement!.elementFlag = 7; //반대로 달리는 장애물.
				
				break;
			case 10000:
				//AI 폭발 효과
				toAddelement = JumpUpElements();
				toAddelement!.elementType = JumpUpElements.TYPE_EFFECT;
				toAddelement!.size = CGSizeMake( 150 * DeviceManager.scrRatioC , 150 * DeviceManager.scrRatioC );
				toAddelement!.position.x = posX; toAddelement!.position.y = posY; //정해진 위치로
				
				//약간의 위치조정.
				toAddelement!.elementTargetPosFix = CGSizeMake( 0, 10 * DeviceManager.scrRatioC );
				toAddelement!.elementTargetElement = targetElement;
				
				if (targetElement == nil) {
					print("boom effect target is null.");
				}
				
				toAddelement!.elementSpeed = 0; //타겟이 정해져있는경우 타겟에 맞춰서 움직일테니.
				toAddelement!.motions_current = 2; //폭발효과는 2번
				toAddelement!.motions_effect = gameTexturesAIEffectsArray[0]; //텍스쳐 배열의 텍스쳐 배열 (이중배열)
				
				break;
			case 10001:
				//그림자. 뭐 빠름을 느끼게 할때나 쓰임
				toAddelement = JumpUpElements();
				toAddelement!.elementType = JumpUpElements.TYPE_SHADOW;
				toAddelement!.size = targetElement!.size;
				toAddelement!.position.x = targetElement!.position.x; toAddelement!.position.y = targetElement!.position.y; //정해진 위치로
				
				toAddelement!.elementSpeed = 0;
				toAddelement!.motions_current = -1; //모션없음
				toAddelement!.texture = targetElement!.texture; //그 순간의 모션이기 때문에 텍스쳐 박제
				break;
			
			default: break;
		}
		
		toAddelement!.zPosition = 1; //behind of character
		mapObject.addChild(toAddelement!);
		gameNodesArray += [toAddelement];
		
		
	}
	
	/////////////
	
	func gameOverRutine() {
		//게임오버 처리 *use only UI available*
		
		//메뉴 제거, 게임 끝, 일시정지는 해제한 상태로.
		isMenuVisible = false;
		gameFinishedBool = true;
		isGamePaused = false;
		uiContents!.menuPausedOverlay.hidden = false; //오버레이는 띄움
		
		//게임오버 창 띄우기
		externalLifeLeft -= 1;
		
		if (externalLifeLeft == 0) {
			//완전 게임오버
			uiContents!.showUISelectionWindow( 3 );
		} else {
			//컨티뉴 게임오버
			uiContents!.showUISelectionWindow( 2 );
		}
		
	} ////// 끝
	
	
	/////////////
	func updateWithSeconds() {
		//알람 게임으로 실행되었을 때, 1초마다 주기적으로 실행되는 함수 (시간 체크시만 사용함)
		//이 함수의 문제점: *앱이 백그라운드에 돌아가도 작동함!!*
		/*if (DeviceManager.appIsBackground == true) {
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
			let location:CGPoint = (touch as UITouch).locationInNode(self);
			touchesLatestPoint.x = location.x; touchesLatestPoint.y = location.y;
			
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
							characterElement!.ySpeed = 11 * max(1, CGFloat(gameGravity / 1.5));
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
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for touch in touches {
			let location:CGPoint = (touch as UITouch).locationInNode(self);
			//이동 거리 찍어주기
			swipeGestureMoved += touchesLatestPoint.y - location.y;
			touchesLatestPoint.x = location.x; touchesLatestPoint.y = location.y;
		}
	}
	
	
	/////////// UI Touch Interactions
	/*func menuTouchesPauseResume() {
		// 일시정지 / 계속 기능
		togglePause();
	}
	func menuTouchesGuide() {
		// 가이드
		showGameGuideUI();
	}
	func menuTouchesSound() {
		// 음소거
		
	}
	func menuTouchesRestart() {
		// 게임 재시작
		showUISelectionWindow(1);
	}
	func menuTouchesStop() {
		// 게임 정지
		showUISelectionWindow(0);
		
	}*/
	
	//////////////////////////////////
	
	//일시정지 기능
	func togglePause() {
		isGamePaused = !isGamePaused;
		uiContents!.toggleMenu( isGamePaused );
	}
	func gameForceStopCallb() {
		//강제 게임 정지의 경우 result 없이 바로 메인으로
		forceExitGame( false );
	}
	func gameOverCallb() {
		//게임오버의 경우 게임오버 루틴으로.
		forceExitGame( true );
		
	}
	func gameRestartCallb() {
		restartGame();
	}
	
	
	//////////////////////////////////
	
	// 게임모드에서의 강제 게임 종료 루틴.
	func forceExitGame( showResultWindow:Bool = false ) {
		print("Game exiting");
		gameFinishedBool = true;
		
		AnalyticsManager.untrackScreen(); //untrack to previous screen
		
		GameModeView.isGameExiting = true; //재시작시엔 이게 false이면, 다시 appear가 발동함
		GameModeView.selfView!.dismissViewControllerAnimated(false, completion: nil);
		ViewController.viewSelf!.showHideBlurview(true);
		GlobalSubView.gameModePlayViewcontroller.dismissViewControllerAnimated(true, completion: { _ in
			if (showResultWindow == true) { //<- Result화면 이동은 게임을 마쳤다는 소리임
				// Result 표시.
				
				if (self.gameScore != 0) {
					// 게임 스코어를 저장함.
					GameManager.saveBestScore(0 /* JumpUP GameID */, score: self.gameScore);
				}
				
				ViewController.viewSelf!.showGameResult(0 /* <- jumpup gameid */ , type: 1 /* game type */,
					score: self.gameScore, best: GameManager.loadBestScore(0) /* load jumpup bestscore */);
			} else {
				//게임 목록의 점프업 화면까지 바로 표시
				ViewController.viewSelf!.openGamePlayView(nil);
				GamePlayView.selfView!.selectCell(0);
			}
		});
	}
	//게임 재시작 루틴.
	func restartGame() {
		print("Game restarting");
		gameFinishedBool = true;
		AnalyticsManager.untrackScreen(); //untrack to previous screen
		GameModeView.isGameExiting = false;
		GameModeView.jumpUPStartupViewController!.dismissViewControllerAnimated(false, completion: nil);
	}
	
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
						Expression<Int64>("backgroundExitCount") <- Int64(AlarmRingView.selfView!.userAsleepCount) /* 존 횟수 */
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
