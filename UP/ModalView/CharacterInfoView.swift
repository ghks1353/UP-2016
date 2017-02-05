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
	
	//Pop views
	var achievementsView:CharacterAchievementsView = CharacterAchievementsView()
	var themeMainView:CharacterSkinMainView = CharacterSkinMainView()
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController()
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController()
	
	//Background img
	var charInfoBGView:UIImageView = UIImageView()
	
	///// 화면 에셋
	var charLevelWrapper:UIImageView = UIImageView()
	var charLevelIndicator:UIImageView = UIImageView()
	
	var charExpWrapper:UIImageView = UIImageView(); var charExpMaskView:UIView = UIView(); //Exp 내용물 마스크 처리를 위함
	var charExpProgress:UIView = UIView(); var charExpProgressImageView:UIImageView = UIImageView();
	var charExpProgressAnimationImages:Array<UIImage> = []
	
	var charGameCenterIcon:UIImageView = UIImageView()
	var charAchievementsIcon:UIImageView = UIImageView()
	
	var charCurrentCharacter:UIImageView = UIImageView()
	
	//레벨 표시를 위한 인디케이터 배열
	var charLevelDigitalArr:Array<UIImageView> = Array<UIImageView>()
	
	//화면 레이어 가이드
	var upLayerGuide:CharacterOverlayGuideView = CharacterOverlayGuideView()
	//레이어가이드 보이기 버튼
	var upLayerGuideShowButton:UIImageView = UIImageView()
	
	
	//Mask view
	var maskUIView:UIView = UIView()
	let modalMaskImageView:UIImageView = UIImageView(image: UIImage(named: "modal-mask.png"))
	let upLayerGuideMaskView:UIImageView = UIImageView()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.clear
		
		//ModalView
		modalView.view.backgroundColor = UIColor.white
		modalView.view.frame = DeviceManager.defaultModalSizeRect
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
		navigationCtrl = UINavigationController.init(rootViewController: modalView)
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#232D4B")
		navigationCtrl.view.frame = modalView.view.frame
		modalView.title = LanguagesManager.$("userCharacterInformation")
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
		navLeftPadding.width = -12 //Button left padding
		let navCloseButton:UIButton = UIButton() //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-close"), for: UIControlState())
		navCloseButton.frame = CGRect(x: 0, y: 0, width: 45, height: 45) //Image frame size
		navCloseButton.addTarget(self, action: #selector(CharacterInfoView.viewCloseAction), for: .touchUpInside)
		modalView.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ]
		///////// Nav items fin
		
		self.view.addSubview(navigationCtrl.view)
		
		//get data from local (stat data)
		DataManager.initDefaults()
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false
		
		////////// 모달 밖에 배치하는 리소스
		upLayerGuideShowButton.image = UIImage( named: "comp-showguide-icon.png" )
		self.view.addSubview(upLayerGuideShowButton)
		
		//SET MASK for dot eff
		modalMaskImageView.frame = modalView.view.frame
		modalMaskImageView.contentMode = .scaleAspectFit
		
		upLayerGuideMaskView.image = UIImage( named: "comp-showguide-icon.png" )
		
		maskUIView.addSubview(modalMaskImageView)
		maskUIView.addSubview(upLayerGuideMaskView)
		
		self.view.mask = maskUIView
		/////////////////////
		
		//bg이미지 박아야함!
		charInfoBGView.image = UIImage( named: "modal-background-characterinfo.png" )
		charInfoBGView.frame = CGRect(x: 0, y: navigationCtrl.navigationBar.frame.size.height,
		                                  width: modalView.view.frame.width, height: modalView.view.frame.height - navigationCtrl.navigationBar.frame.size.height)
		modalView.view.addSubview(charInfoBGView)
		
		//컴포넌트 이미지 설정
		charLevelWrapper.image = UIImage( named: "characterinfo-level-wrapper.png" );
		charLevelIndicator.image = UIImage( named: "characterinfo-level.png" );
		charExpWrapper.image = UIImage( named: "characterinfo-exp-wrapper.png" );
		charGameCenterIcon.image = UIImage( named: "characterinfo-gamecenter.png" );
		charAchievementsIcon.image = UIImage( named: "characterinfo-achievements.png" );
		charCurrentCharacter.image = UIImage( named: SkinManager.getAssetPresetsCharacter() + "character-" + "0" + ".png" ); //현재 캐릭터 스킨 불러오기
		
		//기타 컴포넌트 배치.
		modalView.view.addSubview(charLevelWrapper)
		modalView.view.addSubview(charLevelIndicator)
		modalView.view.addSubview(charExpWrapper)
		
		modalView.view.addSubview(charCurrentCharacter) //영역이 넓어서 먼저.
		modalView.view.addSubview(charGameCenterIcon)
		modalView.view.addSubview(charAchievementsIcon)
		
		//마스크 레이어 테스트
		charExpMaskView.backgroundColor = UIColor.clear
		modalView.view.addSubview(charExpMaskView)
		
		charLevelWrapper.frame = CGRect( x: 194.5 * DeviceManager.modalRatioC,
		                                     y: charInfoBGView.frame.minY + 12 * DeviceManager.modalRatioC
		                                     , width: 105.65 * DeviceManager.modalRatioC, height: 63.65 * DeviceManager.modalRatioC);
		charLevelIndicator.frame = CGRect( x: 142 * DeviceManager.modalRatioC,
		                                        y: charInfoBGView.frame.minY + 42 * DeviceManager.modalRatioC
		                                       , width: 43.85 * DeviceManager.modalRatioC, height: 33.9 * DeviceManager.modalRatioC);
		charExpWrapper.frame = CGRect( x: 26 * DeviceManager.modalRatioC,
		                                   y: charInfoBGView.frame.minY + 54.5 * DeviceManager.modalRatioC
		                                   ,width: 93.7 * DeviceManager.modalRatioC, height: 55.8 * DeviceManager.modalRatioC);
		
		charGameCenterIcon.frame = CGRect( x: 40 * DeviceManager.modalRatioC, y: navigationCtrl.navigationBar.frame.size.height + 188 * DeviceManager.modalRatioC, width: 75.8 * DeviceManager.modalRatioC, height: 75.75 * DeviceManager.modalRatioC);
		charAchievementsIcon.frame = CGRect( x: 198.5 * DeviceManager.modalRatioC, y: charGameCenterIcon.frame.minY, width: 75.8 * DeviceManager.modalRatioC, height: 75.75 * DeviceManager.modalRatioC);
		
		charCurrentCharacter.frame = CGRect( x: 6 * DeviceManager.modalRatioC, y: modalView.view.frame.height - 252 * DeviceManager.modalRatioC, width: 300 * DeviceManager.modalRatioC, height: 300 * DeviceManager.modalRatioC );
		
		//마스크용 프레임 배치
		charExpMaskView.frame = CGRect(x: 30.5 * DeviceManager.modalRatioC, y: charExpWrapper.frame.minY + 3 * DeviceManager.modalRatioC,
		                                   width: 82 * DeviceManager.modalRatioC, height: 48 * DeviceManager.modalRatioC);
		let maskLayer:CAShapeLayer = CAShapeLayer();
		let cMaskRect = CGRect(x: 0, y: 0, width: 82 * DeviceManager.modalRatioC, height: 49 * DeviceManager.modalRatioC);
		let cPath:CGPath = CGPath(rect: cMaskRect, transform: nil);
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
		charExpProgressImageView.startAnimating()
		
		//charExpProgressImageView.image = UIImage( named: "characterinfo-exp-deco.png" );
		charExpMaskView.addSubview(charExpProgress)
		charExpMaskView.addSubview(charExpProgressImageView) // 마스크 씌울 것이기 때문에 이 안에다.
		
		//레벨 숫자 배치
		for i:Int in 0 ..< 3 {
			let tmpView:UIImageView = UIImageView()
			tmpView.image = UIImage( named: SkinManager.getDefaultAssetPresets() +  "0" + ".png"  )
			tmpView.frame = CGRect( x: (215 * DeviceManager.modalRatioC) + ((24 * CGFloat(i)) * DeviceManager.maxModalRatioC)
				, y: charLevelWrapper.frame.minY + 19 * DeviceManager.modalRatioC,
					width: 19.15 * DeviceManager.modalRatioC, height: 26.80 * DeviceManager.modalRatioC )
			modalView.view.addSubview(tmpView)
			charLevelDigitalArr += [tmpView]
		}
		
		
		//게임 센터 아이콘 터치
		var tGesture = UITapGestureRecognizer(target:self, action: #selector(CharacterInfoView.showGameCenter(_:)))
		charGameCenterIcon.isUserInteractionEnabled = true
		charGameCenterIcon.addGestureRecognizer(tGesture)
		
		//도전과제 터치
		tGesture = UITapGestureRecognizer(target:self, action: #selector(CharacterInfoView.showAchievements(_:)))
		charAchievementsIcon.isUserInteractionEnabled = true
		charAchievementsIcon.addGestureRecognizer(tGesture)
		
		//캐릭터 (스킨) 터치
		tGesture = UITapGestureRecognizer(target:self, action: #selector(CharacterInfoView.popToCharacterThemeSel(_:)))
		charCurrentCharacter.isUserInteractionEnabled = true
		charCurrentCharacter.addGestureRecognizer(tGesture)
		
		//오버레이 도움말 터치.
		tGesture = UITapGestureRecognizer(target:self, action: #selector(CharacterInfoView.showOverlayGuide(_:)))
		upLayerGuideShowButton.isUserInteractionEnabled = true
		upLayerGuideShowButton.addGestureRecognizer(tGesture)
		
		upLayerGuide.modalNavHeight = navigationCtrl.navigationBar.frame.size.height
		FitModalLocationToCenter()
	}
	
	func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
		gameCenterViewController.dismiss(animated: true, completion: nil)
	}
	
	//스킨 선택으로 팝
	func popToCharacterThemeSel(_ gst: UITapGestureRecognizer) {
		fadeOutGuideButton()
		navigationCtrl.pushViewController(self.themeMainView, animated: true)
	} //end func
	
	//게임센터 창 띄우기
	func showGameCenter(_ gst: UITapGestureRecognizer) {
		print("ShowGameCenter called");
		/*
		print("Gamecenter window presenting");
		
		let gcViewController: GKGameCenterViewController = GKGameCenterViewController();
		gcViewController.gameCenterDelegate = self;
		gcViewController.viewState = GKGameCenterViewControllerState.achievements;
		
		self.show(gcViewController, sender: self);
		self.present(gcViewController, animated: true, completion: nil);
		*/
	}
	
			
	//도전과제 열기
	func showAchievements(_ gst: UITapGestureRecognizer) {
		fadeOutGuideButton()
		navigationCtrl.pushViewController(self.achievementsView, animated: true)
	}
	
	//오버레이 가이드 열기
	func showOverlayGuide(_ gst: UITapGestureRecognizer? ) {
		upLayerGuide.modalPresentationStyle = .overFullScreen
		self.present(upLayerGuide, animated: true, completion: nil)
	} //end func
	
	
	/////// View transition animation
	override func viewWillAppear(_ animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
		
		//test
		//CharacterManager.currentCharInfo.characterLevel = 4;
		
		//캐릭터 레벨에 대한 숫자 표시
		let levStr = String(CharacterManager.currentCharInfo.characterLevel);
		charLevelDigitalArr[0].alpha = levStr.characters.count < 3 ? 0.6 : 1;
		charLevelDigitalArr[1].alpha = levStr.characters.count < 2 ? 0.6 : 1;
		//Render text
		charLevelDigitalArr[2].image = UIImage(named: SkinManager.getDefaultAssetPresets() + String(validatingUTF8: levStr[ levStr.characters.count - 1 ])! + ".png" );
		charLevelDigitalArr[1].image =
			levStr.characters.count < 2 ? UIImage( named: SkinManager.getDefaultAssetPresets() +  "0" + ".png"  )
			: UIImage(named: SkinManager.getDefaultAssetPresets() + String(validatingUTF8: levStr[ levStr.characters.count - 2 ])! + ".png" )
		charLevelDigitalArr[0].image =
			levStr.characters.count < 3 ? UIImage( named: SkinManager.getDefaultAssetPresets() +  "0" + ".png"  )
			: UIImage(named: SkinManager.getDefaultAssetPresets() + String(validatingUTF8: levStr[ levStr.characters.count - 3 ])! + ".png" )
		
		//경험치량 표시
		//CharacterManager.currentCharInfo.characterExp = 4;
		charExpProgress.frame = CGRect( x: (-14 * DeviceManager.modalRatioC), y: 0,
		                                   width: (82 * DeviceManager.modalRatioC) * CGFloat(CharacterManager.getExpProgress())
			, height: 49 * DeviceManager.modalRatioC);
		charExpProgressImageView.frame = CGRect(x: charExpProgress.frame.maxX, y: 49 * DeviceManager.modalRatioC - 47.5 * DeviceManager.modalRatioC, width: 47.5 * DeviceManager.modalRatioC, height: 47.5 * DeviceManager.modalRatioC);
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
		                             width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
		UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
			self.view.frame = CGRect(x: 0, y: 0,
				width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
			self.view.alpha = 1
		}) { _ in
			//캐릭터 오버레이 가이드 표시
			if (DataManager.getSavedDataBool( DataManager.settingsKeys.overlayGuideCharacterInfoFlag ) == false) {
				self.showOverlayGuide( nil )
			} //end if [check character overlay guide flag]
			
		} //end block [complete animation]
		fadeInGuideButton()
	} ///////////////////////////////
	
	//function으로 분리
	func fadeInGuideButton( _ withDelay:Bool = true ) {
		upLayerGuideShowButton.alpha = 0
		UIView.animate(withDuration: 0.5, delay: withDelay ? 0.56 : 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.upLayerGuideShowButton.alpha = 1
		}, completion: {_ in
		})
	} //end func
	func fadeOutGuideButton( ) {
		upLayerGuideShowButton.alpha = 1
		UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
			self.upLayerGuideShowButton.alpha = 0
		}, completion: {_ in
		})
	} //end func
	
	////////////////
	
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame = DeviceManager.defaultModalSizeRect
		if (self.view.mask != nil) {
			modalMaskImageView.frame = DeviceManager.defaultModalSizeRect
			upLayerGuideMaskView.frame = CGRect( x: DeviceManager.scrSize!.width - ((50.5 + 18) * DeviceManager.maxScrRatioC), y: 34 * DeviceManager.maxScrRatioC, width: 50.5 * DeviceManager.maxScrRatioC, height: 50.5 * DeviceManager.maxScrRatioC)
		}
		
		// 모달 밖 리소스 프레임 맞춤
		upLayerGuideShowButton.frame = upLayerGuideMaskView.frame
		upLayerGuide.fitFrames()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		self.upLayerGuideShowButton.alpha = 0
		
		(self.presentingViewController as! ViewController).showHideBlurview(false)
		self.dismiss(animated: true, completion: nil)
	} //end close func
	
	
	func createCellWithNextArrow( _ name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRect(x: 16, y: 0, width: self.modalView.view.frame.width, height: 45)
		tCell.frame = CGRect(x: 0, y: 0, width: self.modalView.view.frame.width, height: 45)
		tCell.backgroundColor = UIColor.white
		
		tCell.addSubview(tLabel)
		tLabel.text = name
		
		tCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
		tLabel.font = UIFont.systemFont(ofSize: 16)
		
		return tCell
	} //end func
	
}
