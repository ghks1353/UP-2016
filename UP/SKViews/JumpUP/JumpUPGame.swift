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

class JumpUPGame:GameStructureScene, UIScrollViewDelegate {
	
	//움직이는 뒷 배경
	var repeatBackgroundTexture:SKTexture = SKTexture( imageNamed: "game-jumpup-assets-background.png" )
	var repeatBackgroundNodes:Array<SKSpriteNode> = []
	var repeatBackgroundContainer:SKNode = SKNode()
	
	var gameUserJumpCount:Int = 0; //점프 횟수
	
	///////////
	//Game variables
	var mapObject:SKNode = SKNode() //효과, 흔들림 등으로 쓸 맵 오브젝트
	
	var gameStageYAxis:CGFloat = 0
	var gameStageYHeight:CGFloat = 0
	var gameStageYFoot:CGFloat = 0 //gravity 0 position
	var gameScrollSpeed:Double = 1 //왼쪽으로 흘러가는 게임 스크롤 스피드.
	var additionalGameScrollSpeed:Double = 1.2 //추가 게임 스크롤 스피드
	
	var gameGravity:Double = 1 //추가 게임 중력.
	var characterJumpPower:Float = 11 //캐릭터 점프력.
	
	let gameCloudAddDelayMAX:Int = 60 // original: 60
	var gameCloudDecorationAddDelay:Int = 0 //구름 생성 딜레이
	
	var gameEnemyGenerateDelayMAX:Int = 120 // original: 120
	var gameEnemyGenerateDelay:Int = 0 //장애물 생성 딜레이
	
	var gameCharacterUnlimitedLife:Int = 0 //캐릭터 무적 시간. (있을 경우)
	var gameCharacterRetryADScoreTerm:Int = 0 //이 시간동안은 점수가 올라가지 않음
	var gameScreenShakeEventDelay:Int = 0 //화면 흔들림 효과를 위한 딜레이.
	var gameRdmElementNum:Int = 0 //랜덤으로 나오는 장애물 고유 번호. (메모리 절약을 위해 재사용)
	
	var previousEnemyNumber:Int = -1 //이전에 바로 나온 노드 번호
	
	var characterMinYAxis:CGFloat = 0 //캐릭터가 땅에 닿았을 때의 좌표
	
	var speedyObjectAlarmFix:CGFloat = 0 //스피드 있는 오브젝트가 알람모드에선 느리기 때문에 좌표 보정치
	
	//Game vars in GAMEMODE.
	var scoreUPDelayMax:Double = 60.0 //스코어 상승 간격
	var scoreUPDelayCurrent:Int = 0 //간격 딜레이
	var scoreUPLevel:Double = 0.0 //현재 게임 레벨
	var scoreNodesRandomArray:Array<Int>? //스코어모드에서의 적 랜덤 출현 배열
	
	var maxScoreGameLife:Int = 0 //최대 라이프 (수치상)
	var scoreGameLife:Int = 0 //현재 게임 라이프. (목숨)
	var externalLifeLeft:Int = 0 //추가로 살아날 수 있는 라이프 개수
	
	//피버모드.. 가 아니라 헬게이트 오픈시 바뀌는 배경색
	var hellMode:Bool = false //일정 레벨 도달시 오픈
	var hellModeBackgroundColours:Array<UIColor> = [
		UPUtils.colorWithHexString("#790000")
		, UPUtils.colorWithHexString("#007700")
		, UPUtils.colorWithHexString("#00006D")
	]
	var hellModeBackgroundCurrentDelay:Int = 0
	var hellModeBackgroundCurrentIndex:Int = 0
	var hellModeScreenReversed:Bool = false //헬모드 뒤집힘.
	
	//Game node arrays
	var gameNodesArray:Array<JumpUpElements?> = []
	//Game elements textures (for *optimize*)
	var gameNodesTexturesArray:Array<SKTexture> = []
	
	//AI Move sktextures (for optimize.)
	var gameTexturesAIMoveTexturesArray:Array<SKTexture> = []
	var gameTexturesAIJMoveTexturesArray:Array<SKTexture> = []
	var gameTexturesAIJJumpTexturesArray:Array<SKTexture> = []
	
	var gameTexturesAIFlyTexturesArray:Array<SKTexture> = []
	var gameTexturesAIJFlyTexturesArray:Array<SKTexture> = []
	
	//AI from LEFT textures
	var gameTexturesAILeftTexturesArray:Array<SKTexture> = []
	var gameTexturesAIJLeftTexturesArray:Array<SKTexture> = []
	
	//AI Effect sktextures array
	var gameTexturesAIEffectsArray:Array<Array<SKTexture>> = []
	
	//Life nodes
	var gameLifeNodesArray:Array<SKSpriteNode> = [] // 생성해놓고 상태 변화에 따라 그림의 변경을 줌.
	var gameLifeOnTexture:SKTexture = SKTexture(imageNamed: "game-jumpup-assets-life-on.png")
	var gameLifeOffTexture:SKTexture = SKTexture(imageNamed: "game-jumpup-assets-life-off.png")
	
	//Alarm bottom guides
	var gameAlarmGuidesNodesArray:Array<SKSpriteNode> = [
		SKSpriteNode( texture: SKTexture( imageNamed: "game-jumpup-assets-guide-alarm-0" ) ),
		SKSpriteNode( texture: SKTexture( imageNamed: "game-jumpup-assets-guide-alarm-1" ) )
	]
	
	//Character element
	var characterElement:JumpUpElements?
	
	//캐릭터 경고등
	var characterWarningSprite:SKSpriteNode = SKSpriteNode( texture: SKTexture( imageNamed: "game-jumpup-assets-warning.png" ) )
	
	//판정 완화의 정도
	let characterRatherboxX:CGFloat = 140 * DeviceManager.scrRatioC
	let characterRatherboxY:CGFloat = 125 * DeviceManager.scrRatioC
	let nodeRatherboxX:CGFloat = 4 * DeviceManager.scrRatioC
	let nodeRatherboxY:CGFloat = 4 * DeviceManager.scrRatioC
	let aiRatherboxX:CGFloat = 16 * DeviceManager.scrRatioC
	let aiRatherboxY:CGFloat = 16 * DeviceManager.scrRatioC
	
	//View initial function
	override func didMove(to view: SKView) {
		
		///////// 사전설정 variables
		//Game ID
		currentGameID = 0
		//Preload total count
		preloadCompleteCout = 83
		
		// 포기까지의 시간
		gameRetireTime = 200
		
		//////////////////
		let bgPositionRect:CGRect = CGRect( x: self.view!.frame.width / 2, y: self.view!.frame.height / 2, width: self.view!.frame.width, height: 226.95 * DeviceManager.scrRatioC )
		
		///////////실제 게임 스테이지 y값
		gameStageYAxis = bgPositionRect.minY + (bgPositionRect.height / 2)
		gameStageYHeight = bgPositionRect.height
		gameStageYFoot = gameStageYAxis - gameStageYHeight / 2 - (48 * DeviceManager.scrRatioC)
		
		/// 버튼 위치 지정 (사전설정 variable)
		buttonYAxisPrefix = gameStageYHeight
		buttonYAxisCenter = gameStageYAxis - gameStageYHeight
		
		//////////////////// Init view (사전설정 필요한 variable 이후)
		super.didMove(to: view)
		
		/////////////////////////
		/// JumpUP assets initialize
		
		//variable initialize
		gameCloudDecorationAddDelay = gameCloudAddDelayMAX //초기값
		//reset character element
		if (characterElement != nil) {
			characterElement = nil
		}
		
		gameEnemyGenerateDelay = 0
		gameCloudDecorationAddDelay = 0
		
		//맵오브젝트 생성
		mapObject.position = CGPoint(x: 0, y: 0)
		mapObject.addChild(repeatBackgroundContainer)
		self.addChild(mapObject)
		
		//게임 스크롤 뒷 배경 추가 (스크롤은 업데이트에서)
		for i:Int in 0 ..< 2 {
			//add 2 nodes
			let nBackground:SKSpriteNode = SKSpriteNode( texture: repeatBackgroundTexture )
			nBackground.size = CGSize( width: self.view!.frame.width, height: 226.95 * DeviceManager.scrRatioC )
			nBackground.position = CGPoint( x: CGFloat(i) * self.view!.frame.width + (self.view!.frame.width / 2), y: self.view!.frame.height / 2 )
			
			repeatBackgroundNodes += [nBackground]
			repeatBackgroundContainer.addChild(nBackground)
		} //end for
		
		///// 알람으로 켜진 경우
		if (gameStartupType == .AlarmMode) {
			//Add How-to-play guide image
			for i:Int in 0 ..< gameAlarmGuidesNodesArray.count {
				let xIndexCalcuated:CGFloat = (i == 0 ? 1 : -1) * (167/2 * DeviceManager.maxScrRatioC)
				
				gameAlarmGuidesNodesArray[i].size = CGSize( width: 167 * DeviceManager.maxScrRatioC, height: 126 * DeviceManager.maxScrRatioC )
				gameAlarmGuidesNodesArray[i].position = CGPoint(
					x: (self.view!.frame.width / 2 - xIndexCalcuated)
					, y: gameStageYAxis - gameStageYHeight - (48 + 42 + 13) * DeviceManager.maxScrRatioC )
				self.addChild( gameAlarmGuidesNodesArray[i] )
			}
			
			//좌표 보정
			speedyObjectAlarmFix = 24
			
			//레벨 조절
			gameAlarmFirstGoalTime = Int(ceil(ALDManager.generatedTimeMultiply))
			gameTimerMaxTime = gameAlarmFirstGoalTime + 20
			gameLevelAverageTime = gameAlarmFirstGoalTime / 2
				
			scoreUPLevel = Double(max(0.0, Double(ALDManager.generatedLevelMultiply)))
			//레벨은 0부터 시작하기 때문에 계수가 1 미만인경우 캐릭터의 점프력을 증가시키는 것으로 대체
			if (ALDManager.generatedLevelMultiply < 1) {
				characterJumpPower = 11 * (1 + ((1 - ALDManager.generatedLevelMultiply) / 1.25))
			}
			
			gameScore = gameAlarmFirstGoalTime //초반 부여
		} else {
			//게임으로 켜진 경우
			gameScore = 0
			maxScoreGameLife = 3 //기본 최대 라이프
			scoreGameLife = maxScoreGameLife
			externalLifeLeft = 2 //연장 1회, 2life
			
			//// 라이프 구성
			for i:Int in 0 ..< maxScoreGameLife {
				// 최대 라이프만큼 슬롯 만들기
				let lifeNode:SKSpriteNode = SKSpriteNode( texture: gameLifeOnTexture )
				let xIndexCalcuated:CGFloat = ((CGFloat(i)-1) * ((48+22 /* 22: margin */) * DeviceManager.maxScrRatioC))
				lifeNode.size = CGSize( width: 48 * DeviceManager.maxScrRatioC, height: 84 * DeviceManager.maxScrRatioC )
				
				lifeNode.position = CGPoint(
					x: (self.view!.frame.width / 2 - xIndexCalcuated)
					, y: gameStageYAxis - gameStageYHeight - (48 + 42 + 13) * DeviceManager.maxScrRatioC )
				
				gameLifeNodesArray += [lifeNode]
				self.addChild( lifeNode )
			} //end for [life]
		} //end if
		
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
					8, 9 - normal cloud (another design)
				
					10, 11, 12 - tiny / small / big shadows
					13, 14 - tiny 1, tiny 2
				*/
				SKTexture( imageNamed: "game-jumpup-assets-cloud-2.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-trap.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-box.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-box2.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-cloud-1.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-cloud-5.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-cloud-6.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-trap-2.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-cloud-3.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-cloud-4.png" ),
				
				SKTexture( imageNamed: "game-jumpup-assets-shadow-tiny-0.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-shadow-small.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-shadow-big.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-shadow-tiny-1.png" ),
				SKTexture( imageNamed: "game-jumpup-assets-shadow-tiny-2.png" )
			]
			
