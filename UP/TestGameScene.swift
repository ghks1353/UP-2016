//
//  TestGameScene.swift
//  	
//
//  Created by ExFl on 2016. 1. 25..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import AVFoundation
import SpriteKit

class TestGameScene:SKScene {
    
    var xRatio:Double = 1; //var yRatio:Double?;
    
    var playerSpriteTexture:SKTexture = SKTexture(imageNamed: "player.png");
    var enemySpriteTexture:SKTexture = SKTexture(imageNamed: "enemy.jpg");
    var enemySpriteTexture2:SKTexture = SKTexture(imageNamed: "duhan.jpg");
    var enemySpriteTexture3:SKTexture = SKTexture(imageNamed: "cheeta.png");
    
    var playerSKSpr:SKSpriteNode?;
    
    var backgroundMusicSound:AVAudioPlayer = AVAudioPlayer()
    var effectSound1:AVAudioPlayer = AVAudioPlayer(); var effectSound2:AVAudioPlayer = AVAudioPlayer(); var effectSound3:AVAudioPlayer = AVAudioPlayer();
    var effectSound4:AVAudioPlayer = AVAudioPlayer(); var effectSound5:AVAudioPlayer = AVAudioPlayer(); var effectSound6:AVAudioPlayer = AVAudioPlayer();
    var effectSound7:AVAudioPlayer = AVAudioPlayer();
    
    //캐릭터의 점프정도
    var characterJump:Double = 0; var characterAcc:Double = 0;
    
    //적 배열
    var enemysArray:[SKSpriteNode] = []; var score:Int = 0; var level:Int = 1;
    
    //(임시) 적 등장 타이머
    var enemySpawnTimer:Int = 0; var gameOver:Bool = false;
    
    
    let myLabel:SKLabelNode = SKLabelNode();
    
    override func didMoveToView(view: SKView) {
        //initial function
        
        //좌표계 위로감. 맨 아래가 y0.
        
        //test
        let gameNameLabel = SKLabelNode();
        gameNameLabel.text = "심영의모UP";
        gameNameLabel.fontSize = CGFloat(40 * xRatio);
        gameNameLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left;
        gameNameLabel.position = CGPoint(x: 0, y: self.frame.height / 2 + CGFloat(36 * xRatio));
        self.addChild(gameNameLabel);
        
        //let myLabel = SKLabelNode();
        myLabel.text = "Score: 0";
        myLabel.fontSize = CGFloat(30 * xRatio);
        myLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left;
        myLabel.position = CGPoint(x: 0, y: self.frame.height / 2);
        self.addChild(myLabel);
        
        playerSKSpr = SKSpriteNode(texture: playerSpriteTexture);
        playerSKSpr?.size = CGSize(width: ((playerSKSpr?.frame.width)! * CGFloat(xRatio)) / 3, height: ((playerSKSpr?.frame.height)! * CGFloat(xRatio)) / 3);
        
        //Default sprite의 기준점은 센터, 센터임.
        playerSKSpr?.position = CGPointMake(CGFloat(playerSKSpr!.frame.width/2), CGFloat(playerSKSpr!.frame.height/2));
        
        self.addChild(playerSKSpr!);
        
        //테스트 음악 재생
        var tuneURL:NSURL = NSBundle.mainBundle().URLForResource("testbgm", withExtension: "mp3")!
        do { backgroundMusicSound = try AVAudioPlayer(contentsOfURL: tuneURL, fileTypeHint: nil) } catch let error as NSError {
            print(error.description); }
        backgroundMusicSound.numberOfLoops = -1; backgroundMusicSound.prepareToPlay(); backgroundMusicSound.play();
        
        
        //효과음 구성
        tuneURL = NSBundle.mainBundle().URLForResource("testeffect1", withExtension: "mp3")!
        do { effectSound1 = try AVAudioPlayer(contentsOfURL: tuneURL, fileTypeHint: nil) } catch let error as NSError {
            print(error.description); }; effectSound1.numberOfLoops = 0; effectSound1.prepareToPlay();
        tuneURL = NSBundle.mainBundle().URLForResource("testeffect2", withExtension: "mp3")!
        do { effectSound2 = try AVAudioPlayer(contentsOfURL: tuneURL, fileTypeHint: nil) } catch let error as NSError {
            print(error.description); }; effectSound2.numberOfLoops = 0; effectSound2.prepareToPlay();
        tuneURL = NSBundle.mainBundle().URLForResource("testeffect3", withExtension: "mp3")!
        do { effectSound3 = try AVAudioPlayer(contentsOfURL: tuneURL, fileTypeHint: nil) } catch let error as NSError {
            print(error.description); }; effectSound3.numberOfLoops = 0; effectSound3.prepareToPlay();
        tuneURL = NSBundle.mainBundle().URLForResource("testeffect4", withExtension: "mp3")!
        do { effectSound4 = try AVAudioPlayer(contentsOfURL: tuneURL, fileTypeHint: nil) } catch let error as NSError {
            print(error.description); }; effectSound4.numberOfLoops = 0; effectSound4.prepareToPlay();
        tuneURL = NSBundle.mainBundle().URLForResource("testeffect5", withExtension: "mp3")!
        do { effectSound5 = try AVAudioPlayer(contentsOfURL: tuneURL, fileTypeHint: nil) } catch let error as NSError {
            print(error.description); }; effectSound5.numberOfLoops = 0; effectSound5.prepareToPlay();
        tuneURL = NSBundle.mainBundle().URLForResource("testeffect7", withExtension: "mp3")!
        do { effectSound6 = try AVAudioPlayer(contentsOfURL: tuneURL, fileTypeHint: nil) } catch let error as NSError {
            print(error.description); }; effectSound6.numberOfLoops = 0; effectSound6.prepareToPlay();
        tuneURL = NSBundle.mainBundle().URLForResource("testeffect8", withExtension: "mp3")!
        do { effectSound7 = try AVAudioPlayer(contentsOfURL: tuneURL, fileTypeHint: nil) } catch let error as NSError {
            print(error.description); }; effectSound7.numberOfLoops = 0; effectSound7.prepareToPlay();
        
        enemySpawnTimer = 180;
        
    }
    
