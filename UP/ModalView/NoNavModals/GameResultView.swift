//
//  GameResultView.swift
//  UP
//
//  Created by ExFl on 2016. 5. 29..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;
import GameKit;

class GameResultView:UIViewController, GKGameCenterControllerDelegate {
	
	var XAXIS_PRESET_PAD:CGFloat = 0;
	var YAXIS_PRESET_PAD:CGFloat = 6;
	
	var XAXIS_PRESET_LV_PAD:CGFloat = -8;
	var XAXIS_PRESET_LV_R_PAD:CGFloat = -13;
	var YAXIS_PRESET_LV_PAD:CGFloat = -10;
	
	//for access
	static var selfView:GameResultView?;
	
	//Floating view
	var modalView:UIView = UIView();
	//Floating SNS
	var modalSNSView:UIView = UIView();
	
	//숫자 리소스 추가
	var blackNumbers:Array<UIImage> = [];
	
	//숫자 조작을 위한 포인터
	var scoreNumPointers:Array<UIImageView> = [];
	var bestNumPointers:Array<UIImageView> = [];
	
	//Score/Best 표시를 위한 페이징 뷰
	var scrollView:UIScrollView = UIScrollView();
	
	//가운데 결과창 데코 배경, 배경 색
	var resultDecoBGMask:UIView = UIView();
	var resultDecorationBG:UIImageView = UIImageView();
	
	//버튼 (일반 게임 결과창)
	var resultButtonList:UIButton = UIButton();
	var resultButtonRanking:UIButton = UIButton();
	var resultButtonRetry:UIButton = UIButton(); //<- 일반게임 시 가운데
	//버튼 (알람 결과창. 닫기버튼만)
	var resultButtonClose:UIButton = UIButton();
	
	//버튼 활성화 여부
	var rbuttonEnabled:Bool = false;
	
	//경험치, 레벨 인디케이터
	var charLevelWrapper:UIImageView = UIImageView();
	var charLevelIndicator:UIImageView = UIImageView();
	
	var charExpWrapper:UIImageView = UIImageView(); var charExpMaskView:UIView = UIView(); //Exp 내용물 마스크 처리를 위함
	var charExpProgress:UIView = UIView(); var charExpProgressImageView:UIImageView = UIImageView();
	var charExpProgressAnimationImages:Array<UIImage> = [];
	var charCurrentCharacter:UIImageView = UIImageView();
	
	//number up timers
	var numUPTimer:NSTimer?;
	
	//레벨 표시를 위한 인디케이터 배열
	var charLevelDigitalArr:Array<UIImageView> = Array<UIImageView>();
	
	//창 타입에 따른 이미지 (타임, 스코어)
	var imgScoreUIView:UIImageView = UIImageView(); var imgTimeUIView:UIImageView = UIImageView();
	
	//보여줄 점수
	var currentType:Int = 0;
	var gameScore:Int = 0; var gameBestScore:Int = 0;
	
	//목록, 다시하기, 랭킹에 대해 작동하려면 게임 ID가 입력되어 있어야함
	var currentGameID:Int = 0;
	
	///////////////
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		GameResultView.selfView = self;
		
		//ModalView
		modalView.backgroundColor = UIColor.whiteColor();
		modalView.frame = CGRectMake(DeviceManager.resultModalSizeRect.minX, DeviceManager.resultModalSizeRect.minY - 36 * DeviceManager.resultModalRatioC,
		DeviceManager.resultModalSizeRect.width, DeviceManager.resultModalSizeRect.height);
		self.view.addSubview(modalView);
		//ModalView (SNS)
		modalSNSView.backgroundColor = UIColor.whiteColor();
		modalSNSView.frame = CGRectMake(DeviceManager.resultModalSizeRect.minX, modalView.frame.maxY + 18 * DeviceManager.resultModalRatioC,
		                             DeviceManager.resultModalSizeRect.width, 72 * DeviceManager.resultModalRatioC);
		self.view.addSubview(modalSNSView);
		
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
		scrollView.contentSize = CGSizeMake(scrollView.frame.width * 2, scrollView.frame.height); //100은 추정치?
		