			//Preload textures
			for i:Int in 0 ..< gameNodesTexturesArray.count {
				gameNodesTexturesArray[i].preload(completionHandler: preloadEventCall)
			}
		} //end of creation txt
		
		if (gameTexturesAIEffectsArray.count == 0) {
			//texture effect creation
			gameTexturesAIEffectsArray += [ Array<SKTexture>() ]; //빈 텍스쳐 배열을 만들고 그 안에 텍스쳐들 넣음.
			for i in 0 ..< 22 {
				gameTexturesAIEffectsArray[0] += [
					SKTexture( imageNamed: "game-jumpup-assets-ai-j-astro-effect" + String(i) + ".png")
				];
				// Preload texture (reduce fps drop)
				(gameTexturesAIEffectsArray[0][i] as SKTexture).preload(completionHandler: preloadEventCall);
			}
			
		} //end of effet create
		
		//기존 배열에 노드가 있을경우 삭제
		delAllElementsFromArray()
		
		characterMinYAxis = gameStageYFoot + (32 * DeviceManager.scrRatioC)
		
		//캐릭터 추가
		characterElement = JumpUpElements() //60, 70이 원래 크기였음
		characterElement!.size = CGSize(width: 300 * DeviceManager.scrRatioC, height: 300 * DeviceManager.scrRatioC) //Create astro size
		characterElement!.position.x = 64 * DeviceManager.scrRatioC //캐릭터의 왼쪽. 초기위치 잡음
		characterElement!.position.y = characterMinYAxis
		
		//캐릭터 경고등 추가
		characterWarningSprite.size = CGSize( width: 33.6 * DeviceManager.scrRatioC, height: 30.8 * DeviceManager.scrRatioC )
		characterWarningSprite.position.x = characterElement!.position.x
		mapObject.addChild(characterWarningSprite)
		characterWarningSprite.isHidden = true
		
		//////// Make textures for Character (Player)
		if (characterElement!.motions_walking.count == 0) {
			for i:Int in 0 ..< 6 {
				characterElement!.motions_walking += [
					SKTexture( imageNamed: ThemeManager.getAssetPresets(gameName: ThemeManager.ThemeGameNames.JumpUP, themeTarget: ThemeManager.ThemeFileNames.Character, gamePreset: ThemeManager.ThemeGamePresets.Move, index: i) )
				] //Character motions preload
				(characterElement!.motions_walking[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //walking motion end for *character*
		if (characterElement!.motions_jumping.count == 0) {
			for i:Int in 0 ..< 5 {
				characterElement!.motions_jumping += [
					SKTexture( imageNamed: ThemeManager.getAssetPresets(gameName: ThemeManager.ThemeGameNames.JumpUP, themeTarget: ThemeManager.ThemeFileNames.Character, gamePreset: ThemeManager.ThemeGamePresets.Jump, index: i) )
				] //Character motions preload
				(characterElement!.motions_jumping[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //jumping motion end for *character*
		
		///////////// Make textures for AI
		if (gameTexturesAIMoveTexturesArray.count == 0) {
			for i:Int in 0 ..< 6 {
				gameTexturesAIMoveTexturesArray += [
					SKTexture( imageNamed: "game-jumpup-ai-astro-move-" + String(i) + ".png" )
				]
				(gameTexturesAIMoveTexturesArray[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //jumping motion end for *ai move*
		if (gameTexturesAIJMoveTexturesArray.count == 0) {
			for i:Int in 0 ..< 6 {
				gameTexturesAIJMoveTexturesArray += [
					SKTexture( imageNamed: "game-jumpup-ai-j-astro-move-" + String(i) + ".png" )
				]
				(gameTexturesAIJMoveTexturesArray[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //jumping motion end for *ai_j move*
		if (gameTexturesAIJJumpTexturesArray.count == 0) {
			for i:Int in 0 ..< 5 {
				gameTexturesAIJJumpTexturesArray += [
					SKTexture( imageNamed: "game-jumpup-ai-j-astro-jump-" + String(i) + ".png" )
				]
				(gameTexturesAIJJumpTexturesArray[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //jumping motion end for *ai_j jump*
		if (gameTexturesAIFlyTexturesArray.count == 0) {
			for i:Int in 0 ..< 4 {
				gameTexturesAIFlyTexturesArray += [
					SKTexture( imageNamed: "game-jumpup-ai-astro-fly-" + String(i) + ".png" )
				]
				(gameTexturesAIFlyTexturesArray[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //flying motion end for *ai fly*
		if (gameTexturesAIJFlyTexturesArray.count == 0) {
			for i:Int in 0 ..< 4 {
				gameTexturesAIJFlyTexturesArray += [
					SKTexture( imageNamed: "game-jumpup-ai-j-astro-fly-" + String(i) + ".png" )
				]
				(gameTexturesAIJFlyTexturesArray[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //flying motion end for *ai_j fly*
		if (gameTexturesAILeftTexturesArray.count == 0) {
			for i:Int in 0 ..< 6 {
				gameTexturesAILeftTexturesArray += [
					SKTexture( imageNamed: "game-jumpup-ai-astro-left-move-" + String(i) + ".png" )
				]
				(gameTexturesAILeftTexturesArray[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //walking motion end for *ai left move*
		if (gameTexturesAIJLeftTexturesArray.count == 0) {
			for i:Int in 0 ..< 4 {
				gameTexturesAIJLeftTexturesArray += [
					SKTexture( imageNamed: "game-jumpup-ai-astro-left-jump-" + String(i) + ".png" )
				]
				(gameTexturesAIJLeftTexturesArray[i] as SKTexture).preload(completionHandler: preloadEventCall)
			}
		} //jumping motion end for *ai left jump*
		
		//Character to front
		characterElement!.zPosition = 2
		mapObject.addChild(characterElement!)
		
		//make character's shadow
		addNodes( 10003, posX: characterElement!.position.x, posY: characterElement!.position.y, targetElement: characterElement! )
		
		////////////////// UI 추가설정 (게임모드)
		if (gameStartupType == .GameMode) {
			uiContents!.setGame(0) //jumpup
			uiContents!.initUI( uiContents!.frame )
			
			//set callback functions
			uiContents!.pauseResumeBtnCallback = togglePause
			uiContents!.gameForceStopCallback = gameForceStopCallb
			uiContents!.gameOverCallback = gameOverCallb
			uiContents!.restartCallback = gameRestartCallb
			
			uiContents!.gameShowADCallback = gameADWatchCallb
		} //end if [Check gamemode]
	} //end didMove override func
	
	/////// Method override
	override func appEnteredToForeground() {
		super.appEnteredToForeground()
		
		//App -> Foreground
		if (gameStartupType == .AlarmMode && isGameFinished == false && buttonRetireSprite.alpha == 1) {
			//Game guide animation
			gameAlarmGuidesNodesArray[0].run( SKAction.fadeIn(withDuration: 0.5) )
			gameAlarmGuidesNodesArray[1].run( SKAction.fadeIn(withDuration: 0.5) )
		} //end if [GameType is AlarmMode]
	} //end func
	
	//////////// 모든 Element 제거 (점프업)
	func delAllElementsFromArray() {
		for i:Int in 0 ..< gameNodesArray.count {
			gameNodesArray[i]!.removeFromParent()
			gameNodesArray[i] = nil
		} //end for
		gameNodesArray = []
		print("deleted all nodes from array")
	} //end func
	
	///////// Update
	override func update(_ interval: TimeInterval) {
		//Update per frame
		if (isGameFinished == true) {
			// 게임 끝. update 정지
			return;
		}
		if (isGamePaused == true) {
			return; //게임 일시정지 된 경우 틱 정지
		}
		
		//제스처 처리
		if (abs(swipeGestureMoved) > 0) {
			if (gameStartupType == .GameMode) {
				if (abs(swipeGestureMoved) > swipeGestureValid) {
					if (swipeGestureMoved > 0) {
						// 아래로 스와이프
						
						//급강하 (체공 중일때만 가능)
						if (characterElement!.jumpFlaggedCount != 0 && !characterElement!.shadow_on_air) {
							characterElement!.ySpeed = -20
							// 그림자 효과
							characterElement!.shadow_on_air = true
							characterElement!.shadow_on_frame = 0
							characterElement!.shadow_per_frame_current = 0
							
							//효과음
							SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.CloudFall.rawValue )
						} // end if
						
					} else {
						//위로 스와이프
						
						//슈퍼점프 (스와이프로)
						if (characterElement!.jumpFlaggedCount < 2) { //점프 가능 횟수가 남아있을 경우
							characterElement!.ySpeed = 16 * max(1, CGFloat(gameGravity / 1.25))
							characterElement!.jumpFlaggedCount += 2
							
							// 체공중 그림자 효과
							characterElement!.shadow_on_air = false
							characterElement!.shadow_on_frame = 30
							characterElement!.shadow_per_frame_current = 0
							
							//효과음
							SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.CharacterJump.rawValue )
						} //end if
						
					} //end if [swipe direction]
				} //end if [isSwipeValid]
				
				swipeGestureMoved *= 0.75
				if (abs(swipeGestureMoved) < 0.1) {
					swipeGestureMoved = 0
				} //end if
			} //end if [isGameMode]
		} //////// 제스처 처리 끝
		
		//백그라운드 흐름 효과
		for bgi:Int in 0 ..< repeatBackgroundNodes.count {
			repeatBackgroundNodes[bgi].position.x -= CGFloat(additionalGameScrollSpeed);
			if (repeatBackgroundNodes[bgi].position.x < -repeatBackgroundNodes[bgi].size.width / 2) {
				repeatBackgroundNodes[bgi].position.x =
					(bgi == repeatBackgroundNodes.count - 1 ? repeatBackgroundNodes[0].position.x : repeatBackgroundNodes[bgi + 1].position.x)
				+ self.view!.frame.width - ((2 + CGFloat(additionalGameScrollSpeed)) * DeviceManager.scrRatioC);
			}
		}
		
		//화면 흔들림 효과
		let defWid:CGFloat = (mapObject.zRotation / MATHPI) * (self.view!.frame.width);
		if (gameScreenShakeEventDelay > 0) {
			if (gameScreenShakeEventDelay % 2 == 0) {
				mapObject.position.x =
					( mapObject.position.x < defWid ? (12 * (CGFloat(gameScreenShakeEventDelay) / 60)) : (-12 * (CGFloat(gameScreenShakeEventDelay) / 60)) )
				mapObject.position.x = mapObject.position.x * DeviceManager.scrRatioC
				mapObject.position.x += defWid
			}
			gameScreenShakeEventDelay -= 1
		} else {
			gameScreenShakeEventDelay = 0
			mapObject.position.x = defWid
		} //end if [screen needs shake]
		mapObject.position.y = (mapObject.zRotation / MATHPI) * (self.view!.frame.height)
		
		//화면 회전 효과
		if ( hellModeScreenReversed == false ) {
			if (mapObject.zRotation > 0) {
				mapObject.zRotation -= MATHPI / 16
				if (mapObject.zRotation <= 0) {
					mapObject.zRotation = 0
				} //end if
			} //end if
		} else {
			if (mapObject.zRotation < MATHPI) {
				mapObject.zRotation += MATHPI / 16
				if (mapObject.zRotation >= MATHPI) {
					mapObject.zRotation = MATHPI
				}
			}
		} //end if [HellModeScreenReversedOrNot]
		
		//라이프 인디케이터 갱신
		if (maxScoreGameLife > 0) {
			//MAX라이프가 있을 때.
			for i:Int in 0 ..< gameLifeNodesArray.count {
				if ((scoreGameLife-1) >= i) { //라이프 있음 체크
					if (gameLifeNodesArray[(gameLifeNodesArray.count-1) - i].texture == gameLifeOffTexture) {
						gameLifeNodesArray[(gameLifeNodesArray.count-1) - i].texture = gameLifeOnTexture
					}
				} else { //라이프 없음 체크
					if (gameLifeNodesArray[(gameLifeNodesArray.count-1) - i].texture == gameLifeOnTexture) {
						gameLifeNodesArray[(gameLifeNodesArray.count-1) - i].texture = gameLifeOffTexture
					}
				} //라이프 체크 끝
			} //반복문 종료
		} //라이프 인디케이터 갱신 끝.
		
		//게임모드일 시 스코어 상승과 레벨링
		if (gameStartupType == .GameMode) {
			
			//헬모드 효과 (..)
			if (hellMode == true) {
				if (hellModeBackgroundCurrentDelay <= 0) {
					self.backgroundColor = hellModeBackgroundColours[hellModeBackgroundCurrentIndex];
					hellModeBackgroundCurrentIndex += 1
					if (hellModeBackgroundCurrentIndex >= hellModeBackgroundColours.count) {
						hellModeBackgroundCurrentIndex = 0
					}
					hellModeBackgroundCurrentDelay = 8
				} else {
					hellModeBackgroundCurrentDelay -= 1
				}
				repeatBackgroundContainer.alpha = repeatBackgroundContainer.alpha > 0 ? repeatBackgroundContainer.alpha - 0.01 : 0
			} //헬모드 효과 끝
			
			if (gameCharacterRetryADScoreTerm <= 0) {
				if (scoreUPDelayCurrent <= 0) {
					scoreUPDelayCurrent = Int(round(scoreUPDelayMax))
					
					if (scoreUPLevel > 10) {
						gameScore += min(9, Int(round(scoreUPLevel / 5)))
					} else {
						gameScore += 1
					} //end if scoreup level is 10 above.
					
					if (gameScore >= 10000 && hellMode == false) {
						//헬모드 트리거 조건: 게임 점수 1만점 이상
						hellMode = true
					} else {
						//헬모드 중일 때
						
					}
					
					scoreUPDelayMax -= 0.5
					scoreUPDelayMax = max(max(0, 10 - scoreUPLevel), scoreUPDelayMax)
					
					print("Current level:", scoreUPLevel, ",Scroll (x):", additionalGameScrollSpeed, ", Max delay:",
						  max(40, gameEnemyGenerateDelayMAX - Int(round(scoreUPLevel * 10))))
				} else {
					scoreUPDelayCurrent -= 1
				} //end if [Score UP Delay is 0]
				//레벨을 일정 주기로 높임
				scoreUPLevel += 0.0014 //0.0009
			} else {
				gameCharacterRetryADScoreTerm -= 1
			} //end if [Character is unbeatable or not]
		} //end if [gametype is gamemode]
		
		//// 기본적인 레벨링은 일반 알람모드에서도 적용 (단, 레벨이 올라가지는 않음)
		//스크롤 속도 높임
		if (hellMode == true) {
			additionalGameScrollSpeed = 3.5 //헬모드 속도 고정
		} else if ( additionalGameScrollSpeed < 2.5) { //조금 빠르게 올림
			additionalGameScrollSpeed = min(3.25, 1.24 + (scoreUPLevel / 4))
		} else { //천천히 올림
			additionalGameScrollSpeed = min(3.25, additionalGameScrollSpeed + 0.0002 )
		} //end if [hellmode, scrollspeed]
		//약간씩 중력 늘림 (스크롤 속도 비례)
		gameGravity = max(1, additionalGameScrollSpeed / 2)
		
		//Render time(or score)
		gameScoreStr = String(gameScore)
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
				addNodes( 0 ) //0 is decoration cloud
			}
			gameCloudDecorationAddDelay = gameCloudAddDelayMAX
		} else {
			gameCloudDecorationAddDelay -= 1
		} //end of decoration cloud add
		
		//Add enemy elements
		if (gameEnemyGenerateDelay <= 0){
			gameRdmElementNum = 1 + Int(arc4random_uniform( 5 )) //0번은 데코용 구름이라 제외함
			let rdmVars:Float = Float(arc4random()) / Float(UINT32_MAX)
			//딜레이 설정 및 노드 생성
			switch(gameStartupType) {
				case .AlarmMode: //알람 게임
					gameRdmElementNum = 1 + Int(arc4random_uniform( 5 ))
					//일정 시간 미만으로 남았을 때, 알람으로 켜졌을 때, 약 50% 미만의 확률로 발동
					if (gameScore < gameLevelAverageTime) {
						if (rdmVars <= 0.1) {
							addNodes( 6 ) //구름
							addNodes( 1 + Int(arc4random_uniform( 2 ))) //가시 + 박스
						} else if (rdmVars <= 0.4 && ALDManager.generatedLevelMultiply >= 2) {
							//페이크 가시
							addNodes( 8 )
							//self.addNodes( 3 + Int(arc4random_uniform( 3 )))
						} else {
							addNodes( gameRdmElementNum )
						}
					} else {
						addNodes( gameRdmElementNum )
					} //end if [time check]
					
					//딜레이 최대치를 시간이 갈때마다 줄임 (알람으로 켜졌을 때.)
					//gameEnemyGenerateDelay = gameEnemyGenerateDelayMAX - Int((gameAlarmFirstGoalTime - gameScore) / 4)
					
					//딜레이 최대치 스크롤 속도에 비례.
					gameEnemyGenerateDelay = max(40, gameEnemyGenerateDelayMAX - Int(round(scoreUPLevel * (9 + Double(ALDManager.generatedLevelMultiply)))))
					break
				case .GameMode: //직접 킨 게임
					if (hellMode == true) { //헬모드가 켜진 경우, 가끔씩 화면을 돌림
						if (Float(arc4random()) / Float(UINT32_MAX) < 0.1) { //10% 확률로 돌림
							//180도 플랩
							hellModeScreenReversed = !hellModeScreenReversed
						} //end if [10%]
					} //헬모드 처리 끝
					
					if (scoreUPLevel > 9) { //////////////////// 9레벨 등장 패턴
						switch(previousEnemyNumber) {
							case 11:
								gameRdmElementNum = 0
								//뒤에서 나오는걸 생성
								addNodes( 11 )
								characterWarningSprite.isHidden = true
								break;
							default:
								if (rdmVars >= 0.95) { //낮은확률로 다음 턴에 뒤로 달리는 로봇 생성.
									//고로 이번턴엔 점프를 안 할만한걸 생성
									scoreNodesRandomArray = [ 9 ]
									gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
									addNodes( gameRdmElementNum )
									gameRdmElementNum = 11 // 점등 해제를 위해
									
									//경고등 점등
									characterWarningSprite.isHidden = false
									
									//경고등 점등과 함께 효과음
									SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.EnemyWarning.rawValue )
								} else if (rdmVars <= 0.05) { //0.5/10 확률로 떨어지는 구름 생성
									gameRdmElementNum = 7
									scoreNodesRandomArray = [ 1, 2, 3 ]
									gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
									addNodes( 7 ) //위에 고정되었다 떨어지는 구름
									addNodes( gameRdmElementNum ) //작은 박스나 가시로만 구성
								} else if (previousEnemyNumber == 7) {
									//이전에 바로 구름이 나온 경우, 로봇은 소환하지 말자
									scoreNodesRandomArray = [ 1, 2, 3, 9 ]
									gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
									
									addNodes( gameRdmElementNum ) //3단 박스 + 날아다니는 로봇
								} else {
									scoreNodesRandomArray = [ 1, 2, 3, 4, 5, 8, 9, 10 ] //9, 10: 플라잉 로봇. 떨어지는 놈까지
									gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
									addNodes( gameRdmElementNum )
								} //end if [Random vars]
								break
						} //end switch [previous enemy ID]
						
						////////// 9레벨 끝
					} else if (scoreUPLevel > 7) { //////////////////// 7레벨 등장 패턴
						
						if (rdmVars <= 0.05) { //0.5/10 확률로 떨어지는 구름 생성
							gameRdmElementNum = 7
							scoreNodesRandomArray = [ 1, 2, 3 ]
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
							self.addNodes( 7 ) //위에 고정되었다 떨어지는 구름
							self.addNodes( gameRdmElementNum ) //작은 박스나 가시로만 구성
						} else if (previousEnemyNumber == 7) {
							//이전에 바로 구름이 나온 경우, 로봇은 소환하지 말자
							scoreNodesRandomArray = [ 1, 2, 3, 9 ]
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
							
							self.addNodes( gameRdmElementNum ) //3단 박스 + 날아다니는 로봇
						} else {
							scoreNodesRandomArray = [ 1, 2, 3, 4, 5, 8, 9 ] //9 : 플라잉 로봇
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
							self.addNodes( gameRdmElementNum )
						} //end if [random]
						
						////////// 7레벨 끝
					} else if (scoreUPLevel > 4) { //////////////////// 4레벨 등장 패턴
						if (rdmVars <= 0.1) { //1/10 확률로 떨어지는 구름 생성
							gameRdmElementNum = 7
							
							scoreNodesRandomArray = [ 1, 2, 3 ] //올라가는 가시가 나오면 안될듯. 3단 박스까지만
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
							
							self.addNodes( 7 ) //위에 고정되었다 떨어지는 구름
							self.addNodes( gameRdmElementNum ) //작은 박스나 가시로만 구성
							
						} else if (previousEnemyNumber == 7) {
							//이전에 바로 구름이 나온 경우, 로봇은 소환하지 말자
							self.addNodes( 1 + Int(arc4random_uniform( 3 ))) //3단 박스까지 생성함.
						} else {
							scoreNodesRandomArray = [ 1, 2, 3, 4, 5 ]
							gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
							self.addNodes( gameRdmElementNum )
						}
						////////// 4레벨 끝
					} else { //////////////////// 일반 패턴
						scoreNodesRandomArray = [ 1, 2, 3, 4, 5]
						gameRdmElementNum = scoreNodesRandomArray![ Int(arc4random_uniform( UInt32(scoreNodesRandomArray!.count) )) ]
						self.addNodes( gameRdmElementNum )
					} //end check [GameLevel]
					
					gameEnemyGenerateDelay = max(40, gameEnemyGenerateDelayMAX - Int(round(scoreUPLevel * 10)))
					//스코어 레벨에 따라 관리
					//해보니까 빠른속도에 50이하로 내려가긴 힘듬
					
					scoreNodesRandomArray = nil //GC
					break
			} //end switch
			
			previousEnemyNumber = gameRdmElementNum
			
		} else {
			gameEnemyGenerateDelay -= 1
		} //end of generate
		
		
		//Node motion queue
		// - CharacterMotionQueue
		if (characterElement!.motions_frame_delay_left <= 0) {
			characterElement!.motions_current_frame += 1
			switch( characterElement!.motions_current ) {
				case 0: //walking motion
					characterElement!.texture = characterElement!.motions_walking[characterElement!.motions_current_frame]
					characterElement!.motions_frame_delay_left = max(1, 5 - (Int(round(additionalGameScrollSpeed)) - 1)) //per 5f
					if (characterElement!.motions_current_frame >= characterElement!.motions_walking.count - 1) {
						characterElement!.motions_current_frame = -1 //frame reset to 0 (-1 > next frame < 0)
					}
					break
				case 1: //Jump motion
					characterElement!.texture = characterElement!.motions_jumping[characterElement!.motions_current_frame]
					characterElement!.motions_frame_delay_left = 5 //per 5f
					if (characterElement!.motions_current_frame >= characterElement!.motions_jumping.count - 1) {
						characterElement!.motions_current_frame = -1 //frame reset to 0 (-1 > next frame < 0)
					}
					break
				default: break
			} //end switch current motion
		} else {
			//delay min
			characterElement!.motions_frame_delay_left -= 1
		} //end if character motion delay
		
		//Character jump queue
		characterElement!.position.y += (characterElement!.ySpeed / 2) * DeviceManager.scrRatioC;
							/// 1을 더하는 이유는 기종마다 미세한 픽셀 차이로 인해 모션이 안나오는 버그가 있기 때문임
		if (characterElement!.position.y <= 1 + characterMinYAxis) {
			characterElement!.position.y = characterMinYAxis
			characterElement!.ySpeed = 0
			characterElement!.changeMotion(0) //walking motion
			characterElement!.jumpFlaggedCount = 0 //점프횟수 초기화
			characterElement!.shadow_on_air = false //체공 쉐도우 있으면 해제.
		} else {
			characterElement!.ySpeed -= 0.5 * CGFloat(gameGravity)
			characterElement!.changeMotion(1) //jumping motion
		} //end if
		
		//Character-warning queue
		if (characterWarningSprite.isHidden == false) {
			characterWarningSprite.position.y = characterElement!.position.y + characterElement!.size.height / 8 + 18 * DeviceManager.scrRatioC
		}
		
		//캐릭터 무적 처리
		if (gameCharacterUnlimitedLife > 0) {
			gameCharacterUnlimitedLife -= 1
			characterElement!.alpha = characterElement!.alpha == 0 ? 1 : 0
		} else if (gameCharacterUnlimitedLife <= 0) {
			characterElement!.alpha = 1
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
					if (gameNodesArray[i]!.elementTargetElement != nil && gameNodesArray[i]!.elementTargetElement!.parent != nil) {
						switch(gameNodesArray[i]!.elementStyleType) {
							case JumpUpElements.STYLE_SHADOW:
								gameNodesArray[i]!.position.x = gameNodesArray[i]!.elementTargetElement!.position.x + gameNodesArray[i]!.elementTargetPosFix!.width;
								gameNodesArray[i]!.position.y = gameStageYFoot + gameNodesArray[i]!.elementTargetPosFix!.height;
								break;
							default:
								gameNodesArray[i]!.position.x = gameNodesArray[i]!.elementTargetElement!.position.x + gameNodesArray[i]!.elementTargetPosFix!.width;
								gameNodesArray[i]!.position.y = gameNodesArray[i]!.elementTargetElement!.position.y + gameNodesArray[i]!.elementTargetPosFix!.height;
								break;
						}
						//print("Moving effect to target.");
					} else {
						gameNodesArray[i]!.position.x -= CGFloat(gameScrollSpeed * gameNodesArray[i]!.elementSpeed * additionalGameScrollSpeed) * DeviceManager.scrRatioC;
					}
					
					break;
				
				default: break;
			} //end switch
			
			//If node is not visible, remove it
			switch(gameNodesArray[i]!.elementFlag) {
				case 7: //화면 오른쪽에서 없어짐
					
					if (gameNodesArray[i]!.position.x > self.view!.frame.width + gameNodesArray[i]!.size.width / 2) {
						gameNodesArray[i]!.removeFromParent(); gameNodesArray[i] = nil;
						gameNodesArray.remove(at: i);
						continue;
					} //end of remove
					
					break;
				default: //화면 왼쪽에서 없어짐
					if (gameNodesArray[i]!.position.x < -gameNodesArray[i]!.size.width / 2) { //remove
						//print("Disposing type " + String(gameNodesArray[i]!.elementType));
						gameNodesArray[i]!.removeFromParent(); gameNodesArray[i] = nil;
						gameNodesArray.remove(at: i);
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
									gameNodesArray.remove(at: i);
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
						gameNodesArray.remove(at: i);
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
							var additionalYFixAxis:CGFloat = 0;
							switch(gameNodesArray[i]!.elementStyleType) {
								case JumpUpElements.STYLE_AI:
									additionalYFixAxis = -13;
									break;
								default:
									additionalYFixAxis = 0;
									break;
							} //end switch [elementStyleType]
							
							gameNodesArray[i]!.position.y += (gameNodesArray[i]!.ySpeed / 2) * DeviceManager.scrRatioC;
							if (gameNodesArray[i]!.position.y <= 1 + gameStageYFoot + additionalYFixAxis + (gameNodesArray[i]!.size.height / 2)) {
								gameNodesArray[i]!.position.y = gameStageYFoot + additionalYFixAxis + (gameNodesArray[i]!.size.height / 2);
								gameNodesArray[i]!.ySpeed = 0;
								gameNodesArray[i]!.changeMotion(0); //walking motion
								gameNodesArray[i]!.jumpFlaggedCount = 0; //점프횟수 초기화
							} else {
								gameNodesArray[i]!.ySpeed -= 0.5 * CGFloat(gameGravity);
								gameNodesArray[i]!.changeMotion(1); //jumping motion
							} //end if
							break
					} //end switch [ElementFlag]
					
					//판정 완화용 Rect.
					var nodeTmpRect:CGRect? = nil
					switch(gameNodesArray[i]!.elementStyleType) {
						case JumpUpElements.STYLE_AI:
							nodeTmpRect = CGRect(
								x:
								(gameNodesArray[i]!.position.x - gameNodesArray[i]!.size.width / 2) + aiRatherboxX ,
								y:
								(gameNodesArray[i]!.position.y - gameNodesArray[i]!.size.height / 2) + aiRatherboxY ,
								width: gameNodesArray[i]!.size.width - (aiRatherboxX * 2),
								height: max(6 * DeviceManager.scrRatioC, gameNodesArray[i]!.size.height - (aiRatherboxY * 2))
							)
							break
						default:
							nodeTmpRect = CGRect(
								x:
								(gameNodesArray[i]!.position.x - gameNodesArray[i]!.size.width / 2) + nodeRatherboxX ,
								y:
								(gameNodesArray[i]!.position.y - gameNodesArray[i]!.size.height / 2) + nodeRatherboxY ,
								width: gameNodesArray[i]!.size.width - (nodeRatherboxX * 2),
								height: max(6 * DeviceManager.scrRatioC, gameNodesArray[i]!.size.height - (nodeRatherboxY * 2))
								)
							break
					} //end switch [ElementStyle]
					
					if ( //캐릭터 - 적간 충돌판정 (조금 완화 함.)
							nodeTmpRect!.contains( CGPoint( x: (characterElement!.position.x - characterElement!.size.width / 2) + characterRatherboxX, y: (characterElement!.position.y - characterElement!.size.height / 2) + characterRatherboxY  ) ) ||
							nodeTmpRect!.contains( CGPoint( x: (characterElement!.position.x + characterElement!.size.width / 2) - characterRatherboxX, y: (characterElement!.position.y - characterElement!.size.height / 2) + characterRatherboxY  ) ) ||
							
							nodeTmpRect!.contains( CGPoint( x: (characterElement!.position.x - characterElement!.size.width / 2) + characterRatherboxX, y: (characterElement!.position.y + characterElement!.size.height / 2) - characterRatherboxY  ) ) ||
							nodeTmpRect!.contains( CGPoint( x: (characterElement!.position.x + characterElement!.size.width / 2) - characterRatherboxX, y: (characterElement!.position.y + characterElement!.size.height / 2) - characterRatherboxY  ) )
						) {
						
							if (gameCharacterUnlimitedLife == 0) {
								print("Character collision")
								gameCharacterUnlimitedLife = 120 //무적시간 부여
								gameScreenShakeEventDelay = 60 //화면 흔들림 효과
								
								//진동
								AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
								
								//통계값 추가
								statsGameDiedCount += 1
								
								//scoreGameLife
								switch(gameStartupType) {
									case .AlarmMode: //알람으로 켜진 경우, 최대 설정된 시간까지 커지도록 시간 추가
										if (gameScore <= gameLevelAverageTime) {
											gameScore = min( gameScore + 5, gameTimerMaxTime)
										} else {
											gameScore = min( gameScore + 7, gameTimerMaxTime)
										} //end if [Alarm time is average time or not]
										break
									case .GameMode: //게임 모드로 켜짐
										scoreGameLife -= 1
										if (scoreGameLife <= 0) {
											gameOverRutine() //라이프가 없으면 게임오버.
											return
										} //end if
										break
								} //end switch [Game Startup Type]
							} //end if
					} //end if
					
					break
				default: break;
			} //end switch
			
			//특수한 적의 경우 특별한 경우 점프를 하도록 만듬. 아래 적은 점프하느 ㄴ적의 경우.
			//점프할거라는 신호를 먼저 주고 점프해야 함. addNodes( 10000 );
			switch(gameNodesArray[i]!.elementFlag) {
				case 1: //점프하는 적
					let distanceFlagZero:CGFloat = (260 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.65))) * DeviceManager.scrRatioC
					let distanceFlagOne:CGFloat = (160 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.85))) * DeviceManager.scrRatioC
					
					if (gameNodesArray[i]!.elementTickFlag == 0 && gameNodesArray[i]!.position.x < distanceFlagZero ) {
						addNodes( 10000, posX: gameNodesArray[i]!.position.x, posY: gameNodesArray[i]!.position.y, targetElement: gameNodesArray[i] )
						gameNodesArray[i]!.elementTickFlag = 1
					} else if (gameNodesArray[i]!.elementTickFlag == 1 && gameNodesArray[i]!.position.x < distanceFlagOne ) {
						//점프하는 적 점프 트리거
						gameNodesArray[i]!.ySpeed = 14 * max(1, CGFloat(gameGravity / 1.1))
						gameNodesArray[i]!.elementTickFlag = 2
						
						//점프하는 적 효과음.
						SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.EnemyJump.rawValue )
					} //end if
					break
				case 2: break; //물리 영향 없음
				case 3: //일정 좌표 이후 형태가 변경되는 경우. (구름?)
					if (gameNodesArray[i]!.position.x < (230 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.65))) * DeviceManager.scrRatioC ) {
						gameNodesArray[i]!.elementSpeed = 1.8
						gameNodesArray[i]!.elementFlag = 0
						
						//구름 등 떨어짐 효과음
						SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.CloudFall.rawValue )
					} //end if
					break;
				case 4: //페이크 가시같은 것들
					if (gameNodesArray[i]!.position.x < ((260 + speedyObjectAlarmFix) * max(1.0, CGFloat(additionalGameScrollSpeed / 1.85))) * DeviceManager.scrRatioC ) {
						gameNodesArray[i]!.ySpeed = 21 * max(1, CGFloat(gameGravity / 1.3))
						gameNodesArray[i]!.elementFlag = 5
						gameNodesArray[i]!.zRotation = 0
						
						//페이크 가시 점프
						SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.NiddleJump.rawValue )
					} //end if
					break;
				case 5: //페이크 가시가 거의 올라가면
					if (gameNodesArray[i]!.ySpeed < 12) {
						if (gameNodesArray[i]!.zRotation < MATHPI) {
							gameNodesArray[i]!.zRotation += MATHPI / 16
						} else if (gameNodesArray[i]!.elementTickFlag == 0) {
							gameNodesArray[i]!.elementTickFlag = 1
							
							//가시 떨어짐 효과음
							SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.NiddleFall.rawValue )
						} //end if
					} //end if
					break;
				case 6: //날아다니는 AI가 중간에 착지하는 경우
					if (gameNodesArray[i]!.position.x < (220 * max(1.0, CGFloat(additionalGameScrollSpeed / 1.8))) * DeviceManager.scrRatioC ) {
						gameNodesArray[i]!.elementSpeed = 2.2
						gameNodesArray[i]!.elementFlag = 0
						gameNodesArray[i]!.motions_walking = gameTexturesAIJMoveTexturesArray
						gameNodesArray[i]!.motions_jumping = gameTexturesAIJJumpTexturesArray
						
						//날아다니는 AI 착지 효과음
						SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.EnemyFall.rawValue )
					} //end if
					break;
				case 7: break //반대로 달리는 놈.
				default: break
			}
			
		} //end for
		
	} //end of tick
	
	//node add func
	func addNodes( _ elementType:Int, posX:CGFloat = 0, posY:CGFloat = 0, targetElement:JumpUpElements? = nil ) {
		var toAddelement:JumpUpElements?
		var addTargetChild:Bool = false
		var ignoresForceZPosition:Bool = false
		
		//shadow flags
		var tmpCloudNumber:Int = Int(arc4random_uniform( 3 ))
		
		switch(elementType){
			case 0: //0 - Cloud for decoration
				
				//랜덤으로 구름의 종류 (3가지) 중 하나로 결정
				switch( tmpCloudNumber ) {
					case 0:
						toAddelement = JumpUpElements( texture: gameNodesTexturesArray[0] );
						toAddelement!.size = CGSize( width: 132.65 * DeviceManager.scrRatioC , height: 32.15 * DeviceManager.scrRatioC );
						break;
					case 1:
						toAddelement = JumpUpElements( texture: gameNodesTexturesArray[8] );
						toAddelement!.size = CGSize( width: 100.5 * DeviceManager.scrRatioC , height: 24.1 * DeviceManager.scrRatioC );
						break;
					case 2:
						toAddelement = JumpUpElements( texture: gameNodesTexturesArray[9] );
						toAddelement!.size = CGSize( width: 100.45 * DeviceManager.scrRatioC , height: 24.1 * DeviceManager.scrRatioC );
						break;
					default:
						
						break;
				} //end cloud selection
				
				ignoresForceZPosition = true
				
				toAddelement!.elementType = JumpUpElements.TYPE_DECORATION
				toAddelement!.elementTargetPosFix = CGSize( width: 0, height: (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 52) * DeviceManager.scrRatioC) )
				
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) + toAddelement!.elementTargetPosFix!.height;
				//toAddelement!.alpha = 0.8;
				
				toAddelement!.elementSpeed = 1.1 + Double(Float(arc4random()) / Float(UINT32_MAX)) / 7;
				break;
			case 1, 2, 3:
				/* 1 - fuc**ng trap
					2 - **cking box
					3 - triple-fu**ing box */
				
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[elementType] );
				switch(elementType) {
					case 1:
						toAddelement!.size = CGSize( width: 44 * DeviceManager.scrRatioC , height: 12 * DeviceManager.scrRatioC );
						break;
					case 2:
						toAddelement!.size = CGSize( width: 24 * DeviceManager.scrRatioC , height: 24 * DeviceManager.scrRatioC );
						break;
					case 3:
						toAddelement!.size = CGSize( width: 36 * DeviceManager.scrRatioC , height: 72 * DeviceManager.scrRatioC );
						break;
					default: break;
				}
				
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY;
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width;
											/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYFoot + (toAddelement!.size.height / 2);
				toAddelement!.elementSpeed = 1.8; //속도.
				
				break;
			
			case 4:
				//AI Astro (점프 안하고 걸어오는)
				toAddelement = JumpUpElements() //텍스쳐는 모션으로 정할 것임.
				toAddelement!.size = CGSize( width: 85 * DeviceManager.scrRatioC , height: 95 * DeviceManager.scrRatioC )
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYFoot + (toAddelement!.size.height / 2)
				
				if (gameStartupType == .GameMode) {
					toAddelement!.elementSpeed = 2.2 //일반게임은 속도를 좀 줄임
				} else {
					toAddelement!.elementSpeed = 2.8 //속도.
				}
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_AI
				
				toAddelement!.motions_current = 0
				toAddelement!.motions_walking = gameTexturesAIMoveTexturesArray
				toAddelement!.motions_jumping = gameTexturesAIJJumpTexturesArray
				
				break
			case 5:
				//AI Astro (점프)
				toAddelement = JumpUpElements() //텍스쳐는 모션으로 정할 것임.
				toAddelement!.size = CGSize( width: 85 * DeviceManager.scrRatioC , height: 95 * DeviceManager.scrRatioC )
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYFoot + (toAddelement!.size.height / 2)
				if (gameStartupType == .GameMode) {
					toAddelement!.elementSpeed = 2.2 //일반게임은 속도를 좀 줄임
				} else {
					toAddelement!.elementSpeed = 2.8 //속도.
				}
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_AI
				
				toAddelement!.motions_current = 0
				toAddelement!.motions_walking = gameTexturesAIJMoveTexturesArray
				toAddelement!.motions_jumping = gameTexturesAIJJumpTexturesArray
				
				toAddelement!.elementFlag = 1 //점프하는 장애물 (flag)
				break
			
			case 6:
				//페이크 구름
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[6] )
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY
				toAddelement!.size = CGSize( width: 92.3 * DeviceManager.scrRatioC , height: 25.15 * DeviceManager.scrRatioC )
				
				toAddelement!.elementTargetPosFix = CGSize( width: 0, height: 27 + (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 12) * DeviceManager.scrRatioC) )
				
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) + toAddelement!.elementTargetPosFix!.height
				
				toAddelement!.elementSpeed = 1.8 // + Double(Float(arc4random()) / Float(UINT32_MAX)) / 9;
				toAddelement!.elementFlag = 2 //고정형 (물리 안받음)
				
				ignoresForceZPosition = true
				tmpCloudNumber = 3
				break
			case 7:
				//페이크 구름 2. (떨어지는 구름)
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[5] )
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY //static이지만 나중에 dynamic으로 바뀜.
				toAddelement!.size = CGSize( width: 92.3 * DeviceManager.scrRatioC , height: 25.95 * DeviceManager.scrRatioC )
				
				toAddelement!.elementTargetPosFix = CGSize( width: 0, height: 0 )
				
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width / 2
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) + (48 + (CGFloat(Double(Float(arc4random()) / Float(UINT32_MAX)) * 12) * DeviceManager.scrRatioC))
				
				toAddelement!.motions_current = -1
				toAddelement!.elementFlag = 3 //고정형 (물리 안받음), 그리고 중간에 형태 변경
				toAddelement!.elementSpeed = 1.8
				
				ignoresForceZPosition = true
				tmpCloudNumber = 4
				break;
			case 8:
				//솟구치는 가시 (...)
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[7] )
				toAddelement!.size = CGSize( width: 44 * DeviceManager.scrRatioC , height: 12 * DeviceManager.scrRatioC )
				
				toAddelement!.elementType = JumpUpElements.TYPE_STATIC_ENEMY
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width
				toAddelement!.position.y = gameStageYFoot + (toAddelement!.size.height / 2)
				toAddelement!.elementSpeed = 1.8 //속도.
				toAddelement!.elementFlag = 4 //빠르게 위로 솟구치는 장애물.
				break;
			case 9:
				//날기만 하는 AI
				toAddelement = JumpUpElements()
				toAddelement!.size = CGSize( width: 85 * DeviceManager.scrRatioC , height: 95 * DeviceManager.scrRatioC )
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width
				/* fly */
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) + (CGFloat(80 + Double(Float(arc4random()) / Float(UINT32_MAX)) * 18) * DeviceManager.scrRatioC)
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_AI
				
				toAddelement!.elementSpeed = 1.8 //속도.
				toAddelement!.motions_current = 0
				toAddelement!.motions_walking = gameTexturesAIFlyTexturesArray
				toAddelement!.elementFlag = 2 //고정형 (물리 안받음)
				
				//나는 AI 효과음
				SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.EnemyFly.rawValue )
				break
			case 10:
				//날다가 땅으로 착지해서 평범하게 걸어가는 미친놈
				toAddelement = JumpUpElements()
				toAddelement!.size = CGSize( width: 85 * DeviceManager.scrRatioC , height: 95 * DeviceManager.scrRatioC )
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY
				toAddelement!.position.x = self.view!.frame.width + toAddelement!.size.width
				/* fly */
				toAddelement!.position.y = /* fit to stage, and random y range */
					(gameStageYAxis - toAddelement!.size.height) + (CGFloat(80 + Double(Float(arc4random()) / Float(UINT32_MAX)) * 18) * DeviceManager.scrRatioC)
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_AI
				
				toAddelement!.elementSpeed = 1.8 //속도.
				toAddelement!.motions_current = 0
				toAddelement!.motions_walking = gameTexturesAIJFlyTexturesArray
				toAddelement!.elementFlag = 6 //고정형 및 형태변경. 좀 일찍.
				break
			case 11:
				//이번엔.. 반대로 달리는 미친놈..
				toAddelement = JumpUpElements() //텍스쳐는 모션으로 정할 것임.
				toAddelement!.size = CGSize( width: 85 * DeviceManager.scrRatioC , height: 95 * DeviceManager.scrRatioC )
				toAddelement!.elementType = JumpUpElements.TYPE_DYNAMIC_ENEMY
				toAddelement!.position.x = -toAddelement!.size.width / 2 //왼쪽에서 시작
				/* y fit to bottom of stage */
				toAddelement!.position.y = gameStageYFoot + (toAddelement!.size.height / 2) + (48 * DeviceManager.scrRatioC)
				toAddelement!.elementSpeed = -1.6 //속도. -로하면 반대로 감
				toAddelement!.xScale = -1
				toAddelement!.ySpeed = 10 * max(1, CGFloat(gameGravity / 1.3)) //약간 점프한 상태
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_AI
				
				toAddelement!.motions_current = 0
				toAddelement!.motions_walking = gameTexturesAILeftTexturesArray
				toAddelement!.motions_jumping = gameTexturesAIJLeftTexturesArray
				toAddelement!.elementFlag = 7 //반대로 달리는 장애물.
				break
			case 10000: //AI 폭발 효과
				toAddelement = JumpUpElements()
				toAddelement!.elementType = JumpUpElements.TYPE_EFFECT
				toAddelement!.size = CGSize( width: 150 * DeviceManager.scrRatioC , height: 150 * DeviceManager.scrRatioC )
				toAddelement!.position.x = posX //정해진 위치로
				toAddelement!.position.y = posY
				
				//약간의 위치조정.
				toAddelement!.elementTargetPosFix = CGSize( width: 0, height: 10 * DeviceManager.scrRatioC )
				toAddelement!.elementTargetElement = targetElement
				
				if (targetElement == nil) {
					print("effect target is null.")
				}
				
				toAddelement!.elementSpeed = 0 //타겟이 정해져있는경우 타겟에 맞춰서 움직일테니.
				toAddelement!.motions_current = 2 //폭발효과는 2번
				toAddelement!.motions_effect = gameTexturesAIEffectsArray[0] //텍스쳐 배열의 텍스쳐 배열 (이중배열)
				break
			case 10001: //그림자. 뭐 빠름을 느끼게 할때나 쓰임
				toAddelement = JumpUpElements()
				toAddelement!.elementType = JumpUpElements.TYPE_SHADOW
				toAddelement!.size = targetElement!.size
				toAddelement!.position.x = targetElement!.position.x
				toAddelement!.position.y = targetElement!.position.y
				
				toAddelement!.elementSpeed = 0
				toAddelement!.motions_current = -1 //모션없음
				toAddelement!.texture = targetElement!.texture //그 순간의 모션이기 때문에 텍스쳐 박제
				break;
			case 10002,10006,10007: //작은(tiny 1/2/3) 그림자
				switch( elementType ) {
					case 10002: //tiny 0
						toAddelement = JumpUpElements( texture: gameNodesTexturesArray[10] )
						toAddelement!.size = CGSize( width: 44 * DeviceManager.scrRatioC, height: 28 * DeviceManager.scrRatioC )
						break
					case 10006: //tiny 1
						toAddelement = JumpUpElements( texture: gameNodesTexturesArray[13] )
						toAddelement!.size = CGSize( width: 48 * DeviceManager.scrRatioC, height: 32 * DeviceManager.scrRatioC )
						break
					case 10007: //tiny 2
						toAddelement = JumpUpElements( texture: gameNodesTexturesArray[14] )
						toAddelement!.size = CGSize( width: 68 * DeviceManager.scrRatioC, height: 32 * DeviceManager.scrRatioC )
						break
					default: break;
				} //end sel elementtype
					
				toAddelement!.elementType = JumpUpElements.TYPE_EFFECT
				toAddelement!.position.x = posX
				toAddelement!.position.y = posY
				//약간의 위치조정.
				toAddelement!.elementTargetPosFix = CGSize( width: 0, height: 0 )
				toAddelement!.elementTargetElement = targetElement
				
				if (targetElement == nil) {
					print("effect target is null.")
				}
				
				toAddelement!.elementSpeed = targetElement!.elementSpeed //follow original target element speed
				toAddelement!.motions_current = -1 //그림자는 모션없음
				toAddelement!.elementFlag = 0
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_SHADOW
				targetElement!.removeFromParent()
				addTargetChild = true
				break;
			case 10003: //캐릭터 전용(tiny) 그림자
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[10] )
				toAddelement!.elementType = JumpUpElements.TYPE_EFFECT
				toAddelement!.size = CGSize( width: 44 * DeviceManager.scrRatioC, height: 28 * DeviceManager.scrRatioC )
				toAddelement!.position.x = posX
				toAddelement!.position.y = posY
				
				//약간의 위치조정.
				toAddelement!.elementTargetPosFix = CGSize( width: 0, height: 0/* * DeviceManager.scrRatioC*/ )
				toAddelement!.elementTargetElement = targetElement
				
				if (targetElement == nil) {
					print("effect target is null.")
				}
				
				toAddelement!.elementSpeed = targetElement!.elementSpeed //follow original target element speed
				toAddelement!.motions_current = -1 //그림자는 모션없음
				
				//거꾸로 가는 캐릭터였으면 오른쪽에서 없어지게
				if (targetElement!.elementFlag == 7) {
					toAddelement!.elementFlag = 7
				} else {
					toAddelement!.elementFlag = 0
				}
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_SHADOW
				targetElement!.removeFromParent()
				addTargetChild = true
				break
			case 10004: //큰 그림자 (주로 구름 밑) big
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[12] )
				toAddelement!.elementType = JumpUpElements.TYPE_EFFECT
				toAddelement!.size = CGSize( width: 168.8 * DeviceManager.scrRatioC, height: 56.25 * DeviceManager.scrRatioC )
				toAddelement!.position.x = posX
				toAddelement!.position.y = gameStageYFoot + (toAddelement!.size.height / 2) //big, small구름은 땅에박음
				
				//약간의 위치조정.
				toAddelement!.elementTargetPosFix = CGSize( width: 0, height: 0 )
				toAddelement!.elementTargetElement = targetElement
				
				if (targetElement == nil) {
					print("effect target is null.")
				}
				
				toAddelement!.elementSpeed = targetElement!.elementSpeed //follow original target element speed
				toAddelement!.motions_current = -1 //그림자는 모션없음
				toAddelement!.elementFlag = 0
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_SHADOW
				targetElement!.removeFromParent()
				addTargetChild = true
				break
			case 10005: //Shadow (small)
				toAddelement = JumpUpElements( texture: gameNodesTexturesArray[12] )
				toAddelement!.elementType = JumpUpElements.TYPE_EFFECT
				toAddelement!.size = CGSize( width: 104.5 * DeviceManager.scrRatioC, height: 36.15 * DeviceManager.scrRatioC )
				toAddelement!.position.x = posX
				toAddelement!.position.y = gameStageYFoot + (toAddelement!.size.height / 2) //big, small구름은 땅에박음
				
				//약간의 위치조정.
				toAddelement!.elementTargetPosFix = CGSize( width: 0, height: 0 )
				toAddelement!.elementTargetElement = targetElement
				
				if (targetElement == nil) {
					print("effect target is null.")
				}
				
				toAddelement!.elementSpeed = targetElement!.elementSpeed //follow original target element speed
				toAddelement!.motions_current = -1 //그림자는 모션없음
				toAddelement!.elementFlag = 0
				
				toAddelement!.elementStyleType = JumpUpElements.STYLE_SHADOW
				targetElement!.removeFromParent()
				addTargetChild = true
				break
			//10007까지 있음. (위에 10002에서 씀)
			default: break
		} //end switch [ElementType]
		
		if (ignoresForceZPosition == false) {
			toAddelement!.zPosition = 1 //behind of character
		} else {
			toAddelement!.zPosition = 3 //front of character
		} //end if [zPosition ignores or not]
		mapObject.addChild(toAddelement!)
		if (addTargetChild) { //Target Child
			mapObject.addChild(targetElement!)
		} //end if [targetchlid add or not]
		
		gameNodesArray += [toAddelement]
		
		//그림자 생성 할 물건이 있으면 함
		switch(elementType){
			case 0,6,7: //cloud. 구름 종류에 따른 그림자 변형
				switch(tmpCloudNumber) {
					case 0,3,4: //big
						addNodes( 10004, posX: toAddelement!.position.x, posY: toAddelement!.position.y, targetElement: toAddelement! )
						break
					case 1, 2: //small
						addNodes( 10005, posX: toAddelement!.position.x, posY: toAddelement!.position.y, targetElement: toAddelement! )
						break
					default: break;
				} //end switch [Cloud]
				break
			case 2,3: //boxes
				addNodes( 10006, posX: toAddelement!.position.x, posY: toAddelement!.position.y, targetElement: toAddelement! )
				break
			case 1,8: //traps
				addNodes( 10007, posX: toAddelement!.position.x, posY: toAddelement!.position.y, targetElement: toAddelement! )
				break
			case 4,5,9,10,11: //shadow for chars
				addNodes( 10003, posX: toAddelement!.position.x, posY: toAddelement!.position.y, targetElement: toAddelement! )
				break
			default: break
		} //end switch [ElementType]
	} //end func [Add]
	
	////////////////////////////////
	func gameRestartWithAD() {
		//광고가 캐릭터를 살린 경우
		uiContents!.hideUISelectionWindow()
		uiContents!.toggleMenu(false)
		
		isGameFinished = false
		scoreGameLife = maxScoreGameLife - 1
		gameCharacterUnlimitedLife = 300 //부활 무적시간
		gameCharacterRetryADScoreTerm = 300 //이 무적시간동안은 스코어 증가 없음
	} //end func
	
	func gameOverRutine() {
		//게임오버 처리 *use only UI available*
		//메뉴 제거, 게임 끝, 일시정지는 해제한 상태로.
		isMenuVisible = false
		isGameFinished = true
		isGamePaused = false
		uiContents!.menuPausedOverlay.isHidden = false //오버레이는 띄움
		
		//Gameover effect
		SoundManager.playEffectSound( SoundManager.bundleEffectsGeneralGame.Gameover.rawValue )
		//pause bgm
		SoundManager.pauseResumeBGMSound( false )
		
		//게임오버 창 띄우기
		externalLifeLeft -= 1
		if (externalLifeLeft == 0) {
			//완전 게임오버
			uiContents!.showUISelectionWindow( 3 )
		} else {
			//컨티뉴 게임오버
			uiContents!.showUISelectionWindow( 2 )
		} //end if [Life over]
	} ////// 끝
	
	////////////////////////////////
	override func updateWithSeconds() {
		super.updateWithSeconds()
		
		if (gameScore <= 0) { //If game is over
			//Game guide animation
			gameAlarmGuidesNodesArray[0].run( SKAction.fadeOut(withDuration: 0.5) )
			gameAlarmGuidesNodesArray[1].run( SKAction.fadeOut(withDuration: 0.5) )
		} else { //If game not over
			// ~ empty
		} //end if [UserTime to zero or not]
		
		//포기 버튼을 띄워야하면 띄움. (시간도 계산함) 점프횟수가 60번을 넘어야함
		if (gameRetireTimeCount >= gameRetireTime && buttonRetireSprite.alpha == 0) {
			if (gameUserJumpCount > 60) { /// 점프 카운트 60번 이상일 때부터 띄움.
				print("Showing retire button")
				buttonRetireSprite.alpha = 1
				let moveEffect = SKTMoveEffect(node: buttonRetireSprite, duration: 0.5 ,
					startPosition: CGPoint( x: buttonRetireSprite.position.x, y: buttonRetireSprite.position.y ),
					endPosition: CGPoint( x: buttonRetireSprite.position.x, y: buttonYAxis)
					)
				moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut
				buttonRetireSprite.run(
					SKAction.actionWithEffect(moveEffect))
				
				//Game guide animation
				gameAlarmGuidesNodesArray[0].run( SKAction.fadeOut(withDuration: 0.5) )
				gameAlarmGuidesNodesArray[1].run( SKAction.fadeOut(withDuration: 0.5) )
			} //end if [user jumped a lot or not]
		} //end if [Retire show or not]
	} // end func [Update per 1 seconds]
	
	//////// touch evt handler
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location:CGPoint = (touch as UITouch).location(in: self)
			touchesLatestPoint.x = location.x
			touchesLatestPoint.y = location.y
			
			let chkButtonName:SKNode = self.atPoint(location)
			if (chkButtonName.name == "button_retire" || chkButtonName.name == "button_alarm_off") {
				//포기 버튼일 때 혹은 알람끄기 일 때
				//포기 버튼을 눌렀는지의 여부 체크.
				statsGameIsFailed = chkButtonName.name == "button_retire" ? true : false
				exitJumpUPGame()
			} else { //기타 터치: 터치 통계값 추가
				statsGameTouchCount += 1
				if (isGameFinished == false) { //게임이 진행중일 때만 점프 가능.
					if (characterElement!.jumpFlaggedCount < 2) { //캐릭터 점프횟수 제한
						//알람 모드에서 가이드 효과
						if (gameStartupType == .AlarmMode) {
							let scaleEffect = SKTScaleEffect(node: gameAlarmGuidesNodesArray[characterElement!.jumpFlaggedCount], duration: 0.5, startScale: CGPoint(x: 1.4, y: 1.4), endScale: CGPoint(x: 1, y: 1))
							scaleEffect.timingFunction = SKTTimingFunctionCircularEaseOut
							gameAlarmGuidesNodesArray[characterElement!.jumpFlaggedCount].run(
								SKAction.actionWithEffect(scaleEffect))
						} //end if [is AlarmMode or not]
						//Jump character
						characterElement!.ySpeed = CGFloat(characterJumpPower) * max(1, CGFloat(gameGravity / 1.5))
						characterElement!.jumpFlaggedCount += 1
						gameUserJumpCount += 1 //점프 횟수 카운트
						
						switch(characterElement!.jumpFlaggedCount) {
							case 1: //1단 점프시 효과음
								SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.CharacterJump.rawValue )
								break
							case 2: //2단 점프시 효과음
								SoundManager.playEffectSound( SoundManager.bundleEffectsJumpUP.CharacterDoubleJump.rawValue )
								break
							default: break
						} //end switch
						
						//통계값 추가 (유효터치)
						statsGameValidTouchCount += 1
					} //end if [Jump count limit]
				} //end if [Game finished or not]
			} //end if [touched button or not]
		} //end for
		super.touchesBegan(touches, with:event)
	} //end func [Touch handling]
	
	//////////////////////////////////
	//// UI Handler / Callback
	func gameForceStopCallb() {
		//강제 게임 정지의 경우 result 없이 바로 메인으로
		forceExitGame( false )
	} //end func ForceStop Callback
	func gameOverCallb() {
		//게임오버의 경우 게임오버 루틴으로.
		forceExitGame( true )
	} //end func Force Exit Handler
	func gameRestartCallb() {
		restartGame()
	} //end func RestartGame handler
	func gameADWatchCallb() {
		//광고 보고 게임 이어하기 기능
		SoundManager.pauseResumeBGMSound( false )
		UnityAdsManager.showUnityAD(GameModeView.jumpUPStartupViewController!, placementID: UnityAdsManager.PlacementAds.gameContinueAD.rawValue, callbackFunction: gameADWatchFinishedCallback, showFailCallbackFunction: gameADLoadErrorCallback)
	} //end func GameAD Show button handler
	func gameADWatchFinishedCallback() {
		print("AD Finished")
		SoundManager.pauseResumeBGMSound( true )
		gameRestartWithAD()
	} //end func AD Finished Callback
	func gameADLoadErrorCallback() {
		//광고 불러오기가 불가능할 때
		
		/// 게임 모드에서 실행하는 것이므로,
		if ( GameModeView.jumpUPStartupViewController != nil ) {
			let alertWindow:UIAlertController = UIAlertController(title: LanguagesManager.$("generalAlert"), message: LanguagesManager.$("generalCheckInternetConnection"), preferredStyle: UIAlertControllerStyle.alert)
			alertWindow.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
			}))
			
			GameModeView.jumpUPStartupViewController!.present(alertWindow, animated: true, completion: nil)
		} //end if
		
	} //end func
	
	//////////////////////////////////
	
	// 게임모드에서의 강제 게임 종료 루틴.
	func forceExitGame( _ showResultWindow:Bool = false ) {
		print("Game exiting")
		isGameFinished = true
		GameModeView.isGameExiting = true //재시작시엔 이게 false이면, 다시 appear가 발동함
		
		SoundManager.stopBGMSound()
		
		GameModeView.selfView!.dismiss(animated: false, completion: nil)
		ViewController.selfView!.showHideBlurview(true)
		GlobalSubView.gameModePlayViewcontroller.dismiss(animated: true, completion: { _ in
			if (showResultWindow == true) { //<- Result화면 이동은 게임을 마쳤다는 소리임
				// Result 표시.
				if (self.gameScore != 0) {
					// 게임 스코어를 저장함.
					GameManager.saveBestScore(self.currentGameID /* JumpUP GameID */, score: self.gameScore)
				} //end if [GameScore is 0 or not]
				
				ViewController.selfView!.showGameResult( self.currentGameID /* <- jumpup gameid */ , type: 1 /* game type */,
					score: self.gameScore, best: GameManager.loadBestScore(0) /* load jumpup bestscore */)
			} else { //게임 목록의 점프업 화면까지 바로 표시
				ViewController.selfView!.openGamePlayView(nil)
				GamePlayView.selfView!.selectCell( self.currentGameID ) //<- gameid
				
				//패드에서 가끔 방향이 안 맞아서 설정함.
				ViewController.selfView!.fitViewControllerElementsToScreen( false )
			} //end if [Show result or not]
		})
	} //end func [force Exit]
	//게임 재시작 루틴.
	func restartGame() {
		print("Game restarting")
		isGameFinished = true
		GameModeView.isGameExiting = false
		GameModeView.jumpUPStartupViewController!.dismiss(animated: false, completion: nil)
	} //end func
	
	//게임 포기 혹은 종료.
	func exitJumpUPGame() {
		print("Game finished")
		
		isGameFinished = true
		SoundManager.stopBGMSound()
		
		/// .. and send result for tracking.
		AnalyticsManager.sendGameResults(currentGameID,
		                                 isAlarm: gameStartupType == .AlarmMode ? true : false,
		                                 startTime: statsGameStartedTimeStamp,
		                                 endTime: statsGameFinishedTimeStamp,
		                                 diedCount: statsGameDiedCount,
		                                 touchTotal: statsGameTouchCount,
		                                 validTotal: statsGameValidTouchCount)
		
		let nextfieInSeconds:Int = AlarmManager.getNextAlarmFireInSeconds()
		let nextAlarmLeft:Int = nextfieInSeconds == -1 ? -1 : (nextfieInSeconds - Int(Date().timeIntervalSince1970))
		if (abs(nextAlarmLeft) > AlarmManager.alarmForceStopAvaliableSeconds) {
			//알람 해제 1시간이 지나버린 경우엔 기록을 남기지 않음
		} else { //// 알람으로 켜진 경우에만 로그를 남김
			if (gameStartupType == .AlarmMode) {
				logAlarmGame()
			} // end if
		} //end if [1 hour pass check]
		
		if (gameStartupType == .AlarmMode) { //알람으로 켜진 경우 확장팩 결제를 검사하여, 결제되지 않은경우 광고를 보여줌
			AlarmRingView.selfView!.ignoresActiveSound = true
			if (PurchaseManager.purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] == true) {
				//확장팩 결제함
				alarmADFinishedCallback()
			} else {
				//광고 보고 가실게요!
				UnityAdsManager.showUnityAD(AlarmRingView.jumpUPStartupViewController!, placementID: UnityAdsManager.PlacementAds.alarmFinishAD.rawValue, callbackFunction: alarmADFinishedCallback, showFailCallbackFunction: alarmOffWithoutADsCallback)
			} //end if [Purchase]
		} //end if [gameStartupType]
		
	} //end func exit
	
	func alarmOffWithoutADsCallback() {
		print("No ads presented because ads not ready.")
		alarmADFinishedCallback()
	} //end func
	
	func alarmADFinishedCallback() {
		//광고 본 후의 알람 해제 및 화면 이동
		//확장팩 결제의 경우 바로 이쪽으로 넘어옴.
		
		AlarmManager.gameClearToggle( Date(), cleared: true )
		
		AlarmManager.mergeAlarm() //Merge it
		AlarmManager.alarmRingActivated = false
		
		AlarmRingView.selfView!.dismiss(animated: false, completion: nil)
		GlobalSubView.alarmRingViewcontroller.dismiss(animated: true, completion: nil)
		
	} //end func
	
} //end of class
