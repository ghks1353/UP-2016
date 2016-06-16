//
//  GameResultView.swift
//  UP
//
//  Created by ExFl on 2016. 5. 29..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;

class GameResultView:UIViewController {
	
	var XAXIS_PRESET_PAD:CGFloat = 0;
	var YAXIS_PRESET_PAD:CGFloat = 6;
	
	var XAXIS_PRESET_LV_PAD:CGFloat = -8;
	var XAXIS_PRESET_LV_R_PAD:CGFloat = -13;
	var YAXIS_PRESET_LV_PAD:CGFloat = -10;
	
	//for access
	static var selfView:GameResultView?;
	
	//Floating view
	var modalView:UIView = UIView();
	
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
	
	//경험치, 레벨 인디케이터
	var charLevelWrapper:UIImageView = UIImageView();
	var charLevelIndicator:UIImageView = UIImageView();
	
	var charExpWrapper:UIImageView = UIImageView(); var charExpMaskView:UIView = UIView(); //Exp 내용물 마스크 처리를 위함
	var charExpProgress:UIView = UIView(); var charExpProgressImageView:UIImageView = UIImageView();
	var charExpProgressAnimationImages:Array<UIImage> = [];
	//레벨 표시를 위한 인디케이터 배열
	var charLevelDigitalArr:Array<UIImageView> = Array<UIImageView>();
	///////////////
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor();
		
		GameResultView.selfView = self;
		
		//ModalView
		modalView.backgroundColor = UIColor.whiteColor();
		modalView.frame = DeviceGeneral.resultModalSizeRect;
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
		scrollView.frame = CGRectMake(0, 0, modalView.frame.width, 146 * DeviceGeneral.resultModalRatioC);
		scrollView.contentSize = CGSizeMake(scrollView.frame.width * 2, scrollView.frame.height); //100은 추정치?
		
		///// Score 부분 만들기
		let scoreUIView:UIView = UIView(); scoreUIView.frame = CGRectMake(scrollView.frame.width * 0, 0, scrollView.frame.width, scrollView.frame.height);
		let scoreImgView:UIImageView = UIImageView( image: UIImage( named: "result-score.png" ));
		scoreImgView.frame = CGRectMake((modalView.frame.width / 2) - ((118 * DeviceGeneral.resultModalRatioC) / 2), (37 - YAXIS_PRESET_PAD) * DeviceGeneral.resultModalRatioC, (118 * DeviceGeneral.resultModalRatioC), (23.75 * DeviceGeneral.resultModalRatioC));
		scoreUIView.backgroundColor = UIColor.clearColor();
		scoreUIView.addSubview(scoreImgView);
		
		//Score에 대한 숫자 추가
		for i:Int in 0 ..< 3 { //<-5자리면 5로 변경
			let scoreNumber:UIImageView = UIImageView( image: blackNumbers[0] );
			scoreNumber.frame = getNumberLocForIndex(i, yAxis: scoreImgView.frame.maxY + (8 * DeviceGeneral.resultModalRatioC));
			scoreUIView.addSubview(scoreNumber); scoreNumPointers += [ scoreNumber ];
		} //숫자 표시용 디지털 숫자 노드 3개
		
		///// best 부분 만들기
		let bestUIView:UIView = UIView(); bestUIView.frame = CGRectMake(scrollView.frame.width * 1, 0, scrollView.frame.width, scrollView.frame.height);
		let bestImgView:UIImageView = UIImageView( image: UIImage( named: "result-best.png" ));
		bestImgView.frame = CGRectMake((modalView.frame.width / 2) - ((84 * DeviceGeneral.resultModalRatioC) / 2), (32 - YAXIS_PRESET_PAD) * DeviceGeneral.resultModalRatioC, (84 * DeviceGeneral.resultModalRatioC), (32.65 * DeviceGeneral.resultModalRatioC));
		bestUIView.backgroundColor = UIColor.clearColor();
		bestUIView.addSubview(bestImgView);
		
