//
//  GameStructureScene.swift
//  UP
//
//  Created by ExFl on 2016. 10. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import SpriteKit
import SQLite

class GameStructureScene:SKScene {
	//게임 기본 구조체 ////////////////
	/////////////////////////////////
	
	
	let MATHPI:CGFloat = 3.141592
	
	//Game ID
	var currentGameID:Int = 0 //Change it in subclass
	
	//게임 실행 타입 (0= 알람, 1= 메인화면 실행)
	var gameStartupType:GameManager.GameType = .AlarmMode
	
	//score (혹은 time으로 사용.)
	var gameScore:Int = 0
	var gameScoreStr:String = ""
	var isGamePaused:Bool = true //일시정지된 경우.
	var isGameFinished:Bool = false // 게임이 완전히 끝나면 타이머 다시 늘어나는 등의 동작 없음
	
	//Touch handling (this class only handles swipe gesture check)
	var swipeTouchLayer:SKSpriteNode = SKSpriteNode(color: UIColor.white, size: CGSize(width: 0,height: 0))
	var touchesLatestPoint:CGPoint = CGPoint(x: 0, y: 0)
	var swipeGestureMoved:CGFloat = 0; //위 혹은 아래로 이동한 양. 순식간에 사라지도록 해야함
	var swipeGestureValid:CGFloat = 50 * DeviceManager.maxScrRatioC //이동한 양에 대한 허용치. scrRatioC로만 하면 패드에서 힘들어질듯
	
	//Preloader
	var preloadCompleteCout:Int = 0
	var preloadCurrentCompleted:Int = 0
	var preloadCompleteHandler:(() -> Void)? = nil
	
	////////// 스코어 및 시간
	var gameScoreNm:Int = 3 //스코어 자리수. (알람=3, 일반=5)
	
	//아래는 알람으로 게임진행 중일 때 사용하는 값임
	var gameAlarmFirstGoalTime:Int = 40 // 처음 목표로 하는 시간
	var gameLevelAverageTime:Int = 20 //난이도가 높아지는 시간
	var gameTimerMaxTime:Int = 60 //알람으로 게임 진행 중일 때 시간이 추가될 수 있는 최대 수치
	var gameRetireTime:Int = 200 //포기 버튼이 나타나는 시간
	var gameRetireTimeCount:Int = 0 //포기 버튼 카운트
	
	//time 또는 score 표시 부분
	var gameScoreTitleImageTexture:SKTexture?
	var gameScoreTitleImage:SKSpriteNode?
	//time / score에 대한 숫자 관련 텍스쳐 배열
	var gameNumberTexturesArray:Array<SKTexture> = [] // 0~9 10개
	var gameNumberSpriteNodesArray:Array<SKSpriteNode> = [] //000 3개
	
	//게임 끝나거나 포기 버튼
	var buttonRetireSprite:SKSpriteNode = SKSpriteNode( texture: SKTexture( imageNamed: "game-jumpup-assets-retire.png" ) )
	var buttonAlarmOffSprite:SKSpriteNode?
	
	//게임 종료 / 포기 버튼이 생기는 Y위치
	var buttonYAxisCenter:CGFloat = 0
	var buttonYAxisPrefix:CGFloat = 0
	var buttonYAxis:CGFloat = 0
	
	//1초 tick (알람용)
	var gameSecondTickTimer:Timer?
	
	//////////////////////////UI Menu
	var uiContents:GeneralMenuUI?
	var isMenuVisible:Bool = true //알파 효과를 위함
	
	/////// 통계를 위한 데이터 변수
	
	//아래 시작 종료 시간의 경우, 통계시에는 게임 시작까지 걸린 시간 / 게임 진행 시간으로 재집계
	var statsGameStartedTimeStamp:Int = 0 //게임 시작 시간
	var statsGameFinishedTimeStamp:Int = 0 //게임 종료 시간
	
	var statsGameDiedCount:Int = 0 //맞은 횟수
	var statsGameIsFailed:Bool = false //리타이어한 경우
	var statsGameTouchCount:Int = 0 //전체 터치 횟수
	var statsGameValidTouchCount:Int = 0 //유효 터치 횟수
	
	
	///////////// functions
	
