//
//  TestGameView.swift
//  	
//
//  Created by ExFl on 2016. 1. 25..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import UIKit
import SpriteKit

class TestGameView:UIViewController {
    
    //SKView
    var skView:SKView?;
    
    //기기 해상도 bounds
    var scrSize:CGRect?; //<- ?를 추가하는건 null로 선언함과같음.
    //기준 해상도 (iPhone 6s plus)
    let workSize:CGRect = CGRect(x: 0, y: 0, width: 414, height: 736);
    //기준에 대한 비율
    var scrRatio:Double = 1; var maxScrRatio:Double = 1; //최대가 1인 비율 크기

    
    //viewdidload - inital 함수. 뷰 로드시 자동실행
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //화면 사이즈를 얻어옴.
        scrSize = UIScreen.mainScreen().bounds;
        scrRatio = Double((scrSize?.width)! / workSize.width);
        print("GameView init. Width", scrSize?.width, "Height", scrSize?.height, "Ratio", scrRatio);
        maxScrRatio = min(1, scrRatio);
        
        //SKView(frame: CGRectMake(0, 0, CGFloat((scrSize?.width)!), CGFloat((scrSize?.height)!))); //
        self.skView = self.view as? SKView;
        skView!.showsFPS = true; //fps view
        skView!.showsDrawCount = true;
        skView!.showsNodeCount = true;
        skView!.ignoresSiblingOrder = true; //뭐하는건지 모르겠음
        skView!.frame = CGRectMake(0, 0, CGFloat((scrSize?.width)!), CGFloat((scrSize?.height)!));
        
        let gameScene = TestGameScene(size: CGSizeMake( scrSize!.width, scrSize!.height ));
        gameScene.scaleMode = SKSceneScaleMode.ResizeFill;
        
        gameScene.setScrScale(scrRatio);
        
        self.skView!.presentScene(gameScene);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}