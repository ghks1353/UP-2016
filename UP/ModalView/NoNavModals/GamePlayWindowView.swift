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

class GamePlayWindowView:UIViewController {
	
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
	var resultButtonPlay:UIButton = UIButton(); //<- 일반게임 시 가운데
	
	//number up timers
	var numUPTimer:Timer?;
	
	//게임플레이 프리뷰 이미지뷰
	var gamePreviewImageView:GIFImageView?;
	
	///////////////
	
	//현재 지정된 게임
	var currentGameID:Int = 0;
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = UIColor.clear;
		
		GamePlayWindowView.selfView = self;
		
		//ModalView
		modalView.backgroundColor = UIColor.white;
		modalView.frame = DeviceManager.resultModalSizeRect;
		self.view.addSubview(modalView);
		
		//리소스 제작
		for i:Int in 0 ..< 10 {
			blackNumbers += [ UIImage( named: SkinManager.getDefaultAssetPresets() + "black-" + String(i) + ".png" )! ];
		}
		
		// ** 레이아웃들 패드의 경우 특수처리 필요 **
		if (UIDevice.current.userInterfaceIdiom == .phone) {
			XAXIS_PRESET_PAD = 0; YAXIS_PRESET_PAD = 0;
			XAXIS_PRESET_LV_PAD = 0; YAXIS_PRESET_LV_PAD = 0;
			XAXIS_PRESET_LV_R_PAD = 0;
		}
		
		//ScrollView create.
		scrollView.isPagingEnabled = true;
		scrollView.frame = CGRect(x: 0, y: 0, width: modalView.frame.width, height: 146 * DeviceManager.resultModalRatioC);
		scrollView.contentSize = CGSize(width: scrollView.frame.width * 1, height: scrollView.frame.height);
		