    internal func setScrScale(xscale:Double) {
        xRatio = xscale; // yRatio = yscale;
    }
    
    
    override func update(interval: CFTimeInterval) {
        if (gameOver == true) {
            return;
        }
        
       //60fps game tick
        if (characterJump > 0) {
            playerSKSpr!.position.y += CGFloat(characterJump / 1.8);
            --characterJump;
        }
        if (playerSKSpr!.position.y > CGFloat(playerSKSpr!.frame.height/2) && characterJump == 0) {
            playerSKSpr!.position.y -= CGFloat(characterAcc / 5);
            ++characterAcc;
            
            if (playerSKSpr!.position.y <= CGFloat(playerSKSpr!.frame.height/2)) {
                characterAcc = 0; characterJump = 0;
                playerSKSpr!.position.y = CGFloat(playerSKSpr!.frame.height/2);
            }
        }
        
        //enemy tick
        for (var i = 0; i < enemysArray.count; ++i) {
            if (enemysArray[i].name == "cheeeeta") {
                enemysArray[i].position.x -= 6;

            } else if (enemysArray[i].name == "cheeta") {
                enemysArray[i].position.x -= 4;
            } else {
                enemysArray[i].position.x -= 3;
            }
            
            if (enemysArray[i].name == "cheetajumped"){
                
                enemysArray[i].position.y += 5;
            }
            if (enemysArray[i].position.x <= self.frame.width / 2.5 && enemysArray[i].name == "cheeta") {
                effectSound7.play();
                enemysArray[i].name = "cheetajumped";
            }
            if (enemysArray[i].position.x <= -enemysArray[i].frame.width / 2) {
                enemysArray[i].removeFromParent();
                enemysArray.removeAtIndex(i);
                ++score;
                if (score % 5 == 0) {
                    ++level;
                }
                
                continue;
            }
            
           if (
            enemysArray[i].containsPoint((playerSKSpr?.position)!) == true ||
            enemysArray[i].containsPoint(CGPoint(x: (playerSKSpr?.position.x)! - (playerSKSpr?.frame.width)! / 2, y: (playerSKSpr?.position.y)! - (playerSKSpr?.frame.height)! / 2)) == true ||
            enemysArray[i].containsPoint(CGPoint(x: (playerSKSpr?.position.x)! + (playerSKSpr?.frame.width)! / 2, y: (playerSKSpr?.position.y)! - (playerSKSpr?.frame.height)! / 2)) == true ||
            enemysArray[i].containsPoint(CGPoint(x: (playerSKSpr?.position.x)! - (playerSKSpr?.frame.width)! / 2, y: (playerSKSpr?.position.y)! + (playerSKSpr?.frame.height)! / 2)) == true ||
            enemysArray[i].containsPoint(CGPoint(x: (playerSKSpr?.position.x)! + (playerSKSpr?.frame.width)! / 2, y: (playerSKSpr?.position.y)! + (playerSKSpr?.frame.height)! / 2)) == true
            
            
            
            ) {
                effectSound4.play(); //effectSound6.play();

                gameOver = true;
                myLabel.text = "GAY OVER";
                return;
            }
        }
        
        //enemy spawn
        if (enemySpawnTimer <= 0) {
            enemySpawnTimer = 120 + Int(arc4random_uniform(120));
            addEnemys( Int(arc4random_uniform(5)) );
        } else {
            enemySpawnTimer -= 0 + max(1, Int(level/3));
        }
        
        //ui tick
        myLabel.text = "Score: " + String(score) + ", Level: " + String(level);
        
    } //end tick
    
