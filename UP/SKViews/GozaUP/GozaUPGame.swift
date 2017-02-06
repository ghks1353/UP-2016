//
//  GozaUPGame.swift
//  UP
//
//  Created by ExFl on 2017. 2. 7..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import SpriteKit

class GozaUPGame:GameStructureScene {
	
	var playerSpriteTexture:SKTexture = SKTexture(imageNamed: "game-gozaup-assets-player.png")
	var enemySpriteTexture:SKTexture = SKTexture(imageNamed: "game-gozaup-assets-enemy.jpg")
	var enemySpriteTexture2:SKTexture = SKTexture(imageNamed: "game-gozaup-assets-duhan.jpg")
	var enemySpriteTexture3:SKTexture = SKTexture(imageNamed: "game-gozaup-assets-cheeta.png")
	
	var playerSKSpr:SKSpriteNode?
	
	//캐릭터의 점프정도
	var characterJump:Double = 0
	var characterAcc:Double = 0
	
	//적 배열
	var enemysArray:[SKSpriteNode] = []
	var score:Int = 0
	var level:Int = 1
	
	//(임시) 적 등장 타이머
	var enemySpawnTimer:Int = 0
	var gameOver:Bool = false
	
	let myLabel:SKLabelNode = SKLabelNode()
	
	override func didMove(to view: SKView) {
		//Game ID
		currentGameID = -1
		//Preload total count
		preloadCompleteCout = 4
		
		super.didMove(to: view)
		
		gameOver = false
		playerSpriteTexture.preload(completionHandler: preloadEventCall)
		enemySpriteTexture.preload(completionHandler: preloadEventCall)
		enemySpriteTexture2.preload(completionHandler: preloadEventCall)
		enemySpriteTexture3.preload(completionHandler: preloadEventCall)
		
		//좌표계 위로감. 맨 아래가 y0.
		
		let gameNameLabel = SKLabelNode()
		gameNameLabel.text = "심영의모UP swift3 ver."
		gameNameLabel.fontSize = CGFloat(40 * DeviceManager.scrRatioC)
		gameNameLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		gameNameLabel.position = CGPoint(x: 0, y: self.frame.height / 2 + CGFloat(36 * DeviceManager.scrRatioC))
		self.addChild(gameNameLabel)
		
		myLabel.text = "Score: 0"
		myLabel.fontSize = CGFloat(30 * DeviceManager.scrRatioC);
		myLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
		myLabel.position = CGPoint(x: 0, y: self.frame.height / 2)
		self.addChild(myLabel)
		
		playerSKSpr = SKSpriteNode(texture: playerSpriteTexture)
		playerSKSpr?.size = CGSize(width: ((playerSKSpr?.frame.width)! * DeviceManager.scrRatioC) / 3, height: ((playerSKSpr?.frame.height)!  * DeviceManager.scrRatioC) / 3)
		
		//Default sprite의 기준점은 센터, 센터임.
		playerSKSpr?.position = CGPoint(x: CGFloat(playerSKSpr!.frame.width/2), y: CGFloat(playerSKSpr!.frame.height/2))
		
		self.addChild(playerSKSpr!)
		
		//테스트 음악 재생
		SoundManager.playBGMSound( SoundManager.bundleSounds.GozaJumpUPBGM.rawValue )
		
		enemySpawnTimer = 180
	} //end func
	
	override func update(_ interval: CFTimeInterval) {
		if (gameOver == true) {
			return
		}
		
		//60fps game tick
		if (characterJump > 0) {
			playerSKSpr!.position.y += CGFloat(characterJump / 1.8)
			characterJump -= 1
		}
		if (playerSKSpr!.position.y > CGFloat(playerSKSpr!.frame.height/2) && characterJump == 0) {
			playerSKSpr!.position.y -= CGFloat(characterAcc / 5)
			characterAcc += 1
			
			if (playerSKSpr!.position.y <= CGFloat(playerSKSpr!.frame.height/2)) {
				characterAcc = 0
				characterJump = 0
				playerSKSpr!.position.y = CGFloat(playerSKSpr!.frame.height/2)
			}
		}
		
		//enemy tick
		var removedCount:Int = 0
		for i:Int in 0 ..< enemysArray.count {
			if (enemysArray[i + removedCount].name == "cheeeeta") {
				enemysArray[i + removedCount].position.x -= 6
			} else if (enemysArray[i + removedCount].name == "cheeta") {
				enemysArray[i + removedCount].position.x -= 4
			} else {
				enemysArray[i + removedCount].position.x -= 3
			}
			
			if (enemysArray[i + removedCount].name == "cheetajumped"){
				enemysArray[i + removedCount].position.y += 5
			}
			if (enemysArray[i + removedCount].position.x <= self.frame.width / 2.5 && enemysArray[i + removedCount].name == "cheeta") {
				//effect7 play todo
				SoundManager.playEffectSound(SoundManager.bundleEffectsGozaUP.GameEffect7.rawValue)
				enemysArray[i + removedCount].name = "cheetajumped"
			}
			if (enemysArray[i + removedCount].position.x <= -enemysArray[i + removedCount].frame.width / 2) {
				enemysArray[i + removedCount].removeFromParent()
				enemysArray.remove(at: i)
				removedCount -= 1
				score += 1
				if (score % 5 == 0) {
					level += 1;
				}
				continue
			}
			
			if (
				enemysArray[i + removedCount].contains((playerSKSpr?.position)!) == true ||
					enemysArray[i + removedCount].contains(CGPoint(x: (playerSKSpr?.position.x)! - (playerSKSpr?.frame.width)! / 2, y: (playerSKSpr?.position.y)! - (playerSKSpr?.frame.height)! / 2)) == true ||
					enemysArray[i + removedCount].contains(CGPoint(x: (playerSKSpr?.position.x)! + (playerSKSpr?.frame.width)! / 2, y: (playerSKSpr?.position.y)! - (playerSKSpr?.frame.height)! / 2)) == true ||
					enemysArray[i + removedCount].contains(CGPoint(x: (playerSKSpr?.position.x)! - (playerSKSpr?.frame.width)! / 2, y: (playerSKSpr?.position.y)! + (playerSKSpr?.frame.height)! / 2)) == true ||
					enemysArray[i + removedCount].contains(CGPoint(x: (playerSKSpr?.position.x)! + (playerSKSpr?.frame.width)! / 2, y: (playerSKSpr?.position.y)! + (playerSKSpr?.frame.height)! / 2)) == true
				
				
				
				) {
				//effect 3 play todo.
				SoundManager.playEffectSound(SoundManager.bundleEffectsGozaUP.GameEffect3.rawValue)
				
				gameOver = true
				myLabel.text = "GAY OVER"
				return
			}
		}
		
		//enemy spawn
		if (enemySpawnTimer <= 0) {
			enemySpawnTimer = 120 + Int(arc4random_uniform(120))
			addEnemys( enemyType: Int(arc4random_uniform(5)) )
		} else {
			enemySpawnTimer -= 0 + max(1, Int(level/3))
		}
		
		//ui tick
		myLabel.text = "Score: " + String(score) + ", Level: " + String(level);
		
	} //end tick
	
