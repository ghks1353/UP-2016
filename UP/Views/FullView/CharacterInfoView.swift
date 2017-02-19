//
//  CharacterInfoView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 9..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit
import GameKit

class CharacterInfoView:UIViewController {
	
	///// 화면 에셋
	var cLevelWrapper:UIImageView = UIImageView()
	var cLevelIndicator:UIImageView = UIImageView()
	
	var cExpWrapper:UIImageView = UIImageView()
	var cExpMaskView:UIView = UIView() //Exp 내용물 마스크 처리를 위함
	var cExpProgress:UIView = UIView()
	var cExpProgressImageView:UIImageView = UIImageView()
	
	var cExpProgressAnimationImages:[UIImage] = []
	
	//////// 위쪽 백그라운드
	var cTopBackgroundView:UIImageView = UIImageView()
	
	/////////////// Button background
	var cButtonBackgroundGeneral:UIImage = UIImage( named: "characterinfo-button-background.png" )!
	
	var cBottomButtonsWrapper:UIView = UIView()
	
	var cAchievementBackgroundView:UIImageView = UIImageView()
	var cThemeBackgroundView:UIImageView = UIImageView()
	
	var cAchievement:UIImageView = UIImageView()
	var cTheme:UIImageView = UIImageView()
	var cClose:UIImageView = UIImageView()
	
	var labelAchievement:UILabel = UILabel()
	var labelClose:UILabel = UILabel()
	var labelTheme:UILabel = UILabel()
	
	
	var cCharacter:UIImageView = UIImageView()
	
	//레벨 표시를 위한 인디케이터 배열
	var charLevelDigitalArr:[UIImageView] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//Button images
		cAchievementBackgroundView.image = cButtonBackgroundGeneral
		cThemeBackgroundView.image = cButtonBackgroundGeneral
		
		cAchievement.image = UIImage( named: "characterinfo-button-achievements.png" )
		cClose.image = UIImage( named: "characterinfo-button-close.png" )
		
		let buttonMargin:CGFloat = 48 * DeviceManager.maxScrRatioC
		cAchievementBackgroundView.frame = CGRect( x: 0, y: 0, width: 76 * DeviceManager.maxScrRatioC, height: 76 * DeviceManager.maxScrRatioC )
		cClose.frame = CGRect( x: cAchievementBackgroundView.frame.maxX + buttonMargin, y: 0, width: cAchievementBackgroundView.frame.width, height: cAchievementBackgroundView.frame.height )
		cThemeBackgroundView.frame = CGRect( x: cClose.frame.maxX + buttonMargin, y: 0, width: cAchievementBackgroundView.frame.width, height: cAchievementBackgroundView.frame.height )
		
		
		cBottomButtonsWrapper.addSubview(cAchievementBackgroundView)
		cBottomButtonsWrapper.addSubview(cClose)
		cBottomButtonsWrapper.addSubview(cThemeBackgroundView)
		
		/////////// 버튼 위에 이미지 넣음.
		cAchievement.frame = cAchievementBackgroundView.frame
		cTheme.frame = cThemeBackgroundView.frame
		
		cBottomButtonsWrapper.addSubview(cAchievement)
		cBottomButtonsWrapper.addSubview(cTheme)
		
		labelAchievement.frame = CGRect(x: cAchievementBackgroundView.frame.minX + -10 * DeviceManager.maxScrRatioC, y: cAchievementBackgroundView.frame.maxY + 6 * DeviceManager.maxScrRatioC, width: 96 * DeviceManager.maxScrRatioC, height: 24)
		labelAchievement.font = UIFont.systemFont(ofSize: 14)
		labelAchievement.textColor = UIColor.white
		labelAchievement.textAlignment = .center
		labelAchievement.text = LanguagesManager.$("achievements")
		
		labelClose.frame = CGRect(x: cClose.frame.minX + -10 * DeviceManager.maxScrRatioC, y: labelAchievement.frame.minY, width: labelAchievement.frame.width, height: labelAchievement.frame.height)
		labelClose.font = UIFont.systemFont(ofSize: 14)
		labelClose.textColor = UIColor.white
		labelClose.textAlignment = .center
		labelClose.text = LanguagesManager.$("generalClose")
		
