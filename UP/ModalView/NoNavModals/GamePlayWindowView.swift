//
//  GamePlayWindowView.swift
//  UP
//
//  Created by ExFl on 2016. 5. 29..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;
import Gifu;
import GameKit;

class GamePlayWindowView:UIViewController, GKGameCenterControllerDelegate {
	
	var XAXIS_PRESET_PAD:CGFloat = 0;
	var YAXIS_PRESET_PAD:CGFloat = 6;
	
	var XAXIS_PRESET_LV_PAD:CGFloat = -8;
	var XAXIS_PRESET_LV_R_PAD:CGFloat = -13;
	var YAXIS_PRESET_LV_PAD:CGFloat = -10;
	
	//for access
	static var selfView:GamePlayWindowView?;
	
	//Floating view
	var modalView:UIView = UIView();
	
	//숫자 리소스 추가
	var blackNumbers:Array<UIImage> = [];
	
	//숫자 조작을 위한 포인터
	var bestNumPointers:Array<UIImageView> = [];
	
	//Score/Best 표시를 위한 페이징 뷰
	var scrollView:UIScrollView = UIScrollView();
	
	//가운데 결과창 데코 배경, 배경 색
	var resultDecoBGMask:UIView = UIView();
	
	//버튼 (일반 게임 결과창)
	var resultButtonList:UIButton = UIButton();
	var resultButtonRanking:UIButton = UIButton();
	var resultButtonRetry:UIButton = UIButton(); //<- 일반게임 시 가운데
	
	//number up timers
	var numUPTimer:NSTimer?;
	
	//게임플레이 프리뷰 이미지뷰
	var gamePreviewImageView:AnimatableImageView?;
	
	///////////////
	
	//현재 지정된 게임
	var currentGameID:Int = 0;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		GamePlayWindowView.selfView = self;
		
		//ModalView
		modalView.backgroundColor = UIColor.whiteColor();
		modalView.frame = DeviceManager.resultModalSizeRect;
		self.view.addSubview(modalView);
		
		//리소스 제작
		for i:Int in 0 ..< 10 {
			blackNumbers += [ UIImage( named: SkinManager.getDefaultAssetPresets() + "black_" + String(i) + ".png" )! ];
		}
		
