//
//  GameTitleViewJumpUP.swift
//  UP
//
//  Created by ExFl on 2016. 2. 27..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
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
	
	//SKView (Game view) and game scene
	var gameView:SKView = SKView();
	var jumpUPGameScene:JumpUPGame?;
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.blackColor(); //black col
		
		
	}
	
	override func viewDidAppear(animated: Bool) {
		//View load func
		
		let gameTitleLabelYAxis:CGFloat = 128 * DeviceGeneral.scrRatioC;
		
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
		
		let gameThumbsSize:CGFloat = 180 * DeviceGeneral.scrRatioC;
		gameThumbnailsBackgroundImage.frame = CGRectMake( self.view.frame.width / 2 - gameThumbsSize / 2, self.view.frame.height / 2 - gameThumbsSize / 2, gameThumbsSize, gameThumbsSize);
		gameThumbnailsImage.frame = gameThumbnailsBackgroundImage.frame;
		
		self.view.addSubview(gameThumbnailsBackgroundImage); self.view.addSubview(gameThumbnailsImage);
		
		//start btn add.
		gameStartButtonImage.image = UIImage( named: "game-start-button.png" );
		gameStartButtonImage.frame = CGRectMake( self.view.frame.width / 2 - (242.05 * DeviceGeneral.scrRatioC) / 2, self.view.frame.height - (70.75 * DeviceGeneral.scrRatioC) - (86 * DeviceGeneral.scrRatioC), 242.05 * DeviceGeneral.scrRatioC, 70.75 * DeviceGeneral.scrRatioC );
		
		let gameStartGesture:UITapGestureRecognizer = UITapGestureRecognizer();
		gameStartGesture.addTarget(self, action: #selector(GameTitleViewJumpUP.gameStartFuncTapHandler(_:)));
		gameStartButtonImage.addGestureRecognizer(gameStartGesture);
		
		self.view.addSubview(gameStartButtonImage);
		gameStartButtonImage.userInteractionEnabled = true;
	} //end func
	
	func gameStartFuncTapHandler( recognizer: UITapGestureRecognizer ) {
		//Game start
		print("Presenting game view");
		jumpUPGameScene = JumpUPGame( size: CGSizeMake( self.view.frame.width, self.view.frame.height ) );
		jumpUPGameScene!.scaleMode = SKSceneScaleMode.ResizeFill;
		
		gameView.showsFPS = true; //fps view
		gameView.showsDrawCount = true;
		gameView.showsNodeCount = true;
		gameView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height);
		
		self.view.addSubview(gameView);
		gameView.presentScene(jumpUPGameScene!);
	}
	
	override func viewWillAppear(animated: Bool) {
		//뷰가 열릴 직전에.
		//UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default;
		
	} //end func
	
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