	//스코어/타임표시 생성 및 기본적인 로드
	override func didMove(to view: SKView) {
		self.backgroundColor = UIColor.black
		isGameFinished = false
		
		//time 혹은 score 추가 (실행 타입에 따라 바뀜)
		gameScoreStr = ""
		
		//컴포넌트 위치조정을 위한 값
		var movPositionY:CGFloat = 0
		var gameScoreMovPositionY:CGFloat = 0
		
		if (gameStartupType == .AlarmMode) {
			//알람으로 실행된 경우
			ALDManager.buildLevel() //Auto build level
			
			gameScoreTitleImageTexture = SKTexture( imageNamed: "game-jumpup-assets-time.png" )
			gameScoreTitleImage = SKSpriteNode( texture: gameScoreTitleImageTexture )
			
			if (UIDevice.current.userInterfaceIdiom == .phone) {
				//iPhone 전용 사이즈
				gameScoreTitleImage!.size = CGSize( width: 87.65 * DeviceManager.scrRatioC, height: 38.35 * DeviceManager.scrRatioC )
				
				//4/4s의 경우, 세로길이가 부족하므로 기존 아이폰과 다른 y위치 지정
				if (DeviceManager.isiPhone4S) {
					//4/4s fallback
					movPositionY = self.view!.frame.height - (63 * DeviceManager.scrRatioC)
				} else {
					movPositionY = self.view!.frame.height - (96 * DeviceManager.scrRatioC)
				}
				
				gameScoreMovPositionY = movPositionY - (72 * DeviceManager.scrRatioC)
			} else {
				//iPad 전용 사이즈 (고정)
				gameScoreTitleImage!.size = CGSize( width: 122.15, height: 53.35 )
				movPositionY = self.view!.frame.height - (52 * DeviceManager.scrRatioC)
				gameScoreMovPositionY = movPositionY - 94
			}
			
			//1sec tick add
			addCountdownTimerForAlarm()
		} else {
			//score
			gameScoreTitleImageTexture = SKTexture( imageNamed: "game-jumpup-assets-score.png" )
			gameScoreTitleImage = SKSpriteNode( texture: gameScoreTitleImageTexture )
			
			if (UIDevice.current.userInterfaceIdiom == .phone) {
				//iPhone 전용 사이즈
				gameScoreTitleImage!.size = CGSize( width: 135.15 * DeviceManager.scrRatioC, height: 27.45 * DeviceManager.scrRatioC )
				
				//4/4s의 경우, 세로길이가 부족하므로 기존 아이폰과 다른 y위치 지정
				if (DeviceManager.scrSize!.height <= CGFloat(480)) {
					//4/4s fallback
					movPositionY = self.view!.frame.height - (63 * DeviceManager.scrRatioC)
				} else {
					movPositionY = self.view!.frame.height - (96 * DeviceManager.scrRatioC)
				}
				
				gameScoreMovPositionY = movPositionY - (72 * DeviceManager.scrRatioC)
			} else {
				//iPad 전용 사이즈 (고정)
				gameScoreTitleImage!.size = CGSize( width: 135.15, height: 27.45 )
				movPositionY = self.view!.frame.height - (52 * DeviceManager.scrRatioC)
				gameScoreMovPositionY = movPositionY - 94
			} //end if [iPhone or not ]
		} //게임모드 / 알람모드 구분 끝
		
		//time/score 이미지 위치 조절
		gameScoreTitleImage!.position.x = self.view!.frame.width / 2
		self.addChild(gameScoreTitleImage!)
		
		//title/score 이미지 애니메이션 효과
		let moveEffect = SKTMoveEffect(node: gameScoreTitleImage!, duration: 0.5,
		                               startPosition: CGPoint( x: self.view!.frame.width / 2, y: self.view!.frame.height + gameScoreTitleImage!.frame.height / 2),
		                               endPosition: CGPoint( x: self.view!.frame.width / 2, y: movPositionY))
		moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut;
		gameScoreTitleImage!.run(SKAction.actionWithEffect(moveEffect))
		//time / score에 대한 데이터 처리
		gameScoreNm = (gameStartupType == .AlarmMode ? 3 : 5)
		
		//게임 숫자 표시용 이미지 추가
		if (gameNumberTexturesArray.count == 0) {
			for i:Int in 0 ..< 10 {
				gameNumberTexturesArray += [ SKTexture( imageNamed: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + ThemeManager.getName( ThemeManager.ThemeFileNames.DigitalClock + "-" + String(i)) ) ]
			} //0~9에 대한 숫자 데이터 텍스쳐
			for i:Int in 0 ..< gameScoreNm {
				gameNumberSpriteNodesArray += [ SKSpriteNode( texture: gameNumberTexturesArray[0] ) ]
				if (UIDevice.current.userInterfaceIdiom == .phone) { //iPhone 전용 크기 (가변)
					gameNumberSpriteNodesArray[i].size = CGSize(width: 50 * DeviceManager.scrRatioC , height: 70 * DeviceManager.scrRatioC)
					gameNumberSpriteNodesArray[i].position.y = movPositionY - (120 * DeviceManager.scrRatioC)
				} else { //iPad 전용 크기 (고정)
					gameNumberSpriteNodesArray[i].size = CGSize(width: 69.7, height: 97.4)
					gameNumberSpriteNodesArray[i].position.y = movPositionY - 120
				}
				
				gameNumberSpriteNodesArray[i].position.x =
					self.view!.frame.width / 2 - (CGFloat( (gameStartupType == .AlarmMode ? i : i - 1) ) * (gameNumberSpriteNodesArray[i].size.width + 12 * DeviceManager.maxScrRatioC))
					/* align to center */
					+ ((gameNumberSpriteNodesArray[i].size.width + 12 * DeviceManager.maxScrRatioC))
				
				self.addChild( gameNumberSpriteNodesArray[i] )
				
				//숫자 밑에서 위로 올라오는 효과 주기
				gameNumberSpriteNodesArray[i].alpha = 0
				let moveEffect = SKTMoveEffect(node: gameNumberSpriteNodesArray[i], duration: 0.5 ,
				                               startPosition: CGPoint( x: gameNumberSpriteNodesArray[i].position.x, y: movPositionY - (120 * DeviceManager.scrRatioC)),
				                               endPosition: CGPoint( x: gameNumberSpriteNodesArray[i].position.x, y: gameScoreMovPositionY));
				moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut
				
				gameNumberSpriteNodesArray[i].run(
					SKAction.group( [
						SKAction.afterDelay(
							Double((gameStartupType == .AlarmMode ? 2 : 4) - i) * 0.1, performAction: SKAction.actionWithEffect(moveEffect)
						), SKAction.fadeIn(withDuration: 0.5) ]))
				
			} //숫자 표시용 디지털 숫자 노드 3개
		} //end if [numbertextures]
		
		// 일시정지 / 재생 혹은 버그 (나와도 타이머 흐름) 방지를 위한 코드
		let nCenter = NotificationCenter.default;
		nCenter.addObserver(self, selector: #selector(self.appEnteredToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		nCenter.addObserver(self, selector: #selector(self.appEnteredToForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
		//////////////////////////////////
		
		//버튼 배치
		if (UIDevice.current.userInterfaceIdiom == .phone) {
			//아이폰 (상대크기)
			buttonRetireSprite.size = CGSize( width: 242.05 * DeviceManager.scrRatioC, height: 70.75 * DeviceManager.scrRatioC );
			if (DeviceManager.isiPhone4S == false) { //iPhone 4, 4s 이외
				buttonYAxis = buttonYAxisCenter - (128 * DeviceManager.scrRatioC)
			} else { //iPhone 4시리즈
				buttonYAxis = buttonYAxisCenter - (86 * DeviceManager.scrRatioC)
			}
		} else { //아이패드 (절대크기)
			buttonRetireSprite.size = CGSize( width: 336.75, height: 98.45 );
			buttonYAxis = buttonYAxisCenter - ((self.size.height - buttonYAxisPrefix) / 4);
		} //end if [is iPhone]
		
		///////////// 포기 버튼
		buttonRetireSprite.position.x = self.view!.frame.width / 2
		buttonRetireSprite.position.y = -buttonRetireSprite.size.height / 2 //화면 밖에 배치
		buttonRetireSprite.alpha = 0 //나옴/안나옴 플래그 대신 사용
		buttonRetireSprite.name = "button_retire"
		
		self.addChild(buttonRetireSprite)
		buttonRetireSprite.zPosition = 3
		
		
		/////////////알람끄기 버튼.
		if (PurchaseManager.purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] == true) {
			//확장팩 결제자에게는 일반 해제버튼 표시
			buttonAlarmOffSprite = SKSpriteNode( texture: SKTexture( imageNamed: "game-jumpup-assets-alram-off.png" ) )
		} else {
			//확장팩 미결제한 사람에게는 광고 그림도 같이 나오게 수정된 파일로 표시
			buttonAlarmOffSprite = SKSpriteNode( texture: SKTexture( imageNamed: "game-jumpup-assets-alarm-ad-off.png" ) )
		} //end if [isPurchased]
		
		buttonAlarmOffSprite!.size = buttonRetireSprite.size
		buttonAlarmOffSprite!.position.x = self.view!.frame.width / 2
		buttonAlarmOffSprite!.position.y = -buttonAlarmOffSprite!.size.height / 2 //화면 밖에 배치
		buttonAlarmOffSprite!.alpha = 0
		buttonAlarmOffSprite!.name = "button_alarm_off"
		
		self.addChild(buttonAlarmOffSprite!)
		buttonAlarmOffSprite!.zPosition = 3
		////////////////////////////////
		
		//터치 레이어 만들기 (스와이프)
		swipeTouchLayer.name = "touchlayer"
		swipeTouchLayer.size = CGSize( width: self.view!.frame.width, height: self.view!.frame.height )
		swipeTouchLayer.position = CGPoint( x: self.view!.frame.width / 2 , y: self.view!.frame.height / 2)
		swipeTouchLayer.alpha = 0
		swipeTouchLayer.zPosition = 2
		self.addChild(swipeTouchLayer)
		
		/////////// UI 구성 (메뉴, 가이드, 게임오버 등)
		if (gameStartupType == .GameMode) {
			uiContents = GeneralMenuUI( frame: CGRect(x: 0, y: 0, width: self.view!.frame.width, height: self.view!.frame.height ) )
			uiContents!.isUserInteractionEnabled = true
			self.view!.addSubview(uiContents!)
		} //end if
		
		/////////////////
		//Game starttime 기록
		statsGameStartedTimeStamp = Int(Date().timeIntervalSince1970)
	} //end func
	