		//Best에 대한 숫자 추가
		for i:Int in 0 ..< 3 {
			let bestNumber:UIImageView = UIImageView( image: blackNumbers[0] );
			bestNumber.frame = getNumberLocForIndex(i, yAxis: bestImgView.frame.maxY + (6 * DeviceGeneral.resultModalRatioC));
			bestUIView.addSubview(bestNumber); bestNumPointers += [ bestNumber ];
		} //숫자 표시용 디지털 숫자 노드 3개
		
		//페이지 추가
		scrollView.addSubview(scoreUIView);
		scrollView.addSubview(bestUIView);
		
		modalView.addSubview(scrollView);
		
		///// 배경 추가
		resultDecorationBG.image = UIImage( named: "result-game-background.png" );
		resultDecorationBG.frame = CGRectMake(0, scrollView.frame.maxY, modalView.frame.width, 194 * DeviceGeneral.resultModalRatioC);
		resultDecoBGMask.frame = resultDecorationBG.frame; resultDecoBGMask.backgroundColor = UIColor.blackColor();
		resultDecorationBG.contentMode = .ScaleAspectFit;
		modalView.addSubview(resultDecoBGMask); modalView.addSubview(resultDecorationBG);
		
		///// 배경 위의 레벨 등 컴포넌트
		charLevelWrapper.image = UIImage( named: "characterinfo-level-wrapper.png" );
		charLevelIndicator.image = UIImage( named: "characterinfo-level.png" );
		charExpWrapper.image = UIImage( named: "characterinfo-exp-wrapper.png" );
		modalView.addSubview(charLevelWrapper); modalView.addSubview(charLevelIndicator); modalView.addSubview(charExpWrapper);
		//마스크 레이어
		charExpMaskView.backgroundColor = UIColor.clearColor();
		modalView.addSubview(charExpMaskView);
		//+20
		charLevelWrapper.frame = CGRectMake( (187.5 - XAXIS_PRESET_LV_R_PAD) * DeviceGeneral.modalRatioC, (153 - YAXIS_PRESET_LV_PAD) * DeviceGeneral.modalRatioC,
		                                     104.5 * DeviceGeneral.modalRatioC, 61.75 * DeviceGeneral.modalRatioC);
		charLevelIndicator.frame = CGRectMake( (143.5 - XAXIS_PRESET_LV_R_PAD) * DeviceGeneral.modalRatioC, (183 - YAXIS_PRESET_LV_PAD) * DeviceGeneral.modalRatioC,
		                                       38 * DeviceGeneral.modalRatioC, 33.25 * DeviceGeneral.modalRatioC);
		charExpWrapper.frame = CGRectMake( (20.5 - XAXIS_PRESET_LV_PAD) * DeviceGeneral.modalRatioC, (168 - YAXIS_PRESET_LV_PAD) * DeviceGeneral.modalRatioC,
		                                   95 * DeviceGeneral.modalRatioC, 57 * DeviceGeneral.modalRatioC);
		//마스크용 프레임 배치
		charExpMaskView.frame = CGRectMake((25.4 - XAXIS_PRESET_LV_PAD) * DeviceGeneral.modalRatioC, (173.5 - YAXIS_PRESET_LV_PAD) * DeviceGeneral.modalRatioC,
		                                   80.5 * DeviceGeneral.modalRatioC, 47 * DeviceGeneral.modalRatioC);
		let maskLayer:CAShapeLayer = CAShapeLayer();
		let cMaskRect = CGRectMake(0, 0, 82 * DeviceGeneral.modalRatioC, 49 * DeviceGeneral.modalRatioC);
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
			tmpView.frame = CGRectMake( ((205.5 - XAXIS_PRESET_LV_R_PAD) * DeviceGeneral.modalRatioC) + ((24 * CGFloat(i)) * DeviceGeneral.maxModalRatioC)
				, (171 - YAXIS_PRESET_LV_PAD) * DeviceGeneral.modalRatioC,
				  19.15 * DeviceGeneral.modalRatioC, 26.80 * DeviceGeneral.modalRatioC );
			modalView.addSubview(tmpView);
			charLevelDigitalArr += [tmpView];
		}
		/////////////////
		
		//// 버튼 추가
		resultButtonList.setImage(UIImage(named: "result-btn-list.png"), forState: .Normal);
		resultButtonRanking.setImage(UIImage(named: "result-btn-ranking.png"), forState: .Normal);
		resultButtonRetry.setImage(UIImage(named: "result-btn-retry.png"), forState: .Normal);
		
		resultButtonList.frame = CGRectMake(modalView.frame.width / 2 - (62 * DeviceGeneral.resultModalRatioC) * 2,
		                                    resultDecorationBG.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceGeneral.resultModalRatioC,
		                                    62 * DeviceGeneral.resultModalRatioC, 62 * DeviceGeneral.resultModalRatioC);
		
		resultButtonRetry.frame = CGRectMake(modalView.frame.width / 2 - (62 * DeviceGeneral.resultModalRatioC) / 2,
		                                     resultDecorationBG.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceGeneral.resultModalRatioC,
		                                     62 * DeviceGeneral.resultModalRatioC, 62 * DeviceGeneral.resultModalRatioC);
		
		resultButtonRanking.frame = CGRectMake(modalView.frame.width / 2 + (62 * DeviceGeneral.resultModalRatioC),
		                                    resultDecorationBG.frame.maxY + (22 - YAXIS_PRESET_PAD) * DeviceGeneral.resultModalRatioC,
		                                    62 * DeviceGeneral.resultModalRatioC, 62 * DeviceGeneral.resultModalRatioC);
		
		modalView.addSubview(resultButtonList);
		modalView.addSubview(resultButtonRetry);
		modalView.addSubview(resultButtonRanking);
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff (result mask)
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask-result.png"));
		modalMaskImageView.frame = modalView.frame;
		modalMaskImageView.contentMode = .ScaleAspectFit; self.view.maskView = modalMaskImageView;
		
		FitModalLocationToCenter();
		refreshExpLevels();
	}
	
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
		charExpProgress.frame = CGRectMake( (-14 * DeviceGeneral.modalRatioC), 0,
		                                    (80.5 * DeviceGeneral.modalRatioC) * CGFloat(CharacterManager.getExpProgress())
			, 47 * DeviceGeneral.modalRatioC);
		charExpProgressImageView.frame = CGRectMake(charExpProgress.frame.maxX, 0, 47 * DeviceGeneral.modalRatioC, 47 * DeviceGeneral.modalRatioC);
		
	}
	
	func getNumberLocForIndex(index:Int, yAxis:CGFloat) -> CGRect {
		let numWidth:CGFloat = 38; let numHeight:CGFloat = 53.2;
		return CGRectMake(
			(modalView.frame.width / 2) - (CGFloat(index) * ((numWidth * DeviceGeneral.resultModalRatioC) + 6 * DeviceGeneral.resultMaxModalRatioC))
				+ ((((numWidth / 2) * DeviceGeneral.resultModalRatioC) + 3 * DeviceGeneral.resultMaxModalRatioC))
				/*
					5자리 숫자표시의 경우 숫자 생성시 for문을 5번 돌린 다음
					+ ((((numWidth / 2) * DeviceGeneral.resultModalRatioC) + 3 * DeviceGeneral.resultMaxModalRatioC) * 3)
				
				*/
				+ 3 * DeviceGeneral.resultMaxModalRatioC
			, yAxis, numWidth * DeviceGeneral.resultModalRatioC , numHeight * DeviceGeneral.resultModalRatioC);
	}
	
	////////////////
	
	func FitModalLocationToCenter() {
		if (self.view.maskView != nil) {
			self.view.maskView!.frame = DeviceGeneral.resultModalSizeRect;
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning();
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
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
		self.view.frame = CGRectMake(0, DeviceGeneral.scrSize!.height,
		                             DeviceGeneral.scrSize!.width, DeviceGeneral.scrSize!.height);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.view.frame = CGRectMake(0, 0,
				DeviceGeneral.scrSize!.width, DeviceGeneral.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
}