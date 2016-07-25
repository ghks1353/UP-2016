//
//  GeneralMenuUI.swift
//  UP
//
//  Created by ExFl on 2016. 7. 26..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class GeneralMenuUI:UIView, UIScrollViewDelegate {
	//THIS IS NOT UIController, pre-attached menu
	
	///////////////////////////////////
	/////////// Callback functions
	var pauseResumeBtnCallback:(() -> Void)? = nil;
	var soundToggleCallback:(() -> Void)? = nil;
	var restartCallback:(() -> Void)? = nil;
	
	var gameForceStopCallback:(() -> Void)? = nil;
	var gameOverCallback:(() -> Void)? = nil;
	var gameShowADCallback:(() -> Void)? = nil;
	
	//////////////// vals
	var isMenuVisible:Bool = true; //알파 효과를 위함
	var prevMenuVis:Bool? = nil;
	
	////////////////////////////////////////////////////////////////////
	/////////////////////////////// UI /////////////////////////////////
	var selfFrame:CGRect?;
	
	//일시정지 버튼 및 메뉴들
	var menuPauseButtonUIImage:UIImage = UIImage(named: "game-general-menu-pause.png")!;
	var menuResumeButtonUIImage:UIImage = UIImage(named: "game-general-menu-play.png")!;
	
	var menuPausedOverlay:UIView = UIView();
	var menuPauseResume:UIButton = UIButton(); //일시정지, 계속하기는 한 버튼으로 우려먹고 이미지만 바꾸기.
	var menuGameStop:UIButton = UIButton();
	var menuGameRestart:UIButton = UIButton();
	var menuSoundControl:UIButton = UIButton();
	var menuGameGuide:UIButton = UIButton();
	
	//Window 메뉴들
	var windowUIView:UIView = UIView();
	var windowBackgroundImage:UIImageView = UIImageView();
	var windowTitleContinue:UIImageView = UIImageView();
	var windowTitleGameOver:UIImageView = UIImageView();
	var windowTitleRetry:UIImageView = UIImageView();
	var windowTitleExit:UIImageView = UIImageView();
	var windowButtonAD:UIButton = UIButton();
	var windowButtonOK:UIButton = UIButton();
	var windowButtonCancel:UIButton = UIButton();
	
	//가이드 뷰
	var windowGuideCloseButton:UIButton = UIButton();
	
	var windowGuideScrollView:UIScrollView = UIScrollView();
	var windowGuidesUIViewArray:Array<UIView> = Array<UIView>();
	var windowGuidesUIViewImages:Array<UIImageView> = Array<UIImageView>();
	
	//좌우 인디케이터. 있나 없나 확인용?
	var windowGuideLeftIndicator:UIImageView = UIImageView();
	var windowGuideRightIndicator:UIImageView = UIImageView();
	
	var windowGuidesLength:Int = 0; //가이드 개수
	var windowGuidesNamePreset:String = ""; //가이드 파일명 프리셋
	
	var openedWindowType:Int = -1; //열린 윈도우의 종류. 버튼 분기때문에 만듬
	
	var selectedGameID:Int = 0;
	
	func setGame( gameID:Int ) {
		switch(gameID) {
			case 0: //jumpup
				windowGuidesNamePreset = "game_jumpup_assets_guide_";
				windowGuidesLength = 4;
				break;
			default: break;
		}
	}
	
	func initUI( frame:CGRect ) { //frame -> screen size
		selfFrame = frame;
		
		//버튼 이미지 설정
		menuPauseResume.setImage(menuPauseButtonUIImage, forState: .Normal);
		menuGameStop.setImage(UIImage(named: "game-general-menu-list.png"), forState: .Normal);
		menuGameRestart.setImage(UIImage(named: "game-general-menu-retry.png"), forState: .Normal);
		menuSoundControl.setImage(UIImage(named: "game-general-menu-soundon.png"), forState: .Normal);
		menuGameGuide.setImage(UIImage(named: "game-general-menu-info.png"), forState: .Normal);
		
		menuPauseResume.frame = CGRectMake( 24, selfFrame!.height - 24 - (61.6 * DeviceManager.maxScrRatioC), 61.6 * DeviceManager.maxScrRatioC, 61.6 * DeviceManager.maxScrRatioC );
		
		menuGameGuide.frame = CGRectMake( menuPauseResume.frame.minX, menuPauseResume.frame.minY - 12 - menuPauseResume.frame.width, menuPauseResume.frame.width, menuPauseResume.frame.height );
		menuSoundControl.frame = CGRectMake( menuPauseResume.frame.minX, menuGameGuide.frame.minY - 12 - menuPauseResume.frame.width, menuPauseResume.frame.width, menuPauseResume.frame.height );
		menuGameRestart.frame = CGRectMake( menuPauseResume.frame.minX, menuSoundControl.frame.minY - 12 - menuPauseResume.frame.width, menuPauseResume.frame.width, menuPauseResume.frame.height );
		menuGameStop.frame = CGRectMake( menuPauseResume.frame.minX, menuGameRestart.frame.minY - 12 - menuPauseResume.frame.width, menuPauseResume.frame.width, menuPauseResume.frame.height );
		
		//오버레이 생성
		menuPausedOverlay.frame = CGRectMake(0, 0, selfFrame!.width, selfFrame!.height);
		menuPausedOverlay.backgroundColor = UIColor.blackColor();
		menuPausedOverlay.alpha = 0.65;
		
		self.addSubview(menuPausedOverlay); menuPausedOverlay.hidden = true;
		self.addSubview(menuPauseResume);
		self.addSubview(menuGameStop); menuGameStop.hidden = true;
		self.addSubview(menuGameRestart); menuGameRestart.hidden = true;
		self.addSubview(menuSoundControl); menuSoundControl.hidden = true;
		self.addSubview(menuGameGuide); menuGameGuide.hidden = true;
		
		//버튼 이벤트 생성
		menuPauseResume.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackMenuToggle), forControlEvents: .TouchUpInside);
		menuGameGuide.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackGuide), forControlEvents: .TouchUpInside);
		menuSoundControl.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackSoundToggle), forControlEvents: .TouchUpInside);
		menuGameRestart.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackRestart), forControlEvents: .TouchUpInside);
		menuGameStop.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackStopGame), forControlEvents: .TouchUpInside);
		
		//// 윈도우 구성. 크기는 패드에서 안 커지게
		windowBackgroundImage.frame = CGRectMake( 0, 0, 257.75 * DeviceManager.maxScrRatioC, 176.5 * DeviceManager.maxScrRatioC );
		windowBackgroundImage.image = UIImage( named: "game-general-window-mask.png" );
		
		windowTitleContinue.frame = CGRectMake(
			windowBackgroundImage.frame.width / 2 - (203.9 * DeviceManager.maxScrRatioC) / 2
			, 24 * DeviceManager.maxScrRatioC, 203.9 * DeviceManager.maxScrRatioC, 26.95 * DeviceManager.maxScrRatioC );
		windowTitleGameOver.frame = CGRectMake(
			windowBackgroundImage.frame.width / 2 - (198.6 * DeviceManager.maxScrRatioC) / 2
			, windowTitleContinue.frame.minY, 198.6 * DeviceManager.maxScrRatioC, 28.35 * DeviceManager.maxScrRatioC );
		windowTitleRetry.frame = CGRectMake(
			windowBackgroundImage.frame.width / 2 - (134.65 * DeviceManager.maxScrRatioC) / 2
			, windowTitleContinue.frame.minY, 134.65 * DeviceManager.maxScrRatioC, 26.95 * DeviceManager.maxScrRatioC );
		windowTitleExit.frame = CGRectMake(
			windowBackgroundImage.frame.width / 2 - (110.95 * DeviceManager.maxScrRatioC) / 2
			, windowTitleContinue.frame.minY, 110.95 * DeviceManager.maxScrRatioC, 26.95 * DeviceManager.maxScrRatioC );
		
		windowTitleContinue.image = UIImage( named: "game-general-window-continue.png" );
		windowTitleGameOver.image = UIImage( named: "game-general-window-gameover.png" );
		windowTitleRetry.image = UIImage( named: "game-general-window-retry.png" );
		windowTitleExit.image = UIImage( named: "game-general-window-exit.png" );
		
		///  이쪽은 버튼
		windowButtonAD.frame = CGRectMake(
			28 * DeviceManager.maxScrRatioC
			, windowTitleContinue.frame.maxY + 32 * DeviceManager.maxScrRatioC, 89.8 * DeviceManager.maxScrRatioC, 65.5 * DeviceManager.maxScrRatioC );
		windowButtonOK.frame = CGRectMake(
			windowButtonAD.frame.minX
			, windowButtonAD.frame.minY, windowButtonAD.frame.width, windowButtonAD.frame.height );
		windowButtonCancel.frame = CGRectMake(
			windowBackgroundImage.frame.width - windowButtonAD.frame.width - windowButtonAD.frame.minX
			, windowButtonAD.frame.minY, windowButtonAD.frame.width, windowButtonAD.frame.height );
		
		windowButtonAD.setImage(UIImage( named: "game-general-window-btn-ads.png" ), forState: .Normal);
		windowButtonOK.setImage(UIImage( named: "game-general-window-btn-ok.png" ), forState: .Normal);
		windowButtonCancel.setImage(UIImage( named: "game-general-window-btn-cancel.png" ), forState: .Normal);
		
		//배경 사진부터 깔고
		windowUIView.addSubview(windowBackgroundImage);
		windowUIView.addSubview(windowTitleContinue);
		windowUIView.addSubview(windowTitleGameOver);
		windowUIView.addSubview(windowTitleRetry);
		windowUIView.addSubview(windowTitleExit);
		windowUIView.addSubview(windowButtonAD);
		windowUIView.addSubview(windowButtonOK);
		windowUIView.addSubview(windowButtonCancel);
		
		//폼 설정
		windowUIView.frame = CGRectMake(
			selfFrame!.width / 2 - windowBackgroundImage.frame.width / 2
			, selfFrame!.height / 2 - windowBackgroundImage.frame.height / 2
			, windowBackgroundImage.frame.width
			, windowBackgroundImage.frame.height
		);
		
		self.addSubview(windowUIView);
		
		//버튼 리스너 설정
		windowButtonAD.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackAD), forControlEvents: .TouchUpInside);
		windowButtonOK.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackOK), forControlEvents: .TouchUpInside);
		windowButtonCancel.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackCancel), forControlEvents: .TouchUpInside);
		
		hideUISelectionWindow();
		
		////// 가이드 폼 만들기
		windowGuideScrollView.frame = CGRectMake(
			0
			, selfFrame!.height / 2 - ( 176.5 * DeviceManager.maxScrRatioC ) / 2
			, selfFrame!.width
			, 176.5 * DeviceManager.maxScrRatioC
		);
		windowGuideScrollView.contentSize = CGSizeMake(
			/* 24 24 lr margin -> content 4x */
			selfFrame!.width * CGFloat(windowGuidesLength)
			, ( 176.5 * DeviceManager.maxScrRatioC )
		);
		for i:Int in 0 ..< windowGuidesLength {
			//loop for content sizes
			let tmpUIView:UIView = UIView(frame:
				CGRectMake( (windowGuideScrollView.contentSize.width / CGFloat(windowGuidesLength) ) * CGFloat(i)
					, 0, (windowGuideScrollView.contentSize.width / CGFloat(windowGuidesLength) )
					, windowGuideScrollView.contentSize.height
				));
			let tmpGuideImg:UIImageView = UIImageView( image: UIImage( named: windowGuidesNamePreset + String(i) + ".png" ) );
			tmpGuideImg.frame = CGRectMake( (selfFrame!.width - (257.75 * DeviceManager.maxScrRatioC)) / 2 //Margin
				, 0, 257.75 * DeviceManager.maxScrRatioC
				, windowGuideScrollView.contentSize.height
			);
			tmpUIView.addSubview(tmpGuideImg);
			windowGuideScrollView.addSubview(tmpUIView);
			
			windowGuidesUIViewArray += [tmpUIView];
			windowGuidesUIViewImages += [tmpGuideImg];
		}
		
		//가이드 슬라이더 추가
		self.addSubview(windowGuideScrollView);
		windowGuideScrollView.pagingEnabled = true;
		
		//가이드 버튼 추가
		windowGuideCloseButton.frame = CGRectMake(
			selfFrame!.width / 2 - menuPauseResume.frame.width / 2,
			windowGuideScrollView.frame.maxY + 100 * DeviceManager.scrRatioC,
			/* same with 61.6 x 61.6 */
			menuPauseResume.frame.width, menuPauseResume.frame.height
		)
		windowGuideCloseButton.setImage( UIImage( named: "game-general-window-btn-close.png" ) , forState: .Normal);
		self.addSubview(windowGuideCloseButton);
		
		//기본 가이드 상태: 가림
		windowGuideScrollView.hidden = true;
		windowGuideCloseButton.hidden = true;
		
		windowGuideScrollView.delegate = self;
		
		//가이드 화살표 추가
		windowGuideLeftIndicator.image = UIImage( named: "game-general-guide-left.png" );
		windowGuideRightIndicator.image = UIImage( named: "game-general-guide-right.png" );
		
		windowGuideLeftIndicator.frame = CGRectMake(
			selfFrame!.width / 2 - ((257.75 * DeviceManager.maxScrRatioC) / 2) - (18 * DeviceManager.maxScrRatioC)
				- (20.4 * DeviceManager.maxScrRatioC)
			, selfFrame!.height / 2 - ((40.8 * DeviceManager.maxScrRatioC) / 2),
			  20.4 * DeviceManager.maxScrRatioC
			, 40.8 * DeviceManager.maxScrRatioC
		);
		windowGuideRightIndicator.frame = CGRectMake(
			selfFrame!.width / 2 + ((257.75 * DeviceManager.maxScrRatioC) / 2) + (18 * DeviceManager.maxScrRatioC)
			, windowGuideLeftIndicator.frame.minY
			, windowGuideLeftIndicator.frame.width
			, windowGuideLeftIndicator.frame.height
		);
		self.addSubview(windowGuideLeftIndicator); self.addSubview(windowGuideRightIndicator);
		windowGuideLeftIndicator.hidden = true; windowGuideRightIndicator.hidden = true;
		
		//가이드 터치 리스너 추가
		windowGuideCloseButton.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackCloseGuide), forControlEvents: .TouchUpInside);
	}
	
	//////////////////////////
	/// callback inner function
	func innerCallbackAD() {
		switch(openedWindowType) {
			case 0: //그만둠
				// 이 버튼 없음
				break;
			case 1: //재시작
				// 이 버튼 없ㅇ므
				break;
			case 2: //컨티뉴
				
				//유니티광고를 보여준 후, 자동으로 창 닫고 게임을 시작함
				if (gameShowADCallback != nil) {
					gameShowADCallback!();
				}
				
				break;
			case 3: //완전 게임오버
				//완전 게임오버시엔 이 버튼이 비활성화 되어있음
				break;
			default: break;
		}
	}
	func innerCallbackOK() {
		switch(openedWindowType) {
			case 0: //그만둠
				if (gameForceStopCallback != nil) {
					gameForceStopCallback!();
				}
				//var gameOverCallback
				break;
			case 1: //재시작
				if (restartCallback != nil) {
					restartCallback!();
				}
				break;
			case 2: //컨티뉴
				//컨티뉴 시엔 이 버튼이 존재하지 않음.
				break;
			case 3: //완전 게임오버
				//완전 게임오버시엔 이 버튼이 존재하지 않음.
				break;
			default: break;
		}
	}
	func innerCallbackCancel() {
		switch(openedWindowType) {
			case 0: //그만둠
				hideUISelectionWindow();
				break;
			case 1: //재시작
				hideUISelectionWindow();
				break;
			case 2: //컨티뉴
				if (gameShowADCallback != nil) {
					gameShowADCallback!();
				}
				//forceExitGame( true );
				break;
			case 3: //완전 게임오버
				if (gameOverCallback != nil) {
					gameOverCallback!();
				}
				//forceExitGame( true );
				break;
			default: break;
		}
	}
	
	func innerCallbackMenuToggle() {
		if (pauseResumeBtnCallback != nil) {
			pauseResumeBtnCallback!();
		}
	}
	func innerCallbackGuide() {
		showGameGuideUI(); //가이드는 내부호출
	}
	func innerCallbackSoundToggle() {
		if (soundToggleCallback != nil) {
			soundToggleCallback!();
		}
	}
	func innerCallbackRestart() {
		showUISelectionWindow(1); //내부 재시작 확인 호출
	}
	func innerCallbackStopGame() {
		showUISelectionWindow(0); //내부 정지 확인 호출
	}
	
	func innerCallbackCloseGuide() {
		hideGameGuideUI();
	}
	
	////////////////////// Show or hide menu
	func toggleMenu( status:Bool ) {
		//true: pause, show
		//false: resume, hide
		
		if (status) {
			//일시정지 됨
			menuPauseResume.setImage(menuResumeButtonUIImage, forState: .Normal);
		} else {
			//재개됨
			menuPauseResume.setImage(menuPauseButtonUIImage, forState: .Normal);
		}
		
		menuPausedOverlay.hidden = !status;
		menuGameStop.hidden = !status;
		menuGameRestart.hidden = !status;
		menuSoundControl.hidden = !status;
		menuGameGuide.hidden = !status;
		
	}
	
	///////////////////////// window interactions
	//물음을 묻는 메뉴 띄우기
	func showUISelectionWindow( windowTypeNum:Int ) {
		//windowTypeNum으로 게임오버, 컨티뉴, 그만두기, 재시작 구분
		
		windowUIView.hidden = false;
		
		//우선 윈도우를 띄우면 메뉴는 가림
		isMenuVisible = false;
		
		windowTitleContinue.hidden = true; windowTitleGameOver.hidden = true;
		windowTitleRetry.hidden = true; windowTitleExit.hidden = true;
		windowButtonAD.hidden = true; windowButtonOK.hidden = true;
		windowButtonCancel.hidden = true;
		windowButtonAD.alpha = 1;
		
		switch(windowTypeNum) {
			case 0: //그만두고 메뉴로 나가기
				windowTitleExit.hidden = false;
				windowButtonOK.hidden = false; windowButtonCancel.hidden = false;
				break;
			case 1: //재시작
				windowTitleRetry.hidden = false;
				windowButtonOK.hidden = false; windowButtonCancel.hidden = false;
				break;
			case 2: //게임 오버 (재시작 가능)
				windowTitleContinue.hidden = false;
				windowButtonAD.hidden = false; windowButtonCancel.hidden = false;
				break;
			case 3: //완전 게임오버
				windowTitleGameOver.hidden = false;
				windowButtonAD.hidden = false; windowButtonCancel.hidden = false;
				windowButtonAD.alpha = 0.4;
				break;
			default: break;
		}
		openedWindowType = windowTypeNum;
		
		// 열기 애니메이션
		self.windowUIView.alpha = 1;
		self.windowUIView.frame = CGRectMake(
			DeviceManager.scrSize!.width / 2 - self.windowBackgroundImage.frame.width / 2
			, DeviceManager.scrSize!.height
			, self.windowBackgroundImage.frame.width
			, self.windowBackgroundImage.frame.height
		);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.windowUIView.frame = CGRectMake(
				DeviceManager.scrSize!.width / 2 - self.windowBackgroundImage.frame.width / 2
				, DeviceManager.scrSize!.height / 2 - self.windowBackgroundImage.frame.height / 2
				, self.windowBackgroundImage.frame.width
				, self.windowBackgroundImage.frame.height
			);
		}) { _ in
		}
		menuAnimationQueue();
	}
	func hideUISelectionWindow() {
		//윈도우 가림, 다시 메뉴 표시. 뭐였냐에 따라 컴포넌트 표시 등이 달라질듯
		UIView.animateWithDuration(0.2, delay: 0, options: .CurveLinear, animations: {
			self.windowUIView.alpha = 0;
		}) { _ in
			self.windowUIView.hidden = true;
		}
		
		switch(openedWindowType) {
			case -1: //초기화 시 일시정지 버튼만 남김
				isMenuVisible = true;
				menuPauseResume.hidden = false; menuGameStop.hidden = true;
				
				break;
			case 3: //완전 게임오버시 모든 메뉴를 가림
				isMenuVisible = false;
				menuPauseResume.hidden = false; menuGameStop.hidden = false;
				
				break;
			default: //메뉴 다시 표시
				isMenuVisible = true;
				menuPauseResume.hidden = false; menuGameStop.hidden = false;
				break;
		}
		
		menuGameRestart.hidden = menuGameStop.hidden;
		menuSoundControl.hidden = menuGameStop.hidden; menuGameGuide.hidden = menuGameStop.hidden;
		
		menuAnimationQueue();
	}
	
	/////////// 가이드 보기 / 숨기기
	func showGameGuideUI() {
		windowGuideScrollView.hidden = false;
		windowGuideCloseButton.hidden = false;
		windowGuideLeftIndicator.hidden = false; windowGuideRightIndicator.hidden = false;
		
		isMenuVisible = false; //메뉴 감춤
		
		//가이드 스크롤 오프셋을 0으로 초기화
		self.windowGuideScrollView.setContentOffset(CGPointMake(0, 0), animated: false);
		
		// 열기 애니메이션
		windowGuideScrollView.alpha = 1;
		windowGuideCloseButton.alpha = 0; windowGuideLeftIndicator.alpha = 0; windowGuideRightIndicator.alpha = 0;
		windowGuideScrollView.frame = CGRectMake(
			0, selfFrame!.height, selfFrame!.width, 176.5 * DeviceManager.maxScrRatioC
		);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.windowGuideScrollView.frame = CGRectMake(
				0
				, self.selfFrame!.height / 2 - ( 176.5 * DeviceManager.maxScrRatioC ) / 2
				, self.selfFrame!.width
				, 176.5 * DeviceManager.maxScrRatioC
			);
			self.windowGuideCloseButton.alpha = 1;
			self.windowGuideLeftIndicator.alpha = 1; self.windowGuideRightIndicator.alpha = 1;
		}) { _ in
			self.scrollViewDidEndDecelerating(self.windowGuideScrollView);
		}
		
		menuAnimationQueue();
	}
	
	func hideGameGuideUI() {
		if (windowGuideCloseButton.alpha != 1) {
			return;
		}
		isMenuVisible = true; // 메뉴 표시
		
		//가이드 UI가림. 메뉴 표시.
		UIView.animateWithDuration(0.2, delay: 0, options: .CurveLinear, animations: {
			self.windowGuideScrollView.alpha = 0;
			self.windowGuideCloseButton.alpha = 0;
			self.windowGuideLeftIndicator.alpha = 0; self.windowGuideRightIndicator.alpha = 0;
		}) { _ in
			self.windowGuideScrollView.hidden = true;
			self.windowGuideCloseButton.hidden = true;
			self.windowGuideLeftIndicator.hidden = true; self.windowGuideRightIndicator.hidden = true;
		}
		
		menuAnimationQueue();
	}
	
	//가이드 페이지에 따른 왼/오 화살표 알파값 조절
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		let page:Int = Int(scrollView.contentOffset.x / scrollView.frame.width);
		
		if ( page == 0 ) {
			// 왼쪽 화살표 알파값 줄임
			windowGuideLeftIndicator.alpha = 0.4;
		} else {
			//왼쪽 화살표 알파값 1
			windowGuideLeftIndicator.alpha = 1;
		}
		if ( page == windowGuidesLength - 1) {
			//오른쪽 화살표 알파값 줄임
			windowGuideRightIndicator.alpha = 0.4;
		} else {
			// 원상복구
			windowGuideRightIndicator.alpha = 1;
		}
	} //가이드 스크롤뷰 함수 끝
	
	
	///////////// Menu animation
	func menuAnimationQueue() {
		if (prevMenuVis == nil || prevMenuVis != isMenuVisible) {
			prevMenuVis = isMenuVisible;
		} else {
			return;
		}
		
		let startAlpha:CGFloat = isMenuVisible ? 0 : 1;
		let endAlpha:CGFloat = isMenuVisible ? 1 : 0;
		//메뉴 페이드 애니메이션
		menuPauseResume.alpha = startAlpha;
		menuGameStop.alpha = menuPauseResume.alpha; menuGameRestart.alpha = menuPauseResume.alpha;
		menuSoundControl.alpha = menuPauseResume.alpha; menuGameGuide.alpha = menuPauseResume.alpha;
		
		UIView.animateWithDuration(0.6, delay: 0, options: .CurveLinear, animations: {
			self.menuPauseResume.alpha = endAlpha;
			self.menuGameStop.alpha = self.menuPauseResume.alpha; self.menuGameRestart.alpha = self.menuPauseResume.alpha;
			self.menuSoundControl.alpha = self.menuPauseResume.alpha; self.menuGameGuide.alpha = self.menuPauseResume.alpha;
		}) { _ in
			
		}
		
	}
	
}