//
//  CharacterOverlayGuideView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 5..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class CharacterOverlayGuideView:UIOverlayGuideView {
	
	//Nav height
	var modalNavHeight:CGFloat = 0
	
	//가이드 오버레이: 게임센터
	var guideGameCenterImage:UIImageView = UIImageView()
	var guideGameCenterLabel:UILabel = UILabel()
	//도전과제
	var guideAchievementsImage:UIImageView = UIImageView()
	var guideAchievementsLabel:UILabel = UILabel()
	
	//경험치
	var guideEXPImage:UIImageView = UIImageView()
	var guideEXPLabel:UILabel = UILabel()
	
	//레벨
	var guideLevelImage:UIImageView = UIImageView()
	var guideLevelLabel:UILabel = UILabel()
	
	//캐릭터
	var guideCharacterImage:UIImageView = UIImageView()
	var guideCharacterLabel:UILabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		///// Image setup
		guideGameCenterImage.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main, themeID: ThemeManager.legacyDefaultTheme) + "guide-characters-gamecenter.png" )
		guideAchievementsImage.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main, themeID: ThemeManager.legacyDefaultTheme) + "guide-characters-achevements.png" )
		
		guideEXPImage.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main, themeID: ThemeManager.legacyDefaultTheme) + "guide-characters-exp.png" )
		guideLevelImage.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main, themeID: ThemeManager.legacyDefaultTheme) + "guide-characters-level.png" )
		
		guideCharacterImage.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main, themeID: ThemeManager.legacyDefaultTheme) + "guide-characters-astro.png" )
		
		///// Label setup
		
		// 게임센터라벨
		guideGameCenterLabel.textAlignment = .center
		guideGameCenterLabel.textColor = UIColor.white
		guideGameCenterLabel.font = UIFont.systemFont(ofSize: 18)
		guideGameCenterLabel.text = LanguagesManager.$("gameiOSGameCenter")
		//도전과제라벨
		guideAchievementsLabel.textAlignment = .center
		guideAchievementsLabel.textColor = UIColor.white
		guideAchievementsLabel.font = UIFont.systemFont(ofSize: 18)
		guideAchievementsLabel.text = LanguagesManager.$("achievements")
		
		//경험치라벨
		guideEXPLabel.textAlignment = .left
		guideEXPLabel.textColor = UIColor.white
		guideEXPLabel.font = UIFont.systemFont(ofSize: 18)
		guideEXPLabel.text = LanguagesManager.$("characterEXP")
		//레벨라벨
		guideLevelLabel.textAlignment = .right
		guideLevelLabel.textColor = UIColor.white
		guideLevelLabel.font = UIFont.systemFont(ofSize: 18)
		guideLevelLabel.text = LanguagesManager.$("characterLevel")
		
		//캐릭터 라벨
		guideCharacterLabel.textAlignment = .left
		guideCharacterLabel.textColor = UIColor.white
		guideCharacterLabel.font = UIFont.systemFont(ofSize: 18)
		guideCharacterLabel.text = LanguagesManager.$("userTheme")
		
		//////add views
		self.view.addSubview(guideGameCenterImage)
		self.view.addSubview(guideAchievementsImage)
		
		self.view.addSubview(guideEXPImage)
		self.view.addSubview(guideLevelImage)
		
		self.view.addSubview(guideCharacterImage)
		
		////// add label views
		self.view.addSubview(guideGameCenterLabel)
		self.view.addSubview(guideAchievementsLabel)
		
		self.view.addSubview(guideEXPLabel)
		self.view.addSubview(guideLevelLabel)
		
		self.view.addSubview(guideCharacterLabel)
	} //end func
	
	override func fitFrames() {
		super.fitFrames()
		
		var xAxisPreset:CGFloat = 0
		var yAxisPreset:CGFloat = 0
		
		if (UIDevice.current.userInterfaceIdiom == .pad) {
			xAxisPreset = 3
			yAxisPreset = 3
		}
		
		guideGameCenterImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.minX + 40 * DeviceManager.maxScrRatioC,
			y: DeviceManager.defaultModalSizeRect.minY + modalNavHeight + (189 + yAxisPreset) * DeviceManager.maxScrRatioC,
			width: 77.8 * DeviceManager.maxScrRatioC,
			height: 113.75 * DeviceManager.maxScrRatioC
		)
		guideAchievementsImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.maxX - (40 + 77.8) * DeviceManager.maxScrRatioC,
			y: guideGameCenterImage.frame.minY,
			width: 77.8 * DeviceManager.maxScrRatioC,
			height: 113.75 * DeviceManager.maxScrRatioC
		)
		
		guideEXPImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.minX + 26 * DeviceManager.maxScrRatioC,
			y: DeviceManager.defaultModalSizeRect.minY + modalNavHeight + 54 * DeviceManager.maxScrRatioC,
			width: 95.7 * DeviceManager.maxScrRatioC,
			height: 83.55 * DeviceManager.maxScrRatioC
		)
		guideLevelImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.maxX - (13 + 107.65) * DeviceManager.maxScrRatioC,
			y: DeviceManager.defaultModalSizeRect.minY + modalNavHeight + 12 * DeviceManager.maxScrRatioC,
			width: 107.65 * DeviceManager.maxScrRatioC,
			height: 101.6 * DeviceManager.maxScrRatioC
		)
		guideCharacterImage.frame = CGRect(
			x: DeviceManager.defaultModalSizeRect.minX + (113 + xAxisPreset) * DeviceManager.maxScrRatioC,
			y: DeviceManager.defaultModalSizeRect.maxY - (36 + 125.45) * DeviceManager.maxScrRatioC,
			width: 65.8 * DeviceManager.maxScrRatioC,
			height: 125.45 * DeviceManager.maxScrRatioC
		)
		
		/////////////////
		// labels
		
		guideGameCenterLabel.frame = CGRect(
			x: guideGameCenterImage.frame.minX - (100 * DeviceManager.maxScrRatioC),
			y: guideGameCenterImage.frame.maxY + (2 * DeviceManager.maxScrRatioC),
			width: 200 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		guideAchievementsLabel.frame = CGRect(
			x: guideAchievementsImage.frame.maxX - (72 * DeviceManager.maxScrRatioC),
			y: guideAchievementsImage.frame.maxY + (2 * DeviceManager.maxScrRatioC),
			width: 150 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
		guideEXPLabel.frame = CGRect(
			x: guideEXPImage.frame.minX - (8 * DeviceManager.maxScrRatioC),
			y: guideEXPImage.frame.maxY + (2 * DeviceManager.maxScrRatioC),
			width: 200 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		guideLevelLabel.frame = CGRect(
			x: guideLevelImage.frame.maxX - ((12 + 200) * DeviceManager.maxScrRatioC),
			y: guideLevelImage.frame.maxY + (2 * DeviceManager.maxScrRatioC),
			width: 200 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
		guideCharacterLabel.frame = CGRect(
			x: guideCharacterImage.frame.minX - (32 * DeviceManager.maxScrRatioC),
			y: guideCharacterImage.frame.maxY + (2 * DeviceManager.maxScrRatioC),
			width: 200 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
		
	} //end func override fitframes
	
	override func closeGuideView(_ gst: UITapGestureRecognizer) {
		super.closeGuideView(gst)
		
		//창 닫을 때 캐릭터 오버레이 가이드 보았음을 저장
		DataManager.setDataBool( true, key: DataManager.settingsKeys.overlayGuideCharacterInfoFlag )
		
	} //end func
	
}
