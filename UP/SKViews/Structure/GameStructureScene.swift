//
//  GameStructureScene.swift
//  UP
//
//  Created by ExFl on 2016. 10. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import SpriteKit;
import SQLite;

class GameStructureScene:SKScene {
	
	let MATHPI:CGFloat = 3.141592;
	
	//Game ID
	var currentGameID:Int = 0; //Change it in subclass
	
	//게임 실행 타입 (0= 알람, 1= 메인화면 실행)
	var gameStartupType:Int = 0;
	
	//score (혹은 time으로 사용.)
	var gameScore:Int = 0; var gameScoreStr:String = "";
	var isGamePaused:Bool = true; //일시정지된 경우.
	var gameFinishedBool:Bool = false; // 게임이 완전히 끝나면 타이머 다시 늘어나는 등의 동작 없음
	
	//Touch handling (this class only handles swipe gesture check)
	var swipeTouchLayer:SKSpriteNode = SKSpriteNode(color: UIColor.white, size: CGSize(width: 0,height: 0));
	var touchesLatestPoint:CGPoint = CGPoint(x: 0, y: 0);
	var swipeGestureMoved:CGFloat = 0; //위 혹은 아래로 이동한 양. 순식간에 사라지도록 해야함
	var swipeGestureValid:CGFloat = 50 * DeviceManager.maxScrRatioC; //이동한 양에 대한 허용치. scrRatioC로만 하면 패드에서 힘들어질듯
	
	//Preloader
	var preloadCompleteCout:Int = 0;
	var preloadCurrentCompleted:Int = 0;
	var preloadCompleteHandler:(() -> Void)? = nil;
	
	
	//////////////////////////UI Menu
	var uiContents:GeneralMenuUI?;
	var isMenuVisible:Bool = true; //알파 효과를 위함
	
	/////// 통계를 위한 데이터 변수
	
	//아래 시작 종료 시간의 경우, 통계시에는 게임 시작까지 걸린 시간 / 게임 진행 시간으로 재집계
	var statsGameStartedTimeStamp:Int = 0; //게임 시작 시간
	var statsGameFinishedTimeStamp:Int = 0; //게임 종료 시간
	
	var statsGameDiedCount:Int = 0; //맞은 횟수
	var statsGameIsFailed:Bool = false; //리타이어한 경우
	var statsGameTouchCount:Int = 0; //전체 터치 횟수
	var statsGameValidTouchCount:Int = 0; //유효 터치 횟수
	
	
	///////////// functions
	
	func preloadEventCall() {
		preloadCurrentCompleted += 1;
		print("Preload status:", preloadCurrentCompleted,"/",preloadCompleteCout);
		if (preloadCurrentCompleted >= preloadCompleteCout) {
			if (preloadCompleteHandler != nil) {
				preloadCompleteHandler!();
			}
		}
	}
	
	
	////
	
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