	///////////////////////////////
	//// Background methods
	func appEnteredToBackground() { //App -> Background
		SoundManager.pauseResumeBGMSound( false )
		if (gameStartupType == .AlarmMode) {
			//알람으로 게임이 켜졌을 때 **타이머 종료 **
			if (gameSecondTickTimer != nil) {
				gameSecondTickTimer!.invalidate()
				gameSecondTickTimer = nil
			} //end check [Timer is nil]
		} else {
			//Queue pause
			if ( isGamePaused == false ) {
				togglePause()
			}
		} //[end check alarmmode]
	} //end func
	
	func appEnteredToForeground() { //Background -> Foreground
		if (gameStartupType == .AlarmMode && isGameFinished == false) {
			//알람으로 게임이 켜졌을 때, 졸거나 하는 등으로 화면이 꺼지거나 백그라운드로 나갔다 오면 시간은 리셋.
			gameScore = max(gameAlarmFirstGoalTime, gameScore) //남은 시간이 더 크면 유지
			gameRetireTimeCount = gameRetireTimeCount / 2 //리타이어 수작일수도 있으니 이거도 조절함
			if (AlarmRingView.selfView != nil) {
				AlarmRingView.selfView!.userAsleepCount += 1
			} //end if [AlarmRingView is nil]
			//리타이어 버튼이 이미 나와있는 경우, 다시 없앰
			if (buttonRetireSprite.alpha == 1) {
				let moveEffect = SKTMoveEffect(node: buttonRetireSprite, duration: 0.5 ,
				                               startPosition: CGPoint( x: buttonRetireSprite.position.x, y: buttonRetireSprite.position.y ),
				                               endPosition: CGPoint( x: buttonRetireSprite.position.x, y: -buttonRetireSprite.frame.height/2)
				)
				moveEffect.timingFunction = SKTTimingFunctionCircularEaseIn
				buttonRetireSprite.run(
					SKAction.group( [
						SKAction.actionWithEffect(moveEffect), SKAction.fadeOut(withDuration: 0.5)
						])
				)
			} //end if [Retire is showing or not]
			addCountdownTimerForAlarm() //타이머 재시작
			SoundManager.pauseResumeBGMSound( true )
		} //end if [Gametype is AlarmMode]
	} //end func
	
