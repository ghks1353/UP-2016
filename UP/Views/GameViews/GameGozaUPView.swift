//
//  GameGozaUPView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 7..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameGozaUPView:UIViewController {
	
	//SKView (Game view) and game scene
	var gameView:SKView = SKView()
	var gameViewScene:GozaUPGame?
	
	var aPreloadCheckTimer:Timer? //Preload check timer
	
	var preloadCompleted:Bool = false
	
	override func viewDidLoad() {
		// view init func
		self.view.backgroundColor = UIColor.black //black col
		super.viewDidLoad()
	} //end load
	override func viewDidAppear(_ animated: Bool) {
		if (gameViewScene != nil) {
			return
		}
		
		//Auto-init (for loading resources)
		gameViewScene = GozaUPGame( size: CGSize( width: self.view.frame.width, height: self.view.frame.height ) )
		gameViewScene!.preloadCompleteHandler = gamePreloadCompleted
		gameViewScene!.scaleMode = SKSceneScaleMode.resizeFill
		
		gameView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		gameView.presentScene(gameViewScene!)
		
		print("Auto init end")
		
		aPreloadCheckTimer = UPUtils.setInterval(0.5, block: preloadCheckTimer)
		super.viewDidAppear(animated)
	} //end func
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
		if (aPreloadCheckTimer != nil) {
			aPreloadCheckTimer!.invalidate()
			aPreloadCheckTimer = nil
		} //end func
		
		gameStartFuncTapHandler(nil)
	} //end if
	
	func gameStartFuncTapHandler( _ recognizer: UITapGestureRecognizer! ) {
		//Game start
		print("Presenting game view")
		
		////////테스트 전용.
		#if DEBUG
			gameView.showsFPS = true //fps view
			gameView.showsDrawCount = true
			gameView.showsNodeCount = true
		#endif
		
		self.view.addSubview(gameView)
		
		//Gameview alpha transition
		gameView.alpha = 1
		gameViewScene!.isGamePaused = false
		
		// play bgm sound
		SoundManager.playBGMSound( SoundManager.bundleSounds.GozaJumpUPBGM.rawValue )
		
	} //end start func
	override func viewWillDisappear(_ animated: Bool) {
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
