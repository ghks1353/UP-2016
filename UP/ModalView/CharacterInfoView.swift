//
//  CharacterInfoView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 9..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;
import GameKit;

class CharacterInfoView:UIViewController, GKGameCenterControllerDelegate {
	
	var XAXIS_PRESET_PAD:CGFloat = 6;
	var YAXIS_PRESET_PAD:CGFloat = 13;
	
	//Pop views
	var achievementsView:CharacterAchievementsView = CharacterAchievementsView();
	var themeMainView:CharacterSkinMainView = CharacterSkinMainView();
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
	//Background img
	var charInfoBGView:UIImageView = UIImageView();
	
	///// 화면 에셋
	var charLevelWrapper:UIImageView = UIImageView();
	var charLevelIndicator:UIImageView = UIImageView();
	
	var charExpWrapper:UIImageView = UIImageView(); var charExpMaskView:UIView = UIView(); //Exp 내용물 마스크 처리를 위함
	var charExpProgress:UIView = UIView(); var charExpProgressImageView:UIImageView = UIImageView();
	var charExpProgressAnimationImages:Array<UIImage> = [];
	
	var charGameCenterIcon:UIImageView = UIImageView();
	var charAchievementsIcon:UIImageView = UIImageView();
	
	var charCurrentCharacter:UIImageView = UIImageView();
	
	//레벨 표시를 위한 인디케이터 배열
	var charLevelDigitalArr:Array<UIImageView> = Array<UIImageView>();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor()
		
		//ModalView
		modalView.view.backgroundColor = UIColor.whiteColor();
		modalView.view.frame = DeviceManager.defaultModalSizeRect;
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#232D4B");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("userCharacterInformation");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(CharacterInfoView.viewCloseAction), forControlEvents: .TouchUpInside);
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		///////// Nav items fin
		
		self.view.addSubview(navigationCtrl.view);
		
		//get data from local (stat data)
		DataManager.initDefaults();
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		//SET MASK for dot eff
		let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"));
		modalMaskImageView.frame = modalView.view.frame;
		modalMaskImageView.contentMode = .ScaleAspectFit; self.view.maskView = modalMaskImageView;
		
		//bg이미지 박아야함!
		charInfoBGView.image = UIImage( named: "modal-background-characterinfo.png" );
		charInfoBGView.frame = CGRectMake(0, navigationCtrl.navigationBar.frame.size.height,
		                                  modalView.view.frame.width, modalView.view.frame.height - navigationCtrl.navigationBar.frame.size.height);
		modalView.view.addSubview(charInfoBGView);
		
		//컴포넌트 이미지 설정
		charLevelWrapper.image = UIImage( named: "characterinfo-level-wrapper.png" );
		charLevelIndicator.image = UIImage( named: "characterinfo-level.png" );
		charExpWrapper.image = UIImage( named: "characterinfo-exp-wrapper.png" );
		charGameCenterIcon.image = UIImage( named: "characterinfo-gamecenter.png" );
		charAchievementsIcon.image = UIImage( named: "characterinfo-achievements.png" );
		charCurrentCharacter.image = UIImage( named: SkinManager.getAssetPresetsCharacter() + "character-" + "0001" + ".png" ); //현재 캐릭터 스킨 불러오기
		
		//기타 컴포넌트 배치.
		modalView.view.addSubview(charLevelWrapper);
		modalView.view.addSubview(charLevelIndicator);
		modalView.view.addSubview(charExpWrapper);
		
		modalView.view.addSubview(charCurrentCharacter); //영역이 넓어서 먼저.
		modalView.view.addSubview(charGameCenterIcon);
		modalView.view.addSubview(charAchievementsIcon);
		
		//마스크 레이어 테스트
		charExpMaskView.backgroundColor = UIColor.clearColor();
		modalView.view.addSubview(charExpMaskView);
		