		labelTheme.frame = CGRect(x: cThemeBackgroundView.frame.minX + -10 * DeviceManager.maxScrRatioC, y: labelAchievement.frame.minY, width: labelAchievement.frame.width, height: labelAchievement.frame.height)
		labelTheme.font = UIFont.systemFont(ofSize: 14)
		labelTheme.textColor = UIColor.white
		labelTheme.textAlignment = .center
		labelTheme.text = LanguagesManager.$("userTheme")
		
		/// Add labels to wrapper
		cBottomButtonsWrapper.addSubview(labelAchievement)
		cBottomButtonsWrapper.addSubview(labelClose)
		cBottomButtonsWrapper.addSubview(labelTheme)
		
		self.view.addSubview(cBottomButtonsWrapper)
		///////////////
		
		//// draw top background
		cTopBackgroundView.image = UIImage( named: "characterinfo-background.png" )
		cTopBackgroundView.frame = CGRect( x: DeviceManager.scrSize!.width / 2 - (414 * DeviceManager.maxScrRatioC) / 2, y: 0, width: 414 * DeviceManager.maxScrRatioC, height: 226.8 * DeviceManager.maxScrRatioC )
		self.view.addSubview(cTopBackgroundView)
		
		/////////////// Draw battery, level and indicator
		cLevelWrapper.image = UIImage( named: "characterinfo-level-wrapper.png" )
		cLevelIndicator.image = UIImage( named: "characterinfo-level.png" )
		cExpWrapper.image = UIImage( named: "characterinfo-exp-wrapper.png" )
		
		/// Mask for Exp
		cExpMaskView.backgroundColor = UIColor.clear
		
		cLevelWrapper.frame = CGRect( x: cTopBackgroundView.frame.maxX - 38 * DeviceManager.maxScrRatioC - 105.65 * DeviceManager.maxScrRatioC,
		                                 y: 21 * DeviceManager.maxScrRatioC
			, width: 105.65 * DeviceManager.maxScrRatioC, height: 63.65 * DeviceManager.maxScrRatioC)
		cLevelIndicator.frame = CGRect( x: cLevelWrapper.frame.minX - 27 * DeviceManager.maxScrRatioC - 43.85 * DeviceManager.maxScrRatioC,
		                                   y: 54 * DeviceManager.maxScrRatioC
			, width: 43.85 * DeviceManager.maxScrRatioC, height: 33.9 * DeviceManager.maxScrRatioC)
		cExpWrapper.frame = CGRect( x: cTopBackgroundView.frame.minX + 48 * DeviceManager.maxScrRatioC,
		                               y: 75 * DeviceManager.maxScrRatioC
			,width: 93.7 * DeviceManager.maxScrRatioC, height: 55.8 * DeviceManager.maxScrRatioC)
		
		self.view.addSubview(cLevelWrapper)
		self.view.addSubview(cLevelIndicator)
		self.view.addSubview(cExpWrapper)
		
		/*
		
		
		
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
		
		upLayerGuide.modalNavHeight = navigationCtrl.navigationBar.frame.size.height*/
	} //end init func
	//////////////////
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
		//get data from local
		DataManager.initDefaults()
		
		fitFrames()
		//현재 Select된 테마 이미지로 변경
		updateThemeButtonImage()
		
	} //end func
	
	/////////////// Fit frames to center
	func fitFrames() {
		
		let wrapperWidth:CGFloat = cThemeBackgroundView.frame.maxX - cAchievementBackgroundView.frame.minX
		cBottomButtonsWrapper.frame = CGRect( x: DeviceManager.scrSize!.width / 2 - wrapperWidth / 2, y: DeviceManager.scrSize!.height - labelAchievement.frame.maxY - 64 * DeviceManager.maxScrRatioC, width: wrapperWidth, height: labelAchievement.frame.maxY )
		
	} //end func
	
	func updateThemeButtonImage() {
		//현재 설정중인 미리보기로 변경.
		cTheme.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Default) + ThemeManager.ThemeFileNames.Thumbnails )
	} //end func
	
	/*
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
	*/
}