	////////// Timer 추가 혹은 재시작
	func addCountdownTimerForAlarm() {
		if (gameSecondTickTimer != nil) {
			gameSecondTickTimer!.invalidate()
			gameSecondTickTimer = nil
		}
		gameSecondTickTimer = UPUtils.setInterval(1, block: updateWithSeconds) //1초간 실행되는 tick
	} //end func
	
	////////////////////////////////
	func updateWithSeconds() {
		//알람 게임으로 실행되었을 때, 1초마다 주기적으로 실행되는 함수 (시간 체크시만 사용함)
		if (isGamePaused == true) {
			return //게임 일시정지 된 경우 틱 정지
		} //end if [Game paused or not]
		
		if (gameScore <= 0) { //////////// Timer 0 이하일 경우 게임 끝냄
			isGameFinished = true
			
			gameSecondTickTimer!.invalidate()
			gameSecondTickTimer = nil
			
			//게임 끝. 알람끄기 버튼 표시. 리타이어 버튼이 이미 나와있는 경우, 다시 없앰
			if (buttonRetireSprite.alpha == 1) {
				let moveEffect = SKTMoveEffect(node: buttonRetireSprite, duration: 0.5 ,
				                               startPosition: CGPoint( x: buttonRetireSprite.position.x, y: buttonRetireSprite.position.y ),
				                               endPosition: CGPoint( x: buttonRetireSprite.position.x, y: -buttonRetireSprite.frame.height/2)
				)
				moveEffect.timingFunction = SKTTimingFunctionCircularEaseIn
				buttonRetireSprite.run(
					SKAction.group( [
						SKAction.actionWithEffect(moveEffect), SKAction.fadeOut(withDuration: 0.5)])
				)
			} //end if [retire is showing]
			
			//Show off button
			buttonAlarmOffSprite!.alpha = 1
			let moveEffect = SKTMoveEffect(node: buttonAlarmOffSprite!, duration: 0.5 ,
			                               startPosition: CGPoint( x: buttonAlarmOffSprite!.position.x, y: buttonAlarmOffSprite!.position.y ),
			                               endPosition: CGPoint( x: buttonAlarmOffSprite!.position.x, y: buttonYAxis)
			)
			moveEffect.timingFunction = SKTTimingFunctionCircularEaseOut
			buttonAlarmOffSprite!.run(SKAction.actionWithEffect(moveEffect))
		} else { //게임이 아직 진행중일 경우 1초씩 빼거나 경우에 따라 처리
			if (AlarmManager.alarmSoundPlaying == true) {
				//게임 중인데 알람이 울릴 때(졸고 있을 떄) 시간이 올라가도록 함
				gameScore = min( gameScore + 1, gameTimerMaxTime)
				gameScoreTitleImage!.alpha = 0.5
			} else {
				gameScoreTitleImage!.alpha = 1
				gameScore -= 1
			} //end if [alarmSoundPlaying]
			gameRetireTimeCount = min(gameRetireTimeCount + 1, gameRetireTime) //포기 버튼을 띄워야 할 때 필요
		} //end if [Game finished or not]
		
		
	} //end if [Update per seconds]
	
