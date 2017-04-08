//
//  GameTitleViewJumpUP.swift
//  UP
//
//  Created by ExFl on 2016. 2. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit
import Gifu

class GameTitleViewJumpUP:UIViewController {
	
	//Loading indicator
	var loadingIndicatorView:GIFImageView?
	
	//Game title (red, white, skyblue)
	var gameTitleLabel:UILabel = UILabel()
	var gameTitleRedLabel:UILabel = UILabel()
	var gameTitleSkyblueLabel:UILabel = UILabel()
	
	var gameThumbnailsBackgroundImage:UIImageView = UIImageView()
	var gameThumbnailsImage:UIImageView = UIImageView()
	
	//Start button
	var gameStartButtonImage:UIImageView = UIImageView()
	//Auto-start in GameMode
	var gameAutostartCountdownText:UILabel = UILabel()
	
	//SKView (Game view) and game scene
	var gameView:SKView = SKView()
	var jumpUPGameScene:JumpUPGame?
	
	let gameTitleLabelYAxis:CGFloat = 128 * DeviceManager.scrRatioC
	let gameThumbsSize:CGFloat = 180 * DeviceManager.maxScrRatioC
	
	//게임 모드 타입 체크
	var gameStartupType:GameManager.GameType = .AlarmMode
	
	var aStartTimer:Timer? //자동 게임시작 카운트다운 타이머
	var aPreloadCheckTimer:Timer? //Preload check timer
	
	var aStartLeft:Int = 3
	
	var preloadCompleted:Bool = false
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.black //black col
		
		loadingIndicatorView = GIFImageView()
		
		loadingIndicatorView!.animate(withGIFNamed: "comp-loading-preloader.gif")
		self.view.addSubview(loadingIndicatorView!)
		
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if (jumpUPGameScene != nil) {
			return;
		}
		