		//Pad는 세로위치에 약간 차이가 있어서 적용함
		//var mRatioC:CGFloat = DeviceManager.modalRatioC;
		if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
			XAXIS_PRESET_PAD = 0;
			YAXIS_PRESET_PAD = 0; //phone는 프리셋 적용 필요 없음
			//mRatioC = 1;
		}
		YAXIS_PRESET_PAD = 0;
		//print("devhei:", heightRatio);
		
		charLevelWrapper.frame = CGRectMake( 194.5 * DeviceManager.modalRatioC,
		                                     charInfoBGView.frame.minY + 12 * DeviceManager.modalRatioC
		                                     , 105.65 * DeviceManager.modalRatioC, 63.65 * DeviceManager.modalRatioC);
		charLevelIndicator.frame = CGRectMake( 142 * DeviceManager.modalRatioC,
		                                        charInfoBGView.frame.minY + 42 * DeviceManager.modalRatioC
		                                       , 43.85 * DeviceManager.modalRatioC, 33.9 * DeviceManager.modalRatioC);
		charExpWrapper.frame = CGRectMake( 26 * DeviceManager.modalRatioC,
		                                   charInfoBGView.frame.minY + 54.5 * DeviceManager.modalRatioC
		                                   ,93.7 * DeviceManager.modalRatioC, 55.8 * DeviceManager.modalRatioC);
		charGameCenterIcon.frame = CGRectMake( 40 * DeviceManager.modalRatioC, modalView.view.frame.height / 2 - 4 * DeviceManager.modalRatioC, 75.8 * DeviceManager.modalRatioC, 75.75 * DeviceManager.modalRatioC);
		charAchievementsIcon.frame = CGRectMake( 200 * DeviceManager.modalRatioC, charGameCenterIcon.frame.minY, 75.8 * DeviceManager.modalRatioC, 75.75 * DeviceManager.modalRatioC);
		charCurrentCharacter.frame = CGRectMake( 6 * DeviceManager.modalRatioC, modalView.view.frame.height - 252 * DeviceManager.modalRatioC, 300 * DeviceManager.modalRatioC, 300 * DeviceManager.modalRatioC );
		
		//마스크용 프레임 배치
		charExpMaskView.frame = CGRectMake(30.5 * DeviceManager.modalRatioC, charExpWrapper.frame.minY + 3 * DeviceManager.modalRatioC,
		                                   82 * DeviceManager.modalRatioC, 48 * DeviceManager.modalRatioC);
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
		
		//charExpProgressImageView.image = UIImage( named: "characterinfo-exp-deco.png" );
		charExpMaskView.addSubview(charExpProgress); charExpMaskView.addSubview(charExpProgressImageView); // 마스크 씌울 것이기 때문에 이 안에다.
		
		//레벨 숫자 배치
		for i:Int in 0 ..< 3 {
			let tmpView:UIImageView = UIImageView();
			tmpView.image = UIImage( named: SkinManager.getDefaultAssetPresets() +  "0" + ".png"  );
			tmpView.frame = CGRectMake( (215 * DeviceManager.modalRatioC) + ((24 * CGFloat(i)) * DeviceManager.maxModalRatioC)
				, charLevelWrapper.frame.minY + 19 * DeviceManager.modalRatioC,
					19.15 * DeviceManager.modalRatioC, 26.80 * DeviceManager.modalRatioC );
			modalView.view.addSubview(tmpView);
			charLevelDigitalArr += [tmpView];
		}
		
		
		//게임 센터 아이콘 터치
		var tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(CharacterInfoView.showGameCenter(_:)))
		charGameCenterIcon.userInteractionEnabled = true; charGameCenterIcon.addGestureRecognizer(tapGestureRecognizer);
		
		//도전과제 터치
		tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(CharacterInfoView.showAchievements(_:)))
		charAchievementsIcon.userInteractionEnabled = true; charAchievementsIcon.addGestureRecognizer(tapGestureRecognizer);
		
		tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(CharacterInfoView.popToCharacterThemeSel(_:)))
		charCurrentCharacter.userInteractionEnabled = true; charCurrentCharacter.addGestureRecognizer(tapGestureRecognizer);
		
		
		//캐릭터 터치 (스킨선택화면으로)
		
		//themeMainView
		FitModalLocationToCenter();
	}
	
	func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
		gameCenterViewController.dismissViewControllerAnimated(true, completion: nil);
	}
	
	//스킨 선택으로 팝
	func popToCharacterThemeSel(gestureRecognizer: UITapGestureRecognizer) {
		navigationCtrl.pushViewController(self.themeMainView, animated: true);
		
	}
	
	//게임센터 창 띄우기
	func showGameCenter(gestureRecognizer: UITapGestureRecognizer) {
		let gcViewController: GKGameCenterViewController = GKGameCenterViewController();
		gcViewController.gameCenterDelegate = self;
		gcViewController.viewState = GKGameCenterViewControllerState.Achievements;
		
		self.showViewController(gcViewController, sender: self);
		self.presentViewController(gcViewController, animated: true, completion: nil);
	}
	
	//도전과제 열기
	func showAchievements(gestureRecognizer: UITapGestureRecognizer) {
		navigationCtrl.pushViewController(self.achievementsView, animated: true);
	}
	
	
	
	/////// View transition animation
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//test
		//CharacterManager.currentCharInfo.characterLevel = 4;
		
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
		                                   (82 * DeviceManager.modalRatioC) * CGFloat(CharacterManager.getExpProgress())
			, 49 * DeviceManager.modalRatioC);
		charExpProgressImageView.frame = CGRectMake(charExpProgress.frame.maxX, 49 * DeviceManager.modalRatioC - 47.5 * DeviceManager.modalRatioC, 47.5 * DeviceManager.modalRatioC, 47.5 * DeviceManager.modalRatioC);
		
		//Tracking by google analytics
		AnalyticsManager.trackScreen(AnalyticsManager.T_SCREEN_CHARACTERINFO);
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
	} ///////////////////////////////
	
	
	////////////////
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect;
		
		if (self.view.maskView != nil) {
			self.view.maskView!.frame = DeviceManager.defaultModalSizeRect;
		}
		
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		ViewController.viewSelf!.showHideBlurview(false);
		self.dismissViewControllerAnimated(true, completion: nil);
	} //end close func
	
	
	func createCellWithNextArrow( name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRectMake(16, 0, self.modalView.view.frame.width, 45);
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45);
		tCell.backgroundColor = UIColor.whiteColor();
		
		tCell.addSubview(tLabel);
		tLabel.text = name;
		
		tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
		tLabel.font = UIFont.systemFontOfSize(16);
		
		return tCell;
	} //end func
	
}