		///// Score 부분 만들기
		let scoreUIView:UIView = UIView(); scoreUIView.frame = CGRectMake(scrollView.frame.width * 0, 0, scrollView.frame.width, scrollView.frame.height);
		imgScoreUIView = UIImageView( image: UIImage( named: "result-score.png" ));
		imgScoreUIView.frame = CGRectMake((modalView.frame.width / 2) - ((118 * DeviceManager.resultModalRatioC) / 2), (37 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC, (118 * DeviceManager.resultModalRatioC), (23.75 * DeviceManager.resultModalRatioC));
		scoreUIView.backgroundColor = UIColor.clearColor();
		scoreUIView.addSubview(imgScoreUIView);
		imgTimeUIView = UIImageView( image: UIImage( named: "result-time.png" ));
		imgTimeUIView.frame = CGRectMake((modalView.frame.width / 2) - ((75.4 * DeviceManager.resultModalRatioC) / 2), (28 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC, (75.4 * DeviceManager.resultModalRatioC), (33 * DeviceManager.resultModalRatioC));
		scoreUIView.addSubview(imgTimeUIView);
		
		//Score에 대한 숫자 추가
		for i:Int in 0 ..< 5 { //<-5자리면 5로 변경
			let scoreNumber:UIImageView = UIImageView( image: blackNumbers[0] );
			scoreNumber.frame = getNumberLocForIndex(i, yAxis: imgScoreUIView.frame.maxY + (8 * DeviceManager.resultModalRatioC));
			scoreUIView.addSubview(scoreNumber); scoreNumPointers += [ scoreNumber ];
		} //숫자 표시용 디지털 숫자 노드 3개
		
		///// best 부분 만들기
		let bestUIView:UIView = UIView(); bestUIView.frame = CGRectMake(scrollView.frame.width * 1, 0, scrollView.frame.width, scrollView.frame.height);
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
		scrollView.addSubview(scoreUIView);
		scrollView.addSubview(bestUIView);
		
		modalView.addSubview(scrollView);
		
		///// 배경 추가
		resultDecorationBG.image = UIImage( named: "result-game-background.png" );
		resultDecorationBG.frame = CGRectMake(0, scrollView.frame.maxY, modalView.frame.width, 194 * DeviceManager.resultModalRatioC);
		resultDecoBGMask.frame = resultDecorationBG.frame; resultDecoBGMask.backgroundColor = UIColor.blackColor();
		resultDecorationBG.contentMode = .ScaleAspectFit;
		modalView.addSubview(resultDecoBGMask); modalView.addSubview(resultDecorationBG);
		
		///// 배경 위의 레벨 등 컴포넌트
		charLevelWrapper.image = UIImage( named: "characterinfo-level-wrapper.png" );
		charLevelIndicator.image = UIImage( named: "characterinfo-level.png" );
		charExpWrapper.image = UIImage( named: "characterinfo-exp-wrapper.png" );
		charCurrentCharacter.image = UIImage( named: SkinManager.getAssetPresetsCharacter() + "character_" + "0001" + ".png" ); //현재 캐릭터 스킨 불러오기
		modalView.addSubview(charLevelWrapper); modalView.addSubview(charLevelIndicator); modalView.addSubview(charExpWrapper);
		modalView.addSubview(charCurrentCharacter);
		//마스크 레이어
		charExpMaskView.backgroundColor = UIColor.clearColor();
		modalView.addSubview(charExpMaskView);
		//+20
		charLevelWrapper.frame = CGRectMake( (187.5 - XAXIS_PRESET_LV_R_PAD) * DeviceManager.modalRatioC, (153 - YAXIS_PRESET_LV_PAD) * DeviceManager.modalRatioC,
		                                     104.5 * DeviceManager.modalRatioC, 61.75 * DeviceManager.modalRatioC);
		charLevelIndicator.frame = CGRectMake( (143.5 - XAXIS_PRESET_LV_R_PAD) * DeviceManager.modalRatioC, (183 - YAXIS_PRESET_LV_PAD) * DeviceManager.modalRatioC,
		                                       38 * DeviceManager.modalRatioC, 33.25 * DeviceManager.modalRatioC);
		charExpWrapper.frame = CGRectMake( (20.5 - XAXIS_PRESET_LV_PAD) * DeviceManager.modalRatioC, (168 - YAXIS_PRESET_LV_PAD) * DeviceManager.modalRatioC,
		                                   95 * DeviceManager.modalRatioC, 57 * DeviceManager.modalRatioC);
		//마스크용 프레임 배치
		charExpMaskView.frame = CGRectMake((25.4 - XAXIS_PRESET_LV_PAD) * DeviceManager.modalRatioC, (173.5 - YAXIS_PRESET_LV_PAD) * DeviceManager.modalRatioC,
		                                   80.5 * DeviceManager.modalRatioC, 47 * DeviceManager.modalRatioC);
		charCurrentCharacter.frame = CGRectMake( 6 * DeviceManager.modalRatioC, resultDecorationBG.frame.maxY - 195 * DeviceManager.modalRatioC, 300 * DeviceManager.modalRatioC, 300 * DeviceManager.modalRatioC );
		
		let maskLayer:CAShapeLayer = CAShapeLayer();
		let cMaskRect = CGRectMake(0, 0, 82 * DeviceManager.modalRatioC, 49 * DeviceManager.modalRatioC);
		let cPath:CGPathRef = CGPathCreateWithRect(cMaskRect, nil);
		maskLayer.path = cPath;
		charExpMaskView.layer.mask = maskLayer;
		//charExpMaskView.backgroundColor = UIColor.whiteColor();
		//경험치 막대
		charExpProgress.backgroundColor = UPUtils.colorWithHexString("#00CC33");
		//경험치 막대 옆에 붙는 데코
		for i:Int in 0 ..< 33 {
			charExpProgressAnimationImages += [ UIImage( named: "characterinfo-exp-deco-" + String(i) + ".png" )! ];
		}
		charExpProgressImageView.animationImages = charExpProgressAnimationImages;
		charExpProgressImageView.animationDuration = 1.1; charExpProgressImageView.animationRepeatCount = -1;
		charExpProgressImageView.startAnimating();
		charExpMaskView.addSubview(charExpProgress); charExpMaskView.addSubview(charExpProgressImageView); // 마스크 씌울 것이기 때문에 이 안에다.
		
		//레벨 숫자 배치
		for i:Int in 0 ..< 3 {
			let tmpView:UIImageView = UIImageView();
			tmpView.image = UIImage( named: SkinManager.getDefaultAssetPresets() +  "0" + ".png"  );
			tmpView.frame = CGRectMake( ((205.5 - XAXIS_PRESET_LV_R_PAD) * DeviceManager.modalRatioC) + ((24 * CGFloat(i)) * DeviceManager.maxModalRatioC)
				, (171 - YAXIS_PRESET_LV_PAD) * DeviceManager.modalRatioC,
				  19.15 * DeviceManager.modalRatioC, 26.80 * DeviceManager.modalRatioC );
			modalView.addSubview(tmpView);
			charLevelDigitalArr += [tmpView];
		}
		/////////////////
		
		//// 버튼 추가
		resultButtonList.setImage(UIImage(named: "result-btn-list.png"), forState: .Normal);
		resultButtonRanking.setImage(UIImage(named: "result-btn-ranking.png"), forState: .Normal);
		resultButtonRetry.setImage(UIImage(named: "result-btn-retry.png"), forState: .Normal);
		
		//닫기 버튼
		resultButtonClose.setImage(UIImage(named: "result-btn-close.png"), forState: .Normal);
		
		resultButtonList.frame = CGRectMake(modalView.frame.width / 2 - (62 * DeviceManager.resultModalRatioC) * 2,
		                                    resultDecorationBG.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                    62 * DeviceManager.resultModalRatioC, 62 * DeviceManager.resultModalRatioC);
		resultButtonRetry.frame = CGRectMake(modalView.frame.width / 2 - (62 * DeviceManager.resultModalRatioC) / 2,
		                                     resultDecorationBG.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                     62 * DeviceManager.resultModalRatioC, 62 * DeviceManager.resultModalRatioC);
		resultButtonRanking.frame = CGRectMake(modalView.frame.width / 2 + (62 * DeviceManager.resultModalRatioC),
		                                    resultDecorationBG.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceManager.resultModalRatioC,
		                                    62 * DeviceManager.resultModalRatioC, 62 * DeviceManager.resultModalRatioC);
		
		resultButtonClose.frame = resultButtonRetry.frame;
		
		modalView.addSubview(resultButtonList);
		modalView.addSubview(resultButtonRetry);
		modalView.addSubview(resultButtonRanking);
		modalView.addSubview(resultButtonClose);

		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff (result mask)
		var modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask-result.png"));
		modalMaskImageView.frame = CGRectMake(0, 0, modalView.frame.width, modalView.frame.height);
		modalMaskImageView.contentMode = .ScaleAspectFit; modalView.maskView = modalMaskImageView;
		modalMaskImageView = UIImageView(image: UIImage(named: "modal-mask-result-sns.png"));
		modalMaskImageView.frame = CGRectMake(0, 0, modalSNSView.frame.width, modalSNSView.frame.height);
		modalMaskImageView.contentMode = .ScaleAspectFit; modalSNSView.maskView = modalMaskImageView;
		
		FitModalLocationToCenter();
		
		//버튼 이벤트 바인딩
		resultButtonClose.addTarget(self, action: #selector(GameResultView.viewCloseAction), forControlEvents: .TouchUpInside);
		
		//이쪽은 게임으로 실행된 경우 버튼들
		resultButtonList.addTarget(self, action: #selector(GameResultView.goToGameMain), forControlEvents: .TouchUpInside);
		resultButtonRetry.addTarget(self, action: #selector(GameResultView.goRetryGame), forControlEvents: .TouchUpInside);
		resultButtonRanking.addTarget(self, action: #selector(GameResultView.showRankingGameCenter), forControlEvents: .TouchUpInside);
	}
	
	func setVariables( gameID:Int = 0, windowType:Int = 0, showingScore:Int = 0, showingBest:Int = 0 ) {
		//Set variables
		currentGameID = gameID;
		
		gameScore = showingScore;
		gameBestScore = showingBest;
		currentType = windowType;
	}
	
	func toggleButtonStatus( status:Bool ) {
		rbuttonEnabled = status;
		if (rbuttonEnabled) {
			resultButtonList.alpha = 1;
		} else {
			resultButtonList.alpha = 0.6;
		}
		resultButtonRetry.alpha = resultButtonList.alpha; resultButtonRanking.alpha = resultButtonList.alpha;
		resultButtonClose.alpha = resultButtonList.alpha;
	} //toggle btns
	
	func refreshExpLevels() {
		//캐릭터 레벨에 대한 숫자 표시
		let levStr = String(CharacterManager.currentCharInfo.characterLevel);
		charLevelDigitalArr[0].alpha = levStr.characters.count < 3 ? 0.6 : 1;
		charLevelDigitalArr[1].alpha = levStr.characters.count < 2 ? 0.6 : 1;
		//Render text
		charLevelDigitalArr[2].image = UIImage(named: SkinManager.getDefaultAssetPresets() + String(UTF8String: levStr[ levStr.characters.count - 1 ])! + ".png" );
		charLevelDigitalArr[1].image =
			levStr.characters.count < 2 ? UIImage( named: SkinManager.getDefaultAssetPresets() +  "0" + ".png"  )
			: UIImage(named: SkinManager.getDefaultAssetPresets() + String(UTF8String: levStr[ levStr.characters.count - 2 ])! + ".png" )
		charLevelDigitalArr[0].image =
			levStr.characters.count < 3 ? UIImage( named: SkinManager.getDefaultAssetPresets() +  "0" + ".png"  )
			: UIImage(named: SkinManager.getDefaultAssetPresets() + String(UTF8String: levStr[ levStr.characters.count - 3 ])! + ".png" )
		
		//경험치량 표시
		//CharacterManager.currentCharInfo.characterExp = 4;
		charExpProgress.frame = CGRectMake( (-14 * DeviceManager.modalRatioC), 0,
		                                    (80.5 * DeviceManager.modalRatioC) * CGFloat(CharacterManager.getExpProgress())
			, 47 * DeviceManager.modalRatioC);
		charExpProgressImageView.frame = CGRectMake(charExpProgress.frame.maxX, 0, 47 * DeviceManager.modalRatioC, 47 * DeviceManager.modalRatioC);
		
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
		modalView.frame = CGRectMake(DeviceManager.resultModalSizeRect.minX, DeviceManager.resultModalSizeRect.minY - 36 * DeviceManager.resultModalRatioC,
		                             DeviceManager.resultModalSizeRect.width, DeviceManager.resultModalSizeRect.height);
		modalSNSView.frame = CGRectMake(DeviceManager.resultModalSizeRect.minX, modalView.frame.maxY + 18 * DeviceManager.resultModalRatioC,
		                                DeviceManager.resultModalSizeRect.width, 72 * DeviceManager.resultModalRatioC);
		if (modalView.maskView != nil) {
			modalView.maskView!.frame = CGRectMake(0, 0, modalView.frame.width, modalView.frame.height);
		}
		if (modalSNSView.maskView != nil) {
			modalSNSView.maskView!.frame = CGRectMake(0, 0, modalSNSView.frame.width, modalSNSView.frame.height);
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning();
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		if (!rbuttonEnabled) {
			return;
		}
		ViewController.viewSelf!.showHideBlurview(false);
		self.dismissViewControllerAnimated(true, completion: nil);
	} //end func
	
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_RESULT);
	}
	
	override func viewWillDisappear(animated: Bool) {
		AnalyticsManager.untrackScreen(); //untrack to previous screen
	}
	
	override func viewDidAppear(animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRectMake(0, DeviceManager.scrSize!.height,
		                             DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.view.frame = CGRectMake(0, 0,
				DeviceManager.scrSize!.width, DeviceManager.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
		
		//베스트 쪽 스크롤 초기화
		self.scrollView.setContentOffset(CGPointMake(0, 0), animated: false);
		
		switch(currentType) {
			case 0:
				resultButtonList.hidden = true; resultButtonRetry.hidden = true; resultButtonRanking.hidden = true;
				resultButtonClose.hidden = false;
				imgScoreUIView.hidden = true; imgTimeUIView.hidden = false;
				break;
			case 1:
				resultButtonList.hidden = false; resultButtonRetry.hidden = false; resultButtonRanking.hidden = false;
				resultButtonClose.hidden = true;
				imgScoreUIView.hidden = false; imgTimeUIView.hidden = true;
				break;
			default: break;
		}
		
		//점수 및 베스트 표시
		refreshExpLevels(); //경험치 변동 있을경우 새로 표시해야 하기에
		showNumbersOnScore(gameScore, autoContinueBest: true, autoContinueBestScore: gameBestScore);
		
	} ///////////////////////////////
	
	var tmpNumCurrent:Float = 0; var tmpNumTimeCurrent:Float = 0; var tmpNumCurrentMax:Float = 0;
	var autoContinueToBest:Bool = false; var autoContinuedBestScore:Int = 0;
	func showNumbersOnScore(score:Int, autoContinueBest:Bool = false, autoContinueBestScore:Int = 0) {
		//숫자 올라가는 애니메이션과 함께 숫자 표시
		if (numUPTimer != nil) {
			numUPTimer!.invalidate(); numUPTimer = nil;
		}
		tmpNumCurrentMax = Float(score); tmpNumCurrent = 0; tmpNumTimeCurrent = 2;
		numUPTimer = UPUtils.setInterval(0.01, block: scoreTick);
		
		if (autoContinueBest == true) {
			//기존 버튼 비활성화
			toggleButtonStatus(false);
		}
		
		autoContinueToBest = autoContinueBest; autoContinuedBestScore = autoContinueBestScore;
	}
	
	func showNumbersOnBest(score:Int) {
		//숫자 올라가는 애니메이션과 함께 숫자 표시 (Best)
		if (numUPTimer != nil) {
			numUPTimer!.invalidate(); numUPTimer = nil;
		}
		tmpNumCurrentMax = Float(score); tmpNumCurrent = 0; tmpNumTimeCurrent = 2;
		numUPTimer = UPUtils.setInterval(0.01, block: bestTick);
		
		autoContinueToBest = false; autoContinuedBestScore = 0;
	}
	
	func tickNum() {
		tmpNumTimeCurrent *= 1.04;
		tmpNumCurrent = tmpNumCurrentMax - (tmpNumCurrentMax / tmpNumTimeCurrent);
		
		if (tmpNumCurrent >= tmpNumCurrentMax - 0.1) {
			tmpNumCurrent = tmpNumCurrentMax;
		}
	}
	func scoreTick() { //Score에 대한 틱
		tickNum();
		
		//숫자 표시
		let tmpStr:String = String(Int(round(tmpNumCurrent)));
		for i:Int in 0 ..< scoreNumPointers.count {
			if (tmpStr.characters.count - (i+1) < 0) {
				scoreNumPointers[i].image = blackNumbers[0];
				scoreNumPointers[i].alpha = 0.5;
			} else {
				scoreNumPointers[i].image = blackNumbers[ Int(tmpStr[tmpStr.characters.count - (i+1)])! ];
				scoreNumPointers[i].alpha = 1;
			}
		}
		
		if (tmpNumCurrent >= tmpNumCurrentMax) {
			numUPTimer!.invalidate(); numUPTimer = nil;
			print("Timer end");
			if (autoContinueToBest == true) {
				//auto-start with delay
				UPUtils.setTimeout(1, block: {
					self.scrollView.setContentOffset(CGPointMake(self.modalView.frame.width, 0), animated: true);
					self.showNumbersOnBest(self.autoContinuedBestScore);
				});
			} //end auto-start
		}
	} //end of scoretick
	func bestTick() { //Best에 대한 틱
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
			print("Timer end (best)");
			toggleButtonStatus(true);
			
		}
	} //end of scoretick
	
	//////////
	
	func goToGameMain() {
		//게임의 메인화면으로 돌아감
		if (!rbuttonEnabled) {
			return;
		}
		self.dismissViewControllerAnimated(true, completion: { _ in
			
			ViewController.viewSelf!.openGamePlayView(nil);
			GamePlayView.selfView!.selectCell( self.currentGameID );
			
		});
	}
	func goRetryGame() {
		//게임 재시작
		if (!rbuttonEnabled) {
			return;
		}
		self.dismissViewControllerAnimated(true, completion: { _ in
			print("Game retry!");
			GameModeView.setGame( self.currentGameID ); //게임 id 전달
			ViewController.viewSelf!.runGame();
		});
	}
	func showRankingGameCenter() {
		//게임센터 랭킹 표시
		
		let gcViewController: GKGameCenterViewController = GKGameCenterViewController();
		gcViewController.gameCenterDelegate = self;
		gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards;
		
		//아이튠즈 커네트에서 순위표id.
		gcViewController.leaderboardIdentifier = GameManager.getLeadboardIDWithGameID( currentGameID );
		
		self.showViewController(gcViewController, sender: self);
		self.presentViewController(gcViewController, animated: true, completion: nil);
	}
	
	//////////////
	func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
		gameCenterViewController.dismissViewControllerAnimated(true, completion: nil);
	}
	
}