	/////////////// Pause
	func togglePause() { //일시정지 상태를 "토글" 함
		isGamePaused = !isGamePaused
		uiContents!.toggleMenu( isGamePaused )
		self.isPaused = false
		if (self.view != nil) {
			self.view!.isPaused = false
		} //end if [self.view is nil or not]
	} //end func
	
	
	////////////////////////////////
	///////// Preloader 상황 전달
	func preloadEventCall() {
		preloadCurrentCompleted += 1
		print("Preload status:", preloadCurrentCompleted,"/",preloadCompleteCout)
		
		//가끔 카운트가 1 덜올라가기에, 완료 조건을 1 뺀 값으로..
		if (preloadCurrentCompleted >= preloadCompleteCout - 1) {
			if (preloadCompleteHandler != nil) {
				preloadCompleteHandler!()
			} //end if [Handler is nil]
		} //end if [Preload OK]
	} //end func
	
	
	/////////////////////////////////////////
	//Save alarm game status into database
	func logAlarmGame() {
		let currentDateTimeStamp:Int64 = Int64(Date().timeIntervalSince1970);
		statsGameFinishedTimeStamp = Int(currentDateTimeStamp);
		
		do {
			//DB -> 알람 기록 저장 (게임 시작 전까지 걸린 시간)
			try _ = DataManager.db()!.run(
				DataManager.statsTable().insert(
					//type -> 게임 로그 데이터 저장
					Expression<Int64>("type") <- Int64(DataManager.statsType.TYPE_ALARM_START_TIME),
					Expression<Int64>("date") <- currentDateTimeStamp,
					Expression<Int64?>("statsDataInt") <-
						Int64(statsGameStartedTimeStamp - Int(AlarmManager.getAlarm(AlarmRingView.selfView!.currentAlarmElement!.alarmID)!.alarmFireDate.timeIntervalSince1970))
					/* 게임 시작까지 걸린 시간 (시작시간 - 현재 울리고있는 알람의 알람 발생 시각) */
				)
			); //end try
			
			//DB -> 알람 기록 저장 (게임 플레이 시간)
			try _ = DataManager.db()!.run(
				DataManager.statsTable().insert(
					//type -> 게임 로그 데이터 저장
					Expression<Int64>("type") <- Int64(DataManager.statsType.TYPE_ALARM_CLEAR_TIME),
					Expression<Int64>("date") <- currentDateTimeStamp,
					Expression<Int64?>("statsDataInt") <-
						Int64(statsGameFinishedTimeStamp - statsGameStartedTimeStamp)
					/* 게임 플레이 경과시간 */
				)
			); //end try
			
			//DB -> 게임 기록 저장
			try _ = DataManager.db()!.run(
				DataManager.gameResultTable().insert(
					//통계 저장 날짜 저장 (timestamp)
					Expression<Int64>("date") <- currentDateTimeStamp, /* 데이터 기록 타임스탬프 */
					Expression<Int64>("gameid") <- Int64(self.currentGameID), /* 게임 ID */
					Expression<Int64>("gameCleared") <- (statsGameIsFailed == false ? 1 : 0), /* 클리어 여부. 1 = 클리어 */
					Expression<Int64>("startedTimeStamp") <- Int64(statsGameStartedTimeStamp), /* 게임 시작 시간 */
					Expression<Int64>("playTime") <- Int64(statsGameFinishedTimeStamp - statsGameStartedTimeStamp), /* 플레이 시간 */
					Expression<Int64>("resultMissCount") <- Int64(statsGameDiedCount), /* 뒈짓 */
					Expression<Int64>("touchAll") <- Int64(statsGameTouchCount), /* 총 터치수 */
					Expression<Int64>("touchValid") <- Int64(statsGameValidTouchCount), /* 유효 터치수 */
					Expression<Int64>("backgroundExitCount") <- Int64(AlarmRingView.selfView!.userAsleepCount) /* 존 횟수 */
				) /* insert end */
			); // run end
			
			print("DB Statement successful");
			//covertToStringArray
		} catch {
			print("DB Statement error in JumpUP");
		}
	}
	
	//// touch evt
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location:CGPoint = (touch as UITouch).location(in: self);
			//이동 거리 찍어주기
			swipeGestureMoved += touchesLatestPoint.y - location.y;
			touchesLatestPoint.x = location.x; touchesLatestPoint.y = location.y;
		}
	}
	
	
}