	func addEnemys(enemyType:Int) {
		var tmpEnemy:SKSpriteNode
		
		switch(enemyType) {
		case 0:
			tmpEnemy = SKSpriteNode(texture: enemySpriteTexture);
			//enemy resize to fit device size
			tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * DeviceManager.scrRatioC) / 7, height: (tmpEnemy.frame.height * DeviceManager.scrRatioC) / 4);
			tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
			enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
			
			//eff 4 play todo.
			SoundManager.playEffectSound(SoundManager.bundleEffectsGozaUP.GameEffect4.rawValue)
			
			break;
		case 1:
			tmpEnemy = SKSpriteNode(texture: enemySpriteTexture2);
			//enemy resize to fit device size
			tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * DeviceManager.scrRatioC) / 5, height: (tmpEnemy.frame.height * DeviceManager.scrRatioC) / 2.5);
			tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
			enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
			
			//eff 5 play todo.
			SoundManager.playEffectSound(SoundManager.bundleEffectsGozaUP.GameEffect6.rawValue)
			break;
		case 2:
			tmpEnemy = SKSpriteNode(texture: enemySpriteTexture3);
			//enemy resize to fit device size
			tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * DeviceManager.scrRatioC) / 2, height: (tmpEnemy.frame.height * DeviceManager.scrRatioC) / 2);
			tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
			tmpEnemy.name = "cheeta";
			enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
			break;
		case 3:
			tmpEnemy = SKSpriteNode(texture: enemySpriteTexture3);
			//enemy resize to fit device size
			tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * DeviceManager.scrRatioC) / 2, height: (tmpEnemy.frame.height * DeviceManager.scrRatioC) / 2);
			tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
			tmpEnemy.name = "cheeeeta";
			enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
			break;
		case 4:
			tmpEnemy = SKSpriteNode(texture: enemySpriteTexture3);
			//enemy resize to fit device size
			tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * DeviceManager.scrRatioC) / 2, height: (tmpEnemy.frame.height * DeviceManager.scrRatioC) / 2);
			tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
			// tmpEnemy.name = "cheeeeta";
			enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
			break;
		default: break;
		}
		
	}
	
	//Swift 2용
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let _ = touches.first {
			if (gameOver == true){
				//restart again
				characterJump = 0
				playerSKSpr!.position.y = CGFloat(playerSKSpr!.frame.height/2)
				score = 0
				level = 1
				enemySpawnTimer = 180
				for i:Int in 0 ..< enemysArray.count {
					enemysArray[i].removeFromParent()
				}
				enemysArray = []
				
				isGameFinished = true
				GameModeView.isGameExiting = true //재시작시엔 이게 false이면, 다시 appear가 발동함
				
				SoundManager.stopBGMSound()
				
				GameModeView.selfView!.dismiss(animated: false, completion: nil)
				ViewController.selfView!.showHideBlurview(false)
				GlobalSubView.gameModePlayViewcontroller.dismiss(animated: true, completion: nil )
				return
			}
			if (characterJump == 0 && playerSKSpr!.position.y <= CGFloat(playerSKSpr!.frame.height/2)) {
				let random = Int(arc4random_uniform(3)) //0, 1, 2 중 하나를 반환
				switch( random ) {
				case 0:
					//effect0 play todo
					SoundManager.playEffectSound(SoundManager.bundleEffectsGozaUP.GameEffect0.rawValue)
					break
				case 1:
					//effect1 play todo
					SoundManager.playEffectSound(SoundManager.bundleEffectsGozaUP.GameEffect1.rawValue)
					break
				case 2:
					//effect2 play todo
					SoundManager.playEffectSound(SoundManager.bundleEffectsGozaUP.GameEffect2.rawValue)
					break
				default:
					//effect0 play todo
					SoundManager.playEffectSound(SoundManager.bundleEffectsGozaUP.GameEffect0.rawValue)
					break
				}
				characterJump = 26; characterAcc = 0;
			}
			
		}
		super.touchesBegan(touches, with:event)
	}
	
	
}
