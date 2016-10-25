//
//  GameTitleViewJumpUP.swift
//  UP
//
//  Created by ExFl on 2016. 2. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import SpriteKit;
import UIKit;

class GameTitleViewJumpUP:UIViewController {
	
	//Loading indicator
	var loadingIndicatorView:UIActivityIndicatorView = UIActivityIndicatorView();
	
	//Game title (red, white, skyblue)
	var gameTitleLabel:UILabel = UILabel();
	var gameTitleRedLabel:UILabel = UILabel();
	var gameTitleSkyblueLabel:UILabel = UILabel();
	
	var gameThumbnailsBackgroundImage:UIImageView = UIImageView();
	var gameThumbnailsImage:UIImageView = UIImageView();
	
	//Start button
	var gameStartButtonImage:UIImageView = UIImageView();
	//Auto-start in GameMode
	var gameAutostartCountdownText:UILabel = UILabel();
	
	//SKView (Game view) and game scene
	var gameView:SKView = SKView();
	var jumpUPGameScene:JumpUPGame?;
	
	let gameTitleLabelYAxis:CGFloat = 128 * DeviceManager.scrRatioC;
	let gameThumbsSize:CGFloat = 180 * DeviceManager.maxScrRatioC;
	
	var isGameMode:Bool = false; //알람이 아닌, 스코어가 오르는 게임 모드인 경우
	var aStartTimer:Timer?; //자동 게임시작 카운트다운 타이머
	var aStartLeft:Int = 3;
	
	var preloadCompleted:Bool = false;
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.black; //black col
		
