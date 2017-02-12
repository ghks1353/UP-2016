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

class CharacterInfoView:UIModalView, GKGameCenterControllerDelegate {
	
	//Pop views
	var achievementsView:CharacterAchievementsView = CharacterAchievementsView()
	var themeMainView:CharacterSkinMainView = CharacterSkinMainView()
	
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
	
	override func viewDidLoad() {
		super.viewDidLoad( LanguagesManager.$("userCharacterInformation"), barColor: UPUtils.colorWithHexString("#232D4B"), showOverlayGuideButton: true )
		
		//get data from local
		DataManager.initDefaults()
		
		//bg이미지 박아야함!
		charInfoBGView.image = UIImage( named: "modal-background-characterinfo.png" )
		charInfoBGView.frame = CGRect(x: 0, y: navigationCtrl.navigationBar.frame.size.height,
		                                  width: modalView.view.frame.width, height: modalView.view.frame.height - navigationCtrl.navigationBar.frame.size.height)
		modalView.view.addSubview(charInfoBGView)
		
		//컴포넌트 이미지 설정
		charLevelWrapper.image = UIImage( named: "characterinfo-level-wrapper.png" )
		charLevelIndicator.image = UIImage( named: "characterinfo-level.png" )
		charExpWrapper.image = UIImage( named: "characterinfo-exp-wrapper.png" )
		charGameCenterIcon.image = UIImage( named: "characterinfo-gamecenter.png" )
		charAchievementsIcon.image = UIImage( named: "characterinfo-achievements.png" )
		charCurrentCharacter.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Character) + ThemeManager.ThemeFileNames.Character + "-0" + ".png" ) //현재 캐릭터 스킨 불러오기
		
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
		                                     , width: 105.65 * DeviceManager.modalRatioC, height: 63.65 * DeviceManager.modalRatioC)
		charLevelIndicator.frame = CGRect( x: 142 * DeviceManager.modalRatioC,
		                                        y: charInfoBGView.frame.minY + 42 * DeviceManager.modalRatioC
		                                       , width: 43.85 * DeviceManager.modalRatioC, height: 33.9 * DeviceManager.modalRatioC)
		charExpWrapper.frame = CGRect( x: 26 * DeviceManager.modalRatioC,
		                                   y: charInfoBGView.frame.minY + 54.5 * DeviceManager.modalRatioC
		                                   ,width: 93.7 * DeviceManager.modalRatioC, height: 55.8 * DeviceManager.modalRatioC)
		
		charGameCenterIcon.frame = CGRect( x: 40 * DeviceManager.modalRatioC, y: navigationCtrl.navigationBar.frame.size.height + 188 * DeviceManager.modalRatioC, width: 75.8 * DeviceManager.modalRatioC, height: 75.75 * DeviceManager.modalRatioC)
		charAchievementsIcon.frame = CGRect( x: 198.5 * DeviceManager.modalRatioC, y: charGameCenterIcon.frame.minY, width: 75.8 * DeviceManager.modalRatioC, height: 75.75 * DeviceManager.modalRatioC)
		
		charCurrentCharacter.frame = CGRect( x: 6 * DeviceManager.modalRatioC, y: modalView.view.frame.height - 252 * DeviceManager.modalRatioC, width: 300 * DeviceManager.modalRatioC, height: 300 * DeviceManager.modalRatioC )
		
		//마스크용 프레임 배치
		charExpMaskView.frame = CGRect(x: 30.5 * DeviceManager.modalRatioC, y: charExpWrapper.frame.minY + 3 * DeviceManager.modalRatioC,
		                                   width: 82 * DeviceManager.modalRatioC, height: 48 * DeviceManager.modalRatioC)
		let maskLayer:CAShapeLayer = CAShapeLayer()
		let cMaskRect = CGRect(x: 0, y: 0, width: 82 * DeviceManager.modalRatioC, height: 49 * DeviceManager.modalRatioC)
		let cPath:CGPath = CGPath(rect: cMaskRect, transform: nil)
		maskLayer.path = cPath
		charExpMaskView.layer.mask = maskLayer
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
		
		charExpMaskView.addSubview(charExpProgress)
		charExpMaskView.addSubview(charExpProgressImageView) // 마스크 씌울 것이기 때문에 이 안에다.
		
		//레벨 숫자 배치
		for i:Int in 0 ..< 3 {
			let tmpView:UIImageView = UIImageView()
			tmpView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) +  "0" + ".png"  )
			tmpView.frame = CGRect( x: (215 * DeviceManager.modalRatioC) + ((24 * CGFloat(i)) * DeviceManager.maxModalRatioC)
				, y: charLevelWrapper.frame.minY + 19 * DeviceManager.modalRatioC,
					width: 19.15 * DeviceManager.modalRatioC, height: 26.80 * DeviceManager.modalRatioC )
			modalView.view.addSubview(tmpView)
			charLevelDigitalArr += [tmpView]
		} //end for [leveling]
		
		//게임 센터 아이콘 터치
		var tGesture = UITapGestureRecognizer(target:self, action: #selector(self.showGameCenter(_:)))
		charGameCenterIcon.isUserInteractionEnabled = true
		charGameCenterIcon.addGestureRecognizer(tGesture)
		
		//도전과제 터치
		tGesture = UITapGestureRecognizer(target:self, action: #selector(self.showAchievements(_:)))
		charAchievementsIcon.isUserInteractionEnabled = true
		charAchievementsIcon.addGestureRecognizer(tGesture)
		
		//캐릭터 (스킨) 터치
		tGesture = UITapGestureRecognizer(target:self, action: #selector(self.popToCharacterThemeSel(_:)))
		charCurrentCharacter.isUserInteractionEnabled = true
		charCurrentCharacter.addGestureRecognizer(tGesture)
		
		upLayerGuide.modalNavHeight = navigationCtrl.navigationBar.frame.size.height
	} //end init func
	//////////////////
	
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
	override func overlayGuideShowHandler(_ gst: UITapGestureRecognizer? ) {
		upLayerGuide.modalPresentationStyle = .overFullScreen
		self.present(upLayerGuide, animated: true, completion: nil)
	} //end func
	
	
	/////// View transition animation
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
		//test
		//CharacterManager.currentCharInfo.characterLevel = 4;
		
		//캐릭터 레벨에 대한 숫자 표시
		let levStr = String(CharacterManager.currentCharInfo.characterLevel);
		charLevelDigitalArr[0].alpha = levStr.characters.count < 3 ? 0.6 : 1;
		charLevelDigitalArr[1].alpha = levStr.characters.count < 2 ? 0.6 : 1;
		//Render text
		charLevelDigitalArr[2].image = UIImage(named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + String(validatingUTF8: levStr[ levStr.characters.count - 1 ])! + ".png" );
		charLevelDigitalArr[1].image =
			levStr.characters.count < 2 ? UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) +  "0" + ".png"  )
			: UIImage(named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + String(validatingUTF8: levStr[ levStr.characters.count - 2 ])! + ".png" )
		charLevelDigitalArr[0].image =
			levStr.characters.count < 3 ? UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) +  "0" + ".png"  )
			: UIImage(named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + String(validatingUTF8: levStr[ levStr.characters.count - 3 ])! + ".png" )
		
		//경험치량 표시
		//CharacterManager.currentCharInfo.characterExp = 4;
		charExpProgress.frame = CGRect( x: (-14 * DeviceManager.modalRatioC), y: 0,
		                                   width: (82 * DeviceManager.modalRatioC) * CGFloat(CharacterManager.getExpProgress())
			, height: 49 * DeviceManager.modalRatioC);
		charExpProgressImageView.frame = CGRect(x: charExpProgress.frame.maxX, y: 49 * DeviceManager.modalRatioC - 47.5 * DeviceManager.modalRatioC, width: 47.5 * DeviceManager.modalRatioC, height: 47.5 * DeviceManager.modalRatioC);
	} //end func
	
	override func viewAppearedCompleteHandler() {
		//캐릭터 오버레이 가이드 표시
		if (DataManager.getSavedDataBool( DataManager.settingsKeys.overlayGuideCharacterInfoFlag ) == false) {
			self.overlayGuideShowHandler( nil )
		} //end if [check character overlay guide flag]
	} ///////////////////////////////
	
	override func FitModalLocationToCenter() {
		super.FitModalLocationToCenter()
		upLayerGuide.fitFrames()
	} //end if (override)
	
	///////////////////////////////////////////////////
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
