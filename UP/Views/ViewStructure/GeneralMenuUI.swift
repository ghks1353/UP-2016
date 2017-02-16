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
	var pauseResumeBtnCallback:(() -> Void)? = nil
	var soundToggleCallback:(() -> Void)? = nil
	var restartCallback:(() -> Void)? = nil
	
	var gameForceStopCallback:(() -> Void)? = nil
	var gameOverCallback:(() -> Void)? = nil
	var gameShowADCallback:(() -> Void)? = nil
	
	//////////////// vals
	var isMenuVisible:Bool = true //알파 효과를 위함
	var prevMenuVis:Bool? = nil
	
	////////////////////////////////////////////////////////////////////
	/////////////////////////////// UI /////////////////////////////////
	var selfFrame:CGRect?
	
	//일시정지 버튼 및 메뉴들
	var menuPauseButtonUIImage:UIImage = UIImage(named: "game-general-menu-pause.png")!
	var menuResumeButtonUIImage:UIImage = UIImage(named: "game-general-menu-play.png")!
	
	var menuPausedOverlay:UIView = UIView()
	var menuPauseResume:UIButton = UIButton() //일시정지, 계속하기는 한 버튼으로 우려먹고 이미지만 바꾸기.
	var menuGameStop:UIButton = UIButton()
	var menuGameRestart:UIButton = UIButton()
	var menuSoundControl:UIButton = UIButton()
	var menuGameGuide:UIButton = UIButton()
	
	//Window 메뉴들
	var windowUIView:UIView = UIView()
	var windowBackgroundImage:UIImageView = UIImageView()
	var windowTitleContinue:UIImageView = UIImageView()
	var windowTitleGameOver:UIImageView = UIImageView()
	var windowTitleRetry:UIImageView = UIImageView()
	var windowTitleExit:UIImageView = UIImageView()
	var windowButtonAD:UIButton = UIButton()
	var windowButtonOK:UIButton = UIButton()
	var windowButtonCancel:UIButton = UIButton()
	
	//가이드 뷰
	var windowGuideCloseButton:UIButton = UIButton()
	
	var windowGuideScrollView:UIScrollView = UIScrollView()
	var windowGuidesUIViewArray:Array<UIView> = Array<UIView>()
	var windowGuidesUIViewImages:Array<UIImageView> = Array<UIImageView>()
	
	//좌우 인디케이터. 있나 없나 확인용?
	var windowGuideLeftIndicator:UIImageView = UIImageView()
	var windowGuideRightIndicator:UIImageView = UIImageView()
	
	var windowGuidesLength:Int = 0 //가이드 개수
	var windowGuidesNamePreset:String = "" //가이드 파일명 프리셋
	
	var openedWindowType:Int = -1 //열린 윈도우의 종류. 버튼 분기때문에 만듬
	
	var selectedGameID:Int = 0
	
	func setGame( _ gameID:Int ) {
		switch(gameID) {
			case 0: //jumpup
				windowGuidesNamePreset = "game-jumpup-assets-guide-"
				windowGuidesLength = 4
				break;
			default: break;
		}
	}
	
	func initUI( _ frame:CGRect ) { //frame -> screen size
		selfFrame = frame
		
		//버튼 이미지 설정
		menuPauseResume.setImage(menuPauseButtonUIImage, for: UIControlState())
		menuGameStop.setImage(UIImage(named: "game-general-menu-list.png"), for: UIControlState())
		menuGameRestart.setImage(UIImage(named: "game-general-menu-retry.png"), for: UIControlState())
		menuSoundControl.setImage(UIImage(named: "game-general-menu-soundon.png"), for: UIControlState())
		menuGameGuide.setImage(UIImage(named: "game-general-menu-info.png"), for: UIControlState())
		
		menuPauseResume.frame = CGRect( x: 24, y: selfFrame!.height - 24 - (61.6 * DeviceManager.maxScrRatioC), width: 61.6 * DeviceManager.maxScrRatioC, height: 61.6 * DeviceManager.maxScrRatioC )
		
		menuGameGuide.frame = CGRect( x: menuPauseResume.frame.minX, y: menuPauseResume.frame.minY - 12 - menuPauseResume.frame.width, width: menuPauseResume.frame.width, height: menuPauseResume.frame.height )
		menuSoundControl.frame = CGRect( x: menuPauseResume.frame.minX, y: menuGameGuide.frame.minY - 12 - menuPauseResume.frame.width, width: menuPauseResume.frame.width, height: menuPauseResume.frame.height )
		menuGameRestart.frame = CGRect( x: menuPauseResume.frame.minX, y: menuSoundControl.frame.minY - 12 - menuPauseResume.frame.width, width: menuPauseResume.frame.width, height: menuPauseResume.frame.height )
		menuGameStop.frame = CGRect( x: menuPauseResume.frame.minX, y: menuGameRestart.frame.minY - 12 - menuPauseResume.frame.width, width: menuPauseResume.frame.width, height: menuPauseResume.frame.height )
		
		//오버레이 생성
		menuPausedOverlay.frame = CGRect(x: 0, y: 0, width: selfFrame!.width, height: selfFrame!.height)
		menuPausedOverlay.backgroundColor = UIColor.black
		menuPausedOverlay.alpha = 0.65
		
		self.addSubview(menuPausedOverlay); menuPausedOverlay.isHidden = true;
		self.addSubview(menuPauseResume);
		self.addSubview(menuGameStop); menuGameStop.isHidden = true;
		self.addSubview(menuGameRestart); menuGameRestart.isHidden = true;
		self.addSubview(menuSoundControl); menuSoundControl.isHidden = true;
		self.addSubview(menuGameGuide); menuGameGuide.isHidden = true;
		
		//버튼 이벤트 생성
		menuPauseResume.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackMenuToggle), for: .touchUpInside);
		menuGameGuide.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackGuide), for: .touchUpInside);
		menuSoundControl.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackSoundToggle), for: .touchUpInside);
		menuGameRestart.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackRestart), for: .touchUpInside);
		menuGameStop.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackStopGame), for: .touchUpInside);
		
		//// 윈도우 구성. 크기는 패드에서 안 커지게
		windowBackgroundImage.frame = CGRect( x: 0, y: 0, width: 257.75 * DeviceManager.maxScrRatioC, height: 176.5 * DeviceManager.maxScrRatioC );
		windowBackgroundImage.image = UIImage( named: "game-general-window-mask.png" );
		
		windowTitleContinue.frame = CGRect(
			x: windowBackgroundImage.frame.width / 2 - (203.9 * DeviceManager.maxScrRatioC) / 2
			, y: 24 * DeviceManager.maxScrRatioC, width: 203.9 * DeviceManager.maxScrRatioC, height: 26.95 * DeviceManager.maxScrRatioC );
		windowTitleGameOver.frame = CGRect(
			x: windowBackgroundImage.frame.width / 2 - (198.6 * DeviceManager.maxScrRatioC) / 2
			, y: windowTitleContinue.frame.minY, width: 198.6 * DeviceManager.maxScrRatioC, height: 28.35 * DeviceManager.maxScrRatioC );
		windowTitleRetry.frame = CGRect(
			x: windowBackgroundImage.frame.width / 2 - (134.65 * DeviceManager.maxScrRatioC) / 2
			, y: windowTitleContinue.frame.minY, width: 134.65 * DeviceManager.maxScrRatioC, height: 26.95 * DeviceManager.maxScrRatioC );
		windowTitleExit.frame = CGRect(
			x: windowBackgroundImage.frame.width / 2 - (110.95 * DeviceManager.maxScrRatioC) / 2
			, y: windowTitleContinue.frame.minY, width: 110.95 * DeviceManager.maxScrRatioC, height: 26.95 * DeviceManager.maxScrRatioC );
		
		windowTitleContinue.image = UIImage( named: "game-general-window-continue.png" );
		windowTitleGameOver.image = UIImage( named: "game-general-window-gameover.png" );
		windowTitleRetry.image = UIImage( named: "game-general-window-retry.png" );
		windowTitleExit.image = UIImage( named: "game-general-window-exit.png" );
		
		///  이쪽은 버튼
		windowButtonAD.frame = CGRect(
			x: 28 * DeviceManager.maxScrRatioC
			, y: windowTitleContinue.frame.maxY + 32 * DeviceManager.maxScrRatioC, width: 89.8 * DeviceManager.maxScrRatioC, height: 65.5 * DeviceManager.maxScrRatioC );
		windowButtonOK.frame = CGRect(
			x: windowButtonAD.frame.minX
			, y: windowButtonAD.frame.minY, width: windowButtonAD.frame.width, height: windowButtonAD.frame.height );
		windowButtonCancel.frame = CGRect(
			x: windowBackgroundImage.frame.width - windowButtonAD.frame.width - windowButtonAD.frame.minX
			, y: windowButtonAD.frame.minY, width: windowButtonAD.frame.width, height: windowButtonAD.frame.height );
		
		windowButtonAD.setImage(UIImage( named: "game-general-window-btn-ads.png" ), for: UIControlState());
		windowButtonOK.setImage(UIImage( named: "game-general-window-btn-ok.png" ), for: UIControlState());
		windowButtonCancel.setImage(UIImage( named: "game-general-window-btn-cancel.png" ), for: UIControlState());
		
		//배경 사진부터 깔고
		windowUIView.addSubview(windowBackgroundImage)
		windowUIView.addSubview(windowTitleContinue)
		windowUIView.addSubview(windowTitleGameOver)
		windowUIView.addSubview(windowTitleRetry)
		windowUIView.addSubview(windowTitleExit)
		windowUIView.addSubview(windowButtonAD)
		windowUIView.addSubview(windowButtonOK)
		windowUIView.addSubview(windowButtonCancel)
		
		//폼 설정
		windowUIView.frame = CGRect(
			x: selfFrame!.width / 2 - windowBackgroundImage.frame.width / 2
			, y: selfFrame!.height / 2 - windowBackgroundImage.frame.height / 2
			, width: windowBackgroundImage.frame.width
			, height: windowBackgroundImage.frame.height
		);
		
		self.addSubview(windowUIView)
		
		//버튼 리스너 설정
		windowButtonAD.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackAD), for: .touchUpInside);
		windowButtonOK.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackOK), for: .touchUpInside);
		windowButtonCancel.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackCancel), for: .touchUpInside);
		
		hideUISelectionWindow()
		
		////// 가이드 폼 만들기
		windowGuideScrollView.frame = CGRect(
			x: 0
			, y: selfFrame!.height / 2 - ( 176.5 * DeviceManager.maxScrRatioC ) / 2
			, width: selfFrame!.width
			, height: 176.5 * DeviceManager.maxScrRatioC
		);
		windowGuideScrollView.contentSize = CGSize(
			/* 24 24 lr margin -> content 4x */
			width: selfFrame!.width * CGFloat(windowGuidesLength)
			, height: ( 176.5 * DeviceManager.maxScrRatioC )
		);
		for i:Int in 0 ..< windowGuidesLength {
			//loop for content sizes
			let tmpUIView:UIView = UIView(frame:
				CGRect( x: (windowGuideScrollView.contentSize.width / CGFloat(windowGuidesLength) ) * CGFloat(i)
					, y: 0, width: (windowGuideScrollView.contentSize.width / CGFloat(windowGuidesLength) )
					, height: windowGuideScrollView.contentSize.height
				));
			let tmpGuideImg:UIImageView = UIImageView( image: UIImage( named: windowGuidesNamePreset + String(i) + ".png" ) );
			tmpGuideImg.frame = CGRect( x: (selfFrame!.width - (257.75 * DeviceManager.maxScrRatioC)) / 2 //Margin
				, y: 0, width: 257.75 * DeviceManager.maxScrRatioC
				, height: windowGuideScrollView.contentSize.height
			);
			tmpUIView.addSubview(tmpGuideImg);
			windowGuideScrollView.addSubview(tmpUIView);
			
			windowGuidesUIViewArray += [tmpUIView];
			windowGuidesUIViewImages += [tmpGuideImg];
		}
		
		//가이드 슬라이더 추가
		self.addSubview(windowGuideScrollView);
		windowGuideScrollView.isPagingEnabled = true;
		
		//가이드 버튼 추가
		windowGuideCloseButton.frame = CGRect(
			x: selfFrame!.width / 2 - menuPauseResume.frame.width / 2,
			y: windowGuideScrollView.frame.maxY + 100 * DeviceManager.scrRatioC,
			/* same with 61.6 x 61.6 */
			width: menuPauseResume.frame.width, height: menuPauseResume.frame.height
		)
		windowGuideCloseButton.setImage( UIImage( named: "game-general-window-btn-close.png" ) , for: UIControlState());
		self.addSubview(windowGuideCloseButton);
		
		//기본 가이드 상태: 가림
		windowGuideScrollView.isHidden = true;
		windowGuideCloseButton.isHidden = true;
		
		windowGuideScrollView.delegate = self;
		
		//가이드 화살표 추가
		windowGuideLeftIndicator.image = UIImage( named: "game-general-guide-left.png" );
		windowGuideRightIndicator.image = UIImage( named: "game-general-guide-right.png" );
		
		var guideLeftCGPoint:CGPoint = CGPoint();
		var guideRightCGPoint:CGPoint = CGPoint();
		
		guideLeftCGPoint.x = selfFrame!.width / 2 - ((257.75 * DeviceManager.maxScrRatioC) / 2) - (18 * DeviceManager.maxScrRatioC);
		guideLeftCGPoint.x = guideLeftCGPoint.x - (20.4 * DeviceManager.maxScrRatioC);
		guideLeftCGPoint.y = selfFrame!.height / 2 - ((40.8 * DeviceManager.maxScrRatioC) / 2);
		windowGuideLeftIndicator.frame = CGRect(
			x: guideLeftCGPoint.x
			, y: guideLeftCGPoint.y,
			  width: 20.4 * DeviceManager.maxScrRatioC
			, height: 40.8 * DeviceManager.maxScrRatioC
		);
		
		guideRightCGPoint.x = selfFrame!.width / 2 + ((257.75 * DeviceManager.maxScrRatioC) / 2) + (18 * DeviceManager.maxScrRatioC);
		guideRightCGPoint.y = windowGuideLeftIndicator.frame.minY;
		windowGuideRightIndicator.frame = CGRect(
			x: guideRightCGPoint.x
			, y: guideRightCGPoint.y
			, width: windowGuideLeftIndicator.frame.width
			, height: windowGuideLeftIndicator.frame.height
		);
		self.addSubview(windowGuideLeftIndicator); self.addSubview(windowGuideRightIndicator);
		windowGuideLeftIndicator.isHidden = true; windowGuideRightIndicator.isHidden = true;
		
		//가이드 터치 리스너 추가
		windowGuideCloseButton.addTarget(self, action: #selector(GeneralMenuUI.innerCallbackCloseGuide), for: .touchUpInside);
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
					gameShowADCallback!()
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
					gameForceStopCallback!()
				}
				//var gameOverCallback
				break;
			case 1: //재시작
				if (restartCallback != nil) {
					restartCallback!()
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
				hideUISelectionWindow()
				break;
			case 1: //재시작
				hideUISelectionWindow()
				break;
			case 2: //컨티뉴de kyanseru osita bai
				if (gameOverCallback != nil) {
					gameOverCallback!()
				}
				//forceExitGame( true );
				break;
			case 3: //완전 게임오버
				if (gameOverCallback != nil) {
					gameOverCallback!()
				}
				//forceExitGame( true );
				break;
			default: break;
		}
	}
	
	func innerCallbackMenuToggle() {
		if (pauseResumeBtnCallback != nil) {
			pauseResumeBtnCallback!()
		}
	}
	func innerCallbackGuide() {
		showGameGuideUI() //가이드는 내부호출
	}
	func innerCallbackSoundToggle() {
		if (soundToggleCallback != nil) {
			soundToggleCallback!()
		}
	}
	func innerCallbackRestart() {
		showUISelectionWindow(1) //내부 재시작 확인 호출
	}
	func innerCallbackStopGame() {
		showUISelectionWindow(0) //내부 정지 확인 호출
	}
	
	func innerCallbackCloseGuide() {
		hideGameGuideUI()
	}
	
	////////////////////// Show or hide menu
	func toggleMenu( _ status:Bool ) {
		//true: pause, show
		//false: resume, hide
		
		if (status) {
			//일시정지 됨
			menuPauseResume.setImage(menuResumeButtonUIImage, for: UIControlState())
		} else {
			//재개됨
			menuPauseResume.setImage(menuPauseButtonUIImage, for: UIControlState())
		}
		
		menuPausedOverlay.isHidden = !status
		menuGameStop.isHidden = !status
		menuGameRestart.isHidden = !status
		menuSoundControl.isHidden = !status
		menuGameGuide.isHidden = !status
		
	}
	
	///////////////////////// window interactions
	//물음을 묻는 메뉴 띄우기
	func showUISelectionWindow( _ windowTypeNum:Int ) {
		//windowTypeNum으로 게임오버, 컨티뉴, 그만두기, 재시작 구분
		
		windowUIView.isHidden = false
		
		//우선 윈도우를 띄우면 메뉴는 가림
		isMenuVisible = false
		
		windowTitleContinue.isHidden = true; windowTitleGameOver.isHidden = true;
		windowTitleRetry.isHidden = true; windowTitleExit.isHidden = true;
		windowButtonAD.isHidden = true; windowButtonOK.isHidden = true;
		windowButtonCancel.isHidden = true;
		windowButtonAD.alpha = 1;
		
		switch(windowTypeNum) {
			case 0: //그만두고 메뉴로 나가기
				windowTitleExit.isHidden = false;
				windowButtonOK.isHidden = false; windowButtonCancel.isHidden = false;
				break;
			case 1: //재시작
				windowTitleRetry.isHidden = false;
				windowButtonOK.isHidden = false; windowButtonCancel.isHidden = false;
				break;
			case 2: //게임 오버 (재시작 가능)
				windowTitleContinue.isHidden = false;
				windowButtonAD.isHidden = false; windowButtonCancel.isHidden = false;
				break;
			case 3: //완전 게임오버
				windowTitleGameOver.isHidden = false;
				windowButtonAD.isHidden = false; windowButtonCancel.isHidden = false;
				windowButtonAD.alpha = 0.4;
				break;
			default: break;
		}
		openedWindowType = windowTypeNum;
		
		// 열기 애니메이션
		self.windowUIView.alpha = 1;
		self.windowUIView.frame = CGRect(
			x: selfFrame!.width / 2 - self.windowBackgroundImage.frame.width / 2
			, y: selfFrame!.height
			, width: self.windowBackgroundImage.frame.width
			, height: self.windowBackgroundImage.frame.height
		);
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
			self.windowUIView.frame = CGRect(
				x: self.selfFrame!.width / 2 - self.windowBackgroundImage.frame.width / 2
				, y: self.selfFrame!.height / 2 - self.windowBackgroundImage.frame.height / 2
				, width: self.windowBackgroundImage.frame.width
				, height: self.windowBackgroundImage.frame.height
			);
		}) { _ in
		}
		menuAnimationQueue();
	}
	func hideUISelectionWindow() {
		//윈도우 가림, 다시 메뉴 표시. 뭐였냐에 따라 컴포넌트 표시 등이 달라질듯
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
			self.windowUIView.alpha = 0;
		}) { _ in
			self.windowUIView.isHidden = true;
		}
		
		switch(openedWindowType) {
			case -1: //초기화 시 일시정지 버튼만 남김
				isMenuVisible = true;
				menuPauseResume.isHidden = false; menuGameStop.isHidden = true;
				
				break;
			case 3: //완전 게임오버시 모든 메뉴를 가림
				isMenuVisible = false;
				menuPauseResume.isHidden = false; menuGameStop.isHidden = false;
				
				break;
			default: //메뉴 다시 표시
				isMenuVisible = true;
				menuPauseResume.isHidden = false; menuGameStop.isHidden = false;
				break;
		}
		
		menuGameRestart.isHidden = menuGameStop.isHidden
		menuSoundControl.isHidden = menuGameStop.isHidden
		menuGameGuide.isHidden = menuGameStop.isHidden
		
		menuAnimationQueue()
	}
	
	/////////// 가이드 보기 / 숨기기
	func showGameGuideUI() {
		windowGuideScrollView.isHidden = false;
		windowGuideCloseButton.isHidden = false;
		windowGuideLeftIndicator.isHidden = false; windowGuideRightIndicator.isHidden = false;
		
		isMenuVisible = false; //메뉴 감춤
		
		//가이드 스크롤 오프셋을 0으로 초기화
		self.windowGuideScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false);
		
		// 열기 애니메이션
		windowGuideScrollView.alpha = 1;
		windowGuideCloseButton.alpha = 0; windowGuideLeftIndicator.alpha = 0; windowGuideRightIndicator.alpha = 0;
		windowGuideScrollView.frame = CGRect(
			x: 0, y: selfFrame!.height, width: selfFrame!.width, height: 176.5 * DeviceManager.maxScrRatioC
		);
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
			self.windowGuideScrollView.frame = CGRect(
				x: 0
				, y: self.selfFrame!.height / 2 - ( 176.5 * DeviceManager.maxScrRatioC ) / 2
				, width: self.selfFrame!.width
				, height: 176.5 * DeviceManager.maxScrRatioC
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
		UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
			self.windowGuideScrollView.alpha = 0;
			self.windowGuideCloseButton.alpha = 0;
			self.windowGuideLeftIndicator.alpha = 0; self.windowGuideRightIndicator.alpha = 0;
		}) { _ in
			self.windowGuideScrollView.isHidden = true;
			self.windowGuideCloseButton.isHidden = true;
			self.windowGuideLeftIndicator.isHidden = true; self.windowGuideRightIndicator.isHidden = true;
		}
		
		menuAnimationQueue();
	}
	
	//가이드 페이지에 따른 왼/오 화살표 알파값 조절
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
		
		UIView.animate(withDuration: 0.6, delay: 0, options: .curveLinear, animations: {
			self.menuPauseResume.alpha = endAlpha;
			self.menuGameStop.alpha = self.menuPauseResume.alpha; self.menuGameRestart.alpha = self.menuPauseResume.alpha;
			self.menuSoundControl.alpha = self.menuPauseResume.alpha; self.menuGameGuide.alpha = self.menuPauseResume.alpha;
		}) { _ in
			
		}
		
	}
	
}