		loadingIndicatorView.frame = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 32, height: 32);
		loadingIndicatorView.center = self.view!.center;
		loadingIndicatorView.hidesWhenStopped = false;
		loadingIndicatorView.activityIndicatorViewStyle = .white;
		self.view.addSubview(loadingIndicatorView);
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if (jumpUPGameScene != nil) {
			return;
		}
		
		loadingIndicatorView.startAnimating();
		print("JumpUP gameview appear event");
		
		//View load func
		gameTitleLabel.text = Languages.$("gameNameJumpUP");
		gameTitleLabel.font = UIFont.systemFont(ofSize: 38);
		gameTitleLabel.frame = CGRect( x: 0, y: gameTitleLabelYAxis, width: self.view.frame.width, height: 38 );
		gameTitleLabel.textColor = UIColor.white;
		gameTitleLabel.textAlignment = .center;
		
		gameTitleRedLabel.font = gameTitleLabel.font; gameTitleRedLabel.text = gameTitleLabel.text;
		gameTitleRedLabel.frame = CGRect( x: -1.5, y: gameTitleLabelYAxis, width: gameTitleLabel.frame.width, height: gameTitleLabel.frame.height );
		gameTitleRedLabel.textColor = UPUtils.colorWithHexString("#FF0000");
		gameTitleRedLabel.textAlignment = gameTitleLabel.textAlignment;
		gameTitleSkyblueLabel.font = gameTitleLabel.font; gameTitleSkyblueLabel.text = gameTitleLabel.text;
		gameTitleSkyblueLabel.frame = CGRect( x: 1.5, y: gameTitleLabelYAxis, width: gameTitleLabel.frame.width, height: gameTitleLabel.frame.height );
		gameTitleSkyblueLabel.textColor = UPUtils.colorWithHexString("#00FFFF");
		gameTitleSkyblueLabel.textAlignment = gameTitleLabel.textAlignment;
		
		self.view.addSubview(gameTitleRedLabel);
		self.view.addSubview(gameTitleSkyblueLabel); self.view.addSubview(gameTitleLabel);
		/////
		
		gameThumbnailsBackgroundImage.image = UIImage( named: "game-thumb-background.png" );
		gameThumbnailsImage.image = UIImage( named: "game-thumb-jumpup.png" );
		
		gameThumbnailsBackgroundImage.frame = CGRect( x: self.view.frame.width / 2 - gameThumbsSize / 2, y: self.view.frame.height / 2 - gameThumbsSize / 2, width: gameThumbsSize, height: gameThumbsSize);
		gameThumbnailsImage.frame = gameThumbnailsBackgroundImage.frame;
		
		self.view.addSubview(gameThumbnailsBackgroundImage); self.view.addSubview(gameThumbnailsImage);
		
		//start btn add.
		gameStartButtonImage.image = UIImage( named: "game-start-button.png" );
		gameStartButtonImage.frame = CGRect( x: self.view.frame.width / 2 - (242.05 * DeviceManager.maxScrRatioC) / 2, y: self.view.frame.height - (70.75 * DeviceManager.maxScrRatioC) - (86 * DeviceManager.maxScrRatioC), width: 242.05 * DeviceManager.maxScrRatioC, height: 70.75 * DeviceManager.maxScrRatioC );
		
		let gameStartGesture:UITapGestureRecognizer = UITapGestureRecognizer();
		gameStartGesture.addTarget(self, action: #selector(GameTitleViewJumpUP.gameStartFuncTapHandler(_:)));
		gameStartButtonImage.addGestureRecognizer(gameStartGesture);
		
		self.view.addSubview(gameStartButtonImage);
		gameStartButtonImage.isUserInteractionEnabled = true;
		
		//Auto-count Add. (게임모드일때만 보임)
		gameAutostartCountdownText.text = String(aStartLeft);
		gameAutostartCountdownText.font = UIFont.systemFont(ofSize: 38);
		gameAutostartCountdownText.frame = CGRect( x: 0,
		                                               y: self.view.frame.height - (48 * DeviceManager.maxScrRatioC) - (86 * DeviceManager.maxScrRatioC)
		                                               , width: self.view.frame.width, height: 38 );
		gameAutostartCountdownText.textColor = UIColor.white;
		gameAutostartCountdownText.textAlignment = .center;
		self.view.addSubview(gameAutostartCountdownText);
		
		if (isGameMode == false) {
			gameAutostartCountdownText.isHidden = true;
			gameStartButtonImage.isHidden = true; //set to false when preload finish
		} else {
			gameStartButtonImage.isHidden = true;
			aStartTimer = UPUtils.setInterval(1, block: autoGameStartTimer);
		}
		
		///////
		self.gameTitleLabel.alpha = 0; self.gameTitleRedLabel.alpha = 0; self.gameTitleSkyblueLabel.alpha = 0;
		self.gameThumbnailsBackgroundImage.alpha = 0; self.gameThumbnailsImage.alpha = 0;
		self.gameStartButtonImage.alpha = 0; self.gameAutostartCountdownText.alpha = 0;
		
		//Auto-init (for loading resources)
		jumpUPGameScene = JumpUPGame( size: CGSize( width: self.view.frame.width, height: self.view.frame.height ) );
		jumpUPGameScene!.preloadCompleteHandler = gamePreloadCompleted;
		jumpUPGameScene!.scaleMode = SKSceneScaleMode.resizeFill; jumpUPGameScene!.gameStartupType = isGameMode ? 1 : 0;
		
		gameView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height);
		gameView.presentScene(jumpUPGameScene!);
		
		print("Auto init end");
	} //end func
	
	func gamePreloadCompleted() {
		//View fade-in effect
		loadingIndicatorView.stopAnimating();
		
		if (isGameMode == false) {
			//alarm mode
			gameStartButtonImage.isHidden = false;
		} else { //manual game mode
			
		}
		
		UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
			self.gameTitleLabel.alpha = 1; self.gameTitleRedLabel.alpha = 1; self.gameTitleSkyblueLabel.alpha = 1;
			self.gameThumbnailsBackgroundImage.alpha = 1; self.gameThumbnailsImage.alpha = 1;
			self.gameAutostartCountdownText.alpha = 1; self.gameStartButtonImage.alpha = 1;
			}, completion: {_ in
		});
		
		preloadCompleted = true;
	}
	
	//자동 시작 타이머
	func autoGameStartTimer( ) {
		if (!preloadCompleted) {
			return;
		}
		
		print("timer running");
		
		aStartLeft -= 1;
		gameAutostartCountdownText.text = String(aStartLeft);
		if (aStartLeft <= 0) {
			// 타이머 정지 및 시작
			if (aStartTimer != nil) {
				aStartTimer!.invalidate(); aStartTimer = nil;
			}
			gameStartFuncTapHandler(nil);
		}
	}
	
	func gameStartFuncTapHandler( _ recognizer: UITapGestureRecognizer! ) {
		//Game start
		print("Presenting game view");
		
		////////테스트 전용. 나중에 빼야함
		gameView.showsFPS = true; //fps view
		gameView.showsDrawCount = true;
		gameView.showsNodeCount = true;
		gameView.showsQuadCount = true;
		gameView.showsFields = true;
		//////////////
		
		self.view.addSubview(gameView);
		//Gameview alpha transition
		gameView.alpha = 0;
		jumpUPGameScene!.isGamePaused = false;
		
		UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
			self.gameView.alpha = 1;
			}, completion: {_ in
		});
		
	} //end start func
	
	override func viewWillDisappear(_ animated: Bool) {
		//UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;
		//disposeView
		print("viewwilldisappear.");
		if (isGameMode == false) {
			AlarmRingView.selfView!.disposeView();
		}
	}
		
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	//Lock
	override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
		//Lock it to Portrait
		return .portrait;
	}
	
}