    func addEnemys(enemyType:Int) {
        var tmpEnemy:SKSpriteNode;
        
        switch(enemyType) {
            case 0:
                tmpEnemy = SKSpriteNode(texture: enemySpriteTexture);
                //enemy resize to fit device size
                tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * CGFloat(xRatio)) / 7, height: (tmpEnemy.frame.height * CGFloat(xRatio)) / 4);
                tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
                enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
                effectSound5.play();
            break;
            case 1:
                tmpEnemy = SKSpriteNode(texture: enemySpriteTexture2);
                //enemy resize to fit device size
                tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * CGFloat(xRatio)) / 5, height: (tmpEnemy.frame.height * CGFloat(xRatio)) / 2.5);
                tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
                enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
                
                effectSound6.play();
            break;
            case 2:
                tmpEnemy = SKSpriteNode(texture: enemySpriteTexture3);
                //enemy resize to fit device size
                tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * CGFloat(xRatio)) / 2, height: (tmpEnemy.frame.height * CGFloat(xRatio)) / 2);
                tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
                tmpEnemy.name = "cheeta";
                enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
            break;
        case 3:
            tmpEnemy = SKSpriteNode(texture: enemySpriteTexture3);
            //enemy resize to fit device size
            tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * CGFloat(xRatio)) / 2, height: (tmpEnemy.frame.height * CGFloat(xRatio)) / 2);
            tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
            tmpEnemy.name = "cheeeeta";
            enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
            break;
        case 4:
            tmpEnemy = SKSpriteNode(texture: enemySpriteTexture3);
            //enemy resize to fit device size
            tmpEnemy.size = CGSize(width: (tmpEnemy.frame.width * CGFloat(xRatio)) / 2, height: (tmpEnemy.frame.height * CGFloat(xRatio)) / 2);
            tmpEnemy.position.x = self.frame.width + tmpEnemy.frame.width / 2; tmpEnemy.position.y = tmpEnemy.frame.height / 2;
           // tmpEnemy.name = "cheeeeta";
            enemysArray += [tmpEnemy]; self.addChild(tmpEnemy);
            break;
        default: break;
        }
       
        
        
       
        
    }
    
    //Swift 2용
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            //print("Touch!");
            if (gameOver == true){
                //restart again
                characterJump = 0; playerSKSpr!.position.y = CGFloat(playerSKSpr!.frame.height/2);
                score = 0; level = 1; enemySpawnTimer = 180;
                for (var i = 0; i < enemysArray.count; ++i) {
                    enemysArray[i].removeFromParent();
                    enemysArray.removeAtIndex(i);
                }
                
                gameOver = false;
                return;
            }
            if (characterJump == 0 && playerSKSpr!.position.y <= CGFloat(playerSKSpr!.frame.height/2)) {
                let random = Int(arc4random_uniform(3)); //0, 1, 2 중 하나를 반환
                    switch( random ) {
                        case 0:
                            effectSound1.stop(); effectSound1.play();
                            break;
                        case 1:
                            effectSound2.stop(); effectSound2.play();
                            break;
                        case 2:
                            effectSound3.stop(); effectSound3.play();
                            break;
                        default: effectSound1.stop(); effectSound1.play(); break;
                    }
                characterJump = 26; characterAcc = 0;
            }
            
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    
}