		loadingIndicatorView!.frame =  CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 24, height: 24)
		loadingIndicatorView!.center = self.view!.center
		loadingIndicatorView!.contentMode = .scaleAspectFit
		
		loadingIndicatorView!.isHidden = false
		print("JumpUP gameview appear event")
		
		//View load func
		gameTitleLabel.text = LanguagesManager.$("gameNameJumpUP")
		gameTitleLabel.font = UIFont.systemFont(ofSize: 38)
		gameTitleLabel.frame = CGRect( x: 0, y: gameTitleLabelYAxis, width: self.view.frame.width, height: 38 )
		gameTitleLabel.textColor = UIColor.white
		gameTitleLabel.textAlignment = .center
		
		gameTitleRedLabel.font = gameTitleLabel.font; gameTitleRedLabel.text = gameTitleLabel.text
		gameTitleRedLabel.frame = CGRect( x: -1.5, y: gameTitleLabelYAxis, width: gameTitleLabel.frame.width, height: gameTitleLabel.frame.height )
		gameTitleRedLabel.textColor = UPUtils.colorWithHexString("#FF0000")
		gameTitleRedLabel.textAlignment = gameTitleLabel.textAlignment
		gameTitleSkyblueLabel.font = gameTitleLabel.font; gameTitleSkyblueLabel.text = gameTitleLabel.text
		gameTitleSkyblueLabel.frame = CGRect( x: 1.5, y: gameTitleLabelYAxis, width: gameTitleLabel.frame.width, height: gameTitleLabel.frame.height )
		gameTitleSkyblueLabel.textColor = UPUtils.colorWithHexString("#00FFFF")
		gameTitleSkyblueLabel.textAlignment = gameTitleLabel.textAlignment
		
		self.view.addSubview(gameTitleRedLabel)
		self.view.addSubview(gameTitleSkyblueLabel)
		self.view.addSubview(gameTitleLabel)
		/////
		
		gameThumbnailsBackgroundImage.image = UIImage( named: "game-thumb-background.png" )
		gameThumbnailsImage.image = UIImage( named: "game-thumb-jumpup.png" )
		
		gameThumbnailsBackgroundImage.frame = CGRect( x: self.view.frame.width / 2 - gameThumbsSize / 2, y: self.view.frame.height / 2 - gameThumbsSize / 2, width: gameThumbsSize, height: gameThumbsSize)
		gameThumbnailsImage.frame = gameThumbnailsBackgroundImage.frame
		
		self.view.addSubview(gameThumbnailsBackgroundImage)
		self.view.addSubview(gameThumbnailsImage)
		
		//start btn add.
		gameStartButtonImage.image = UIImage( named: "game-general-start.png" )
		gameStartButtonImage.frame = CGRect( x: self.view.frame.width / 2 - (242.05 * DeviceManager.maxScrRatioC) / 2, y: self.view.frame.height - (70.75 * DeviceManager.maxScrRatioC) - (86 * DeviceManager.maxScrRatioC), width: 242.05 * DeviceManager.maxScrRatioC, height: 70.75 * DeviceManager.maxScrRatioC )
		
		let gameStartGesture:UITapGestureRecognizer = UITapGestureRecognizer()
		gameStartGesture.addTarget(self, action: #selector(GameTitleViewJumpUP.gameStartFuncTapHandler(_:)))
		gameStartButtonImage.addGestureRecognizer(gameStartGesture)
		
		self.view.addSubview(gameStartButtonImage)
		gameStartButtonImage.isUserInteractionEnabled = true
		
		//Auto-count Add. (게임모드일때만 보임)
		gameAutostartCountdownText.text = String(aStartLeft)
		gameAutostartCountdownText.font = UIFont.systemFont(ofSize: 38)
		gameAutostartCountdownText.frame = CGRect( x: 0,
		                                               y: self.view.frame.height - (48 * DeviceManager.maxScrRatioC) - (86 * DeviceManager.maxScrRatioC)
		                                               , width: self.view.frame.width, height: 38 );
		gameAutostartCountdownText.textColor = UIColor.white
		gameAutostartCountdownText.textAlignment = .center
		self.view.addSubview(gameAutostartCountdownText)
		
		if (gameStartupType == .AlarmMode) {
			gameAutostartCountdownText.isHidden = true
			gameStartButtonImage.isHidden = true //set to false when preload finish
		} else {
			gameStartButtonImage.isHidden = true
		} //end if [is AlarmMode]
		
		///////
		self.gameTitleLabel.alpha = 0; self.gameTitleRedLabel.alpha = 0; self.gameTitleSkyblueLabel.alpha = 0;
		self.gameThumbnailsBackgroundImage.alpha = 0; self.gameThumbnailsImage.alpha = 0;
		self.gameStartButtonImage.alpha = 0; self.gameAutostartCountdownText.alpha = 0;
		
		//Auto-init (for loading resources)
		jumpUPGameScene = JumpUPGame( size: CGSize( width: self.view.frame.width, height: self.view.frame.height ) )
		jumpUPGameScene!.preloadCompleteHandler = gamePreloadCompleted
		jumpUPGameScene!.scaleMode = SKSceneScaleMode.resizeFill
		jumpUPGameScene!.gameStartupType = gameStartupType
		
		gameView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		gameView.presentScene(jumpUPGameScene!)
		
		print("Auto init end")
		
		aPreloadCheckTimer = UPUtils.setInterval(0.5, block: preloadCheckTimer)
		super.viewDidAppear(animated)
	} //end func
	
	//외부에서 실행되는 함수라 그런지 뷰 알파 애니메이션 등등이 지연이 심함. 따라서 아래처럼만 사용함
	func gamePreloadCompleted() {
		if (preloadCompleted) {
			return
		}
		
		preloadCompleted = true
	}
	
	func preloadCheckTimer() {
		if (!preloadCompleted) {
			return
		}
		
		//Play bgm sound if alarm mode
		if (gameStartupType == .AlarmMode) {
			SoundManager.playBGMSound(SoundManager.bundleSounds.GameReadyBGM.rawValue, repeatCount: -1)
			gameStartButtonImage.isHidden = false //Start hidden false
		} else { //Start auto 3-2-1 counter in Game Mode
			aStartTimer = UPUtils.setInterval(1, block: autoGameStartTimer)
		} //end if [Alarm mode or game mode]
		
		//View fade-in effect
		loadingIndicatorView!.isHidden = true
		
		UIView.animate(withDuration: 0.5, animations: {
			self.gameTitleLabel.alpha = 1; self.gameTitleRedLabel.alpha = 1; self.gameTitleSkyblueLabel.alpha = 1;
			self.gameThumbnailsBackgroundImage.alpha = 1; self.gameThumbnailsImage.alpha = 1;
			self.gameAutostartCountdownText.alpha = 1; self.gameStartButtonImage.alpha = 1;
		}, completion: {_ in
		
		});
		
		if (aPreloadCheckTimer != nil) {
			aPreloadCheckTimer!.invalidate()
			aPreloadCheckTimer = nil
		} //end func
	} //end if
	
	//자동 시작 타이머
	func autoGameStartTimer( ) {
		print("timer running")
		
		aStartLeft -= 1
		
		gameAutostartCountdownText.text = String(aStartLeft)
		if (aStartLeft <= 0) {
			// 타이머 정지 및 시작
			SoundManager.playEffectSound( SoundManager.bundleEffectsGeneralGame.CountdownStart.rawValue )
			if (aStartTimer != nil) {
				aStartTimer!.invalidate()
				aStartTimer = nil
			}
			gameStartFuncTapHandler(nil)
		} else { // 3, 2, 1 사운드 재생
			SoundManager.playEffectSound( SoundManager.bundleEffectsGeneralGame.Countdown.rawValue )
		} //end if
	} //end func
	
	func gameStartFuncTapHandler( _ recognizer: UITapGestureRecognizer! ) {
		//Game start
		print("Presenting game view")
		
		////////테스트 전용.
		#if DEBUG
			gameView.showsFPS = true //fps view
			gameView.showsDrawCount = true
			gameView.showsNodeCount = true
		#endif
		
		//vvvvv 사용 시 메모리 누수가 있음.. ㅡㅡ;;
		//gameView.showsFields = true;
		//////////////
		
		self.view.addSubview(gameView)
		
		//Gameview alpha transition
		gameView.alpha = 0
		jumpUPGameScene!.isGamePaused = false
		
		// play bgm sound
		SoundManager.playBGMSound(SoundManager.bundleSounds.GameJumpUPBGM.rawValue, repeatCount: -1)
		
		UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
			self.gameView.alpha = 1
			}, completion: {_ in
		});
		
	} //end start func
	
	override func viewWillDisappear(_ animated: Bool) {
		//UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;
		if (gameStartupType == .AlarmMode) {
			AlarmRingView.selfView!.disposeView()
		}
		super.viewWillDisappear(animated)
	} //end func
		
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	} //end func
	
	
	//Lock
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		//Lock it to Portrait
		return .portrait
	}
} //end class