		///// best 부분 만들기
		let bestUIView:UIView = UIView(); bestUIView.frame = CGRect(x: scrollView.frame.width * 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height);
		let bestImgView:UIImageView = UIImageView( image: UIImage( named: "result-best.png" ));
		bestImgView.frame = CGRect(x: (modalView.frame.width / 2) - ((84 * DeviceManager.resultModalRatioC) / 2), y: (32 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC, width: (84 * DeviceManager.resultModalRatioC), height: (32.65 * DeviceManager.resultModalRatioC));
		bestUIView.backgroundColor = UIColor.clear;
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
		gamePreviewImageView = GIFImageView(frame: CGRect(x: 0, y: scrollView.frame.maxY, width: modalView.frame.width, height: 194 * DeviceManager.resultModalRatioC) );
		resultDecoBGMask.frame = gamePreviewImageView!.frame; resultDecoBGMask.backgroundColor = UIColor.black;
		modalView.addSubview(resultDecoBGMask);
		modalView.addSubview(gamePreviewImageView!);
		
		gamePreviewImageView!.contentMode = .scaleAspectFit;
		
		//// 버튼 추가
		resultButtonList.setImage(UIImage(named: "result-btn-list.png"), for: UIControlState());
		resultButtonRanking.setImage(UIImage(named: "result-btn-ranking.png"), for: UIControlState());
		resultButtonPlay.setImage(UIImage(named: "result-btn-play.png"), for: UIControlState());
		
		resultButtonList.frame = CGRect(x: modalView.frame.width / 2 - (62 * DeviceManager.resultModalRatioC) * 2,
		                                    y: gamePreviewImageView!.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                    width: 62 * DeviceManager.resultModalRatioC, height: 62 * DeviceManager.resultModalRatioC);
		
		resultButtonPlay.frame = CGRect(x: modalView.frame.width / 2 - (62 * DeviceManager.resultModalRatioC) / 2,
		                                     y: gamePreviewImageView!.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                     width: 62 * DeviceManager.resultModalRatioC, height: 62 * DeviceManager.resultModalRatioC);
		
		resultButtonRanking.frame = CGRect(x: modalView.frame.width / 2 + (62 * DeviceManager.resultModalRatioC),
		                                    y: gamePreviewImageView!.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                    width: 62 * DeviceManager.resultModalRatioC, height: 62 * DeviceManager.resultModalRatioC);
		
		modalView.addSubview(resultButtonList);
		modalView.addSubview(resultButtonPlay);
		modalView.addSubview(resultButtonRanking);
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff (result mask)
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask-result.png"));
		modalMaskImageView.frame = CGRect(x: 0, y: 0, width: modalView.frame.width, height: modalView.frame.height);
		modalMaskImageView.contentMode = .scaleAspectFit; modalView.mask = modalMaskImageView;
		
		FitModalLocationToCenter();
		
		//버튼 이벤트 바인딩
		resultButtonList.addTarget(self, action: #selector(GamePlayWindowView.viewCloseAction), for: .touchUpInside);
		resultButtonRanking.addTarget(self, action: #selector(GamePlayWindowView.showLeaderboard), for: .touchUpInside);
		resultButtonPlay.addTarget(self, action: #selector(GamePlayWindowView.startPlayGame), for: .touchUpInside);
	}
	
	//게임 시작
	func startPlayGame() {
		print("Preparing to play!");
		GameModeView.setGame( currentGameID ); //게임 id 전달
		
		self.view.frame = CGRect(x: 0, y: 0,
		                             width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseOut, animations: {
			self.view.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
				width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
		}) { _ in
			self.dismiss(animated: false, completion: { _ in
				ViewController.selfView!.runGame(); //게임 시작 호출
			});
		}
		
		
	}
	
	//리더보드 표시 함수
	func showLeaderboard() {
		
	}
	
	func setGame( _ gameID:Int ) {
		currentGameID = gameID;
		switch ( gameID ) {
			case 0:
				gamePreviewImageView!.animate(withGIFNamed: "game-jumpup-assets-playpreview.gif");
				break;
			default: break;
		}
	}
	
	func getNumberLocForIndex(_ index:Int, yAxis:CGFloat) -> CGRect {
		let numWidth:CGFloat = 38; let numHeight:CGFloat = 53.2;
		var cgrPoint:CGPoint = CGPoint();
		cgrPoint.x = (modalView.frame.width / 2);
		cgrPoint.x = cgrPoint.x - (CGFloat(index) * ((numWidth * DeviceManager.resultModalRatioC) + 6 * DeviceManager.resultMaxModalRatioC));
		cgrPoint.x = cgrPoint.x + ((((numWidth / 2) * DeviceManager.resultModalRatioC) + 3 * DeviceManager.resultMaxModalRatioC) * 3);
		cgrPoint.x = cgrPoint.x + 3 * DeviceManager.resultMaxModalRatioC;
		
		return CGRect(
			x: cgrPoint.x
				/*
					5자리 숫자표시의 경우 숫자 생성시 for문을 5번 돌린 다음
					+ ((((numWidth / 2) * DeviceManager.resultModalRatioC) + 3 * DeviceManager.resultMaxModalRatioC) * 3)
				
				*/
			, y: yAxis, width: numWidth * DeviceManager.resultModalRatioC , height: numHeight * DeviceManager.resultModalRatioC);
	}
	
	////////////////
	
	func FitModalLocationToCenter() {
		modalView.frame = DeviceManager.resultModalSizeRect;
		if (modalView.mask != nil) {
			modalView.mask!.frame = CGRect(x: 0, y: 0, width: modalView.frame.width, height: modalView.frame.height);
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
		
		self.dismiss(animated: true, completion: nil);
	} //end func
	
	override func viewWillAppear(_ animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		gamePreviewImageView!.startAnimatingGIF();
		
		//이 곳에 점수 애니메이션
		showNumbersOnScore( GameManager.loadBestScore( currentGameID ) );
		
		//베스트 쪽 스크롤 초기화
		self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false);
		
		//queue bounce animation
		self.view.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
		                             width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
			self.view.frame = CGRect(x: 0, y: 0,
				width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	var tmpNumCurrent:Float = 0; var tmpNumTimeCurrent:Float = 0; var tmpNumCurrentMax:Float = 0;
	func showNumbersOnScore(_ score:Int) {
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
	
	
}
