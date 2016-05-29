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
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff (result mask)
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask-result.png"));
		modalMaskImageView.frame = modalView.frame;
		modalMaskImageView.contentMode = .ScaleAspectFit; self.view.maskView = modalMaskImageView;
		
		FitModalLocationToCenter();
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