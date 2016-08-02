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
	var aStartTimer:NSTimer?; //자동 게임시작 카운트다운 타이머
	var aStartLeft:Int = 3;
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.blackColor(); //black col
		
		
	}
	
	override func viewDidAppear(animated: Bool) {
		if (jumpUPGameScene != nil) {
			return;
		}
		
		print("JumpUP gameview appear event");
		
		//View load func
		gameTitleLabel.text = Languages.$("gameNameJumpUP");
		gameTitleLabel.font = UIFont.systemFontOfSize(38);
		gameTitleLabel.frame = CGRectMake( 0, gameTitleLabelYAxis, self.view.frame.width, 38 );
		gameTitleLabel.textColor = UIColor.whiteColor();
		gameTitleLabel.textAlignment = .Center;
		
		gameTitleRedLabel.font = gameTitleLabel.font; gameTitleRedLabel.text = gameTitleLabel.text;
		gameTitleRedLabel.frame = CGRectMake( -1.5, gameTitleLabelYAxis, gameTitleLabel.frame.width, gameTitleLabel.frame.height );
		gameTitleRedLabel.textColor = UPUtils.colorWithHexString("#FF0000");
		gameTitleRedLabel.textAlignment = gameTitleLabel.textAlignment;
		gameTitleSkyblueLabel.font = gameTitleLabel.font; gameTitleSkyblueLabel.text = gameTitleLabel.text;
		gameTitleSkyblueLabel.frame = CGRectMake( 1.5, gameTitleLabelYAxis, gameTitleLabel.frame.width, gameTitleLabel.frame.height );
		gameTitleSkyblueLabel.textColor = UPUtils.colorWithHexString("#00FFFF");
		gameTitleSkyblueLabel.textAlignment = gameTitleLabel.textAlignment;
		
		self.view.addSubview(gameTitleRedLabel);
		self.view.addSubview(gameTitleSkyblueLabel); self.view.addSubview(gameTitleLabel);
		/////
		
		gameThumbnailsBackgroundImage.image = UIImage( named: "game-thumb-background.png" );
		gameThumbnailsImage.image = UIImage( named: "game-thumb-jumpup.png" );
		
		gameThumbnailsBackgroundImage.frame = CGRectMake( self.view.frame.width / 2 - gameThumbsSize / 2, self.view.frame.height / 2 - gameThumbsSize / 2, gameThumbsSize, gameThumbsSize);
		gameThumbnailsImage.frame = gameThumbnailsBackgroundImage.frame;
		
		self.view.addSubview(gameThumbnailsBackgroundImage); self.view.addSubview(gameThumbnailsImage);
		
		//start btn add.
		gameStartButtonImage.image = UIImage( named: "game-start-button.png" );
		gameStartButtonImage.frame = CGRectMake( self.view.frame.width / 2 - (242.05 * DeviceManager.maxScrRatioC) / 2, self.view.frame.height - (70.75 * DeviceManager.maxScrRatioC) - (86 * DeviceManager.maxScrRatioC), 242.05 * DeviceManager.maxScrRatioC, 70.75 * DeviceManager.maxScrRatioC );
		
		let gameStartGesture:UITapGestureRecognizer = UITapGestureRecognizer();
		gameStartGesture.addTarget(self, action: #selector(GameTitleViewJumpUP.gameStartFuncTapHandler(_:)));
		gameStartButtonImage.addGestureRecognizer(gameStartGesture);
		
		self.view.addSubview(gameStartButtonImage);
		gameStartButtonImage.userInteractionEnabled = true;
		
		//Auto-count Add. (게임모드일때만 보임)
		gameAutostartCountdownText.text = String(aStartLeft);
		gameAutostartCountdownText.font = UIFont.systemFontOfSize(38);
		gameAutostartCountdownText.frame = CGRectMake( 0,
		                                               self.view.frame.height - (48 * DeviceManager.maxScrRatioC) - (86 * DeviceManager.maxScrRatioC)
		                                               , self.view.frame.width, 38 );
		gameAutostartCountdownText.textColor = UIColor.whiteColor();
		gameAutostartCountdownText.textAlignment = .Center;
		self.view.addSubview(gameAutostartCountdownText);
		
		if (isGameMode == false) {
			gameAutostartCountdownText.hidden = true;
		} else {
			gameStartButtonImage.hidden = true;
			//자동 시작해야 함
			aStartTimer = UPUtils.setInterval(1, block: autoGameStartTimer);
		}
		
		///////
		self.gameTitleLabel.alpha = 0; self.gameTitleRedLabel.alpha = 0; self.gameTitleSkyblueLabel.alpha = 0;
		self.gameThumbnailsBackgroundImage.alpha = 0; self.gameThumbnailsImage.alpha = 0;
		self.gameStartButtonImage.alpha = 0; self.gameAutostartCountdownText.alpha = 0;
		
		//View fade-in effect
		UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
			self.gameTitleLabel.alpha = 1; self.gameTitleRedLabel.alpha = 1; self.gameTitleSkyblueLabel.alpha = 1;
			self.gameThumbnailsBackgroundImage.alpha = 1; self.gameThumbnailsImage.alpha = 1;
			self.gameStartButtonImage.alpha = 1;  self.gameAutostartCountdownText.alpha = 1;
			}, completion: {_ in
		});
		
		
	} //end func
	
	//자동 시작 타이머
	func autoGameStartTimer() {
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
	
	func gameStartFuncTapHandler( recognizer: UITapGestureRecognizer! ) {
		//Game start
		print("Presenting game view");
		jumpUPGameScene = JumpUPGame( size: CGSizeMake( self.view.frame.width, self.view.frame.height ) );
		jumpUPGameScene!.scaleMode = SKSceneScaleMode.ResizeFill;
		jumpUPGameScene!.gameStartupType = isGameMode ? 1 : 0;
		
		////////테스트 전용. 나중에 빼야함
		gameView.showsFPS = true; //fps view
		gameView.showsDrawCount = true;
		gameView.showsNodeCount = true;
		//////////////
		
		gameView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height);
		
		self.view.addSubview(gameView);
		gameView.presentScene(jumpUPGameScene!);
		
		//Gameview alpha transition
		gameView.alpha = 0;
		
		UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
			self.gameView.alpha = 1;
			}, completion: {_ in
		});
		
	} //end start func
	
	//override func viewWillAppear(animated: Bool) {
		//뷰가 열릴 직전에.
		//UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default;
		
	//} //end func
	
	override func viewWillDisappear(animated: Bool) {
		//UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent;
		
	}
		
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	//Lock
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		//Lock it to Portrait
		return .Portrait;
	}
	
}