		// ** 레이아웃들 패드의 경우 특수처리 필요 **
		if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
			XAXIS_PRESET_PAD = 0; YAXIS_PRESET_PAD = 0;
			XAXIS_PRESET_LV_PAD = 0; YAXIS_PRESET_LV_PAD = 0;
			XAXIS_PRESET_LV_R_PAD = 0;
		}
		
		//ScrollView create.
		scrollView.pagingEnabled = true;
		scrollView.frame = CGRectMake(0, 0, modalView.frame.width, 146 * DeviceManager.resultModalRatioC);
		scrollView.contentSize = CGSizeMake(scrollView.frame.width * 1, scrollView.frame.height);
		
		///// best 부분 만들기
		let bestUIView:UIView = UIView(); bestUIView.frame = CGRectMake(scrollView.frame.width * 0, 0, scrollView.frame.width, scrollView.frame.height);
		let bestImgView:UIImageView = UIImageView( image: UIImage( named: "result-best.png" ));
		bestImgView.frame = CGRectMake((modalView.frame.width / 2) - ((84 * DeviceManager.resultModalRatioC) / 2), (32 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC, (84 * DeviceManager.resultModalRatioC), (32.65 * DeviceManager.resultModalRatioC));
		bestUIView.backgroundColor = UIColor.clearColor();
		bestUIView.addSubview(bestImgView);
		
		//Best에 대한 숫자 추가
		for i:Int in 0 ..< 5 {
			let bestNumber:UIImageView = UIImageView( image: blackNumbers[0] );
			bestNumber.frame = getNumberLocForIndex(i, yAxis: bestImgView.frame.maxY + (8 * DeviceManager.resultModalRatioC));
			bestUIView.addSubview(bestNumber); bestNumPointers += [ bestNumber ];
		} //숫자 표시용 디지털 숫자 노드 3개
		
		//페이지 추가
		scrollView.addSubview(bestUIView);
		modalView.addSubview(scrollView);
		
		///// 배경 추가
		gamePreviewImageView = AnimatableImageView(frame: CGRectMake(0, scrollView.frame.maxY, modalView.frame.width, 194 * DeviceManager.resultModalRatioC) );
		resultDecoBGMask.frame = gamePreviewImageView!.frame; resultDecoBGMask.backgroundColor = UIColor.blackColor();
		modalView.addSubview(resultDecoBGMask);
		modalView.addSubview(gamePreviewImageView!);
		
		gamePreviewImageView!.contentMode = .ScaleAspectFit;
		
		//// 버튼 추가
		resultButtonList.setImage(UIImage(named: "result-btn-list.png"), forState: .Normal);
		resultButtonRanking.setImage(UIImage(named: "result-btn-ranking.png"), forState: .Normal);
		resultButtonRetry.setImage(UIImage(named: "result-btn-play.png"), forState: .Normal);
		
		resultButtonList.frame = CGRectMake(modalView.frame.width / 2 - (62 * DeviceManager.resultModalRatioC) * 2,
		                                    gamePreviewImageView!.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                    62 * DeviceManager.resultModalRatioC, 62 * DeviceManager.resultModalRatioC);
		
		resultButtonRetry.frame = CGRectMake(modalView.frame.width / 2 - (62 * DeviceManager.resultModalRatioC) / 2,
		                                     gamePreviewImageView!.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                     62 * DeviceManager.resultModalRatioC, 62 * DeviceManager.resultModalRatioC);
		
		resultButtonRanking.frame = CGRectMake(modalView.frame.width / 2 + (62 * DeviceManager.resultModalRatioC),
		                                    gamePreviewImageView!.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                    62 * DeviceManager.resultModalRatioC, 62 * DeviceManager.resultModalRatioC);
		
		modalView.addSubview(resultButtonList);
		modalView.addSubview(resultButtonRetry);
		modalView.addSubview(resultButtonRanking);
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff (result mask)
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask-result.png"));
		modalMaskImageView.frame = CGRectMake(0, 0, modalView.frame.width, modalView.frame.height);
		modalMaskImageView.contentMode = .ScaleAspectFit; modalView.maskView = modalMaskImageView;
		
		FitModalLocationToCenter();
		
		//버튼 이벤트 바인딩
		resultButtonList.addTarget(self, action: #selector(GamePlayWindowView.viewCloseAction), forControlEvents: .TouchUpInside);
		resultButtonRanking.addTarget(self, action: #selector(GamePlayWindowView.showLeaderboard), forControlEvents: .TouchUpInside);
	}
	
	//리더보드 표시 함수
	func showLeaderboard() {
		let gcViewController: GKGameCenterViewController = GKGameCenterViewController();
		gcViewController.gameCenterDelegate = self;
		gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards;
		
		switch(currentGameID) {
			case 0: //JumpUP
				gcViewController.leaderboardIdentifier = "leaderboard_jumpup"; //아이튠즈 커네트에서 순위표id.
				break;
			default: break;
		}
		
		self.showViewController(gcViewController, sender: self);
		self.presentViewController(gcViewController, animated: true, completion: nil);
	}
	
	func setGame( gameID:Int ) {
		currentGameID = gameID;
		switch ( gameID ) {
			case 0:
				gamePreviewImageView!.animateWithImage(named: "game_jumpup_assets_playpreview.gif");
				break;
			default: break;
		}
	}
	
	func getNumberLocForIndex(index:Int, yAxis:CGFloat) -> CGRect {
		let numWidth:CGFloat = 38; let numHeight:CGFloat = 53.2;
		return CGRectMake(
			(modalView.frame.width / 2) - (CGFloat(index) * ((numWidth * DeviceManager.resultModalRatioC) + 6 * DeviceManager.resultMaxModalRatioC))
				+ ((((numWidth / 2) * DeviceManager.resultModalRatioC) + 3 * DeviceManager.resultMaxModalRatioC) * 3)
				/*
					5자리 숫자표시의 경우 숫자 생성시 for문을 5번 돌린 다음
					+ ((((numWidth / 2) * DeviceManager.resultModalRatioC) + 3 * DeviceManager.resultMaxModalRatioC) * 3)
				
				*/
				+ 3 * DeviceManager.resultMaxModalRatioC
			, yAxis, numWidth * DeviceManager.resultModalRatioC , numHeight * DeviceManager.resultModalRatioC);
	}
	
	////////////////
	
	func FitModalLocationToCenter() {
		modalView.frame = DeviceManager.resultModalSizeRect;
		if (modalView.maskView != nil) {
			modalView.maskView!.frame = CGRectMake(0, 0, modalView.frame.width, modalView.frame.height);
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning();
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		//Off overlay
		if (numUPTimer != nil) {
			print("Force timer finish");
			numUPTimer!.invalidate(); numUPTimer = nil;
		}
		if (GamePlayView.selfView != nil) {
			GamePlayView.selfView!.toggleOverlay(false);
		}
		
		gamePreviewImageView!.stopAnimatingGIF();
		
		self.dismissViewControllerAnimated(true, completion: nil);
	} //end func
	
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_PLAYGAME_READY);
	}
	
	override func viewWillDisappear(animated: Bool) {
		AnalyticsManager.untrackScreen(); //untrack to previous screen
	}
	
	override func viewDidAppear(animated: Bool) {
		gamePreviewImageView!.startAnimatingGIF();
		//이 곳에 점수 애니메이션
		showNumbersOnScore(16827);
		
		//queue bounce animation
		self.view.frame = CGRectMake(0, DeviceManager.scrSize!.height,
		                             DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.view.frame = CGRectMake(0, 0,
				DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	var tmpNumCurrent:Float = 0; var tmpNumTimeCurrent:Float = 0; var tmpNumCurrentMax:Float = 0;
	func showNumbersOnScore(score:Int) {
		//숫자 올라가는 애니메이션과 함께 숫자 표시
		if (numUPTimer != nil) {
			numUPTimer!.invalidate(); numUPTimer = nil;
		}
		tmpNumCurrentMax = Float(score); tmpNumCurrent = 0; tmpNumTimeCurrent = 2;
		numUPTimer = UPUtils.setInterval(0.01, block: scoreTick);
	}
	
	func tickNum() {
		tmpNumTimeCurrent *= 1.12;
		tmpNumCurrent = tmpNumCurrentMax - (tmpNumCurrentMax / tmpNumTimeCurrent);
		
		if (tmpNumCurrent >= tmpNumCurrentMax - 0.1) {
			tmpNumCurrent = tmpNumCurrentMax;
		}
	}
	func scoreTick() { //Score에 대한 틱
		tickNum();
		
		//숫자 표시
		let tmpStr:String = String(Int(round(tmpNumCurrent)));
		for i:Int in 0 ..< bestNumPointers.count {
			if (tmpStr.characters.count - (i+1) < 0) {
				bestNumPointers[i].image = blackNumbers[0];
				bestNumPointers[i].alpha = 0.5;
			} else {
				bestNumPointers[i].image = blackNumbers[ Int(tmpStr[tmpStr.characters.count - (i+1)])! ];
				bestNumPointers[i].alpha = 1;
			}
		}
		
		if (tmpNumCurrent >= tmpNumCurrentMax) {
			numUPTimer!.invalidate(); numUPTimer = nil;
			print("Timer end");
		}
	} //end of scoretick
	
	func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
		gameCenterViewController.dismissViewControllerAnimated(true, completion: nil);
	}
	
}