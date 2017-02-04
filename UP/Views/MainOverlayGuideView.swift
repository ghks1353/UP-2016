//
//  MainOverlayGuideView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 3..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class MainOverlayGuideView:UIOverlayGuideView {
	
	//가이드 오버레이: 메인화면
	var guideMainClockImageView:UIImageView = UIImageView()
	var guideMainListLabel:UILabel = UILabel()
	var guideMainClockLabel:UILabel = UILabel()
	var guideMainSettingLabel:UILabel = UILabel()
	
	//오버레이: UP 구매
	var guideMainBuyUPImage:UIImageView = UIImageView()
	var guideMainBuyLabel:UILabel = UILabel()
	//통계
	var guideMainStatsImage:UIImageView = UIImageView()
	var guideMainStatsLabel:UILabel = UILabel()
	
	//플로팅, 스탠딩 게임칩
	var guideGameFloatingImage:UIImageView = UIImageView()
	var guideGameStandingImage:UIImageView = UIImageView()
	var guideGameLabel:UILabel = UILabel()
	
	//캐릭터
	var guideCharacterImage:UIImageView = UIImageView()
	var guideCharacterLabel:UILabel = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		///// Image setup
		guideMainClockImageView.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-center.png" )
		guideMainBuyUPImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-buy.png" )
		guideMainStatsImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-stats.png" )
		
		guideGameFloatingImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-ground-hover.png" )
		guideGameStandingImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-ground.png" )
		
		guideCharacterImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-astro.png" )
		
		///// Label setup
		
		// 리스트라벨
		guideMainListLabel.textAlignment = .right
		guideMainListLabel.textColor = UIColor.white
		guideMainListLabel.font = UIFont.systemFont(ofSize: 18)
		guideMainListLabel.text = LanguagesManager.$("alarmList")
		//시계 설명라벨
		guideMainClockLabel.textAlignment = .left
		guideMainClockLabel.textColor = UIColor.white
		guideMainClockLabel.font = UIFont.systemFont(ofSize: 18)
		guideMainClockLabel.text = LanguagesManager.$("addAlarm")
		//환경설정 설명라벨
		guideMainSettingLabel.textAlignment = .left
		guideMainSettingLabel.textColor = UIColor.white
		guideMainSettingLabel.font = UIFont.systemFont(ofSize: 18)
		guideMainSettingLabel.text = LanguagesManager.$("settingsMenu")
		
		//통계보기 라벨
		guideMainStatsLabel.textAlignment = .left
		guideMainStatsLabel.textColor = UIColor.white
		guideMainStatsLabel.font = UIFont.systemFont(ofSize: 18)
		guideMainStatsLabel.text = LanguagesManager.$("userStatistics")
		
		//게임하기 라벨
		guideGameLabel.textAlignment = .left
		guideGameLabel.textColor = UIColor.white
		guideGameLabel.font = UIFont.systemFont(ofSize: 18)
		guideGameLabel.text = LanguagesManager.$("gamePlay")
		
		//확장팩 구매 설명라벨
		guideMainBuyLabel.textAlignment = .left
		guideMainBuyLabel.textColor = UIColor.white
		guideMainBuyLabel.font = UIFont.systemFont(ofSize: 18)
		guideMainBuyLabel.text = LanguagesManager.$("settingsBuyPremium")
		
		//캐릭터 설명 라벨
		guideCharacterLabel.textAlignment = .right
		guideCharacterLabel.textColor = UIColor.white
		guideCharacterLabel.font = UIFont.systemFont(ofSize: 18)
		guideCharacterLabel.text = LanguagesManager.$("userCharacterInformation")
		
		//////add views
		self.view.addSubview(guideMainClockImageView)
		self.view.addSubview(guideMainBuyUPImage)
		self.view.addSubview(guideMainStatsImage)
		
		self.view.addSubview(guideGameFloatingImage)
		self.view.addSubview(guideGameStandingImage)
		
		self.view.addSubview(guideCharacterImage)
		
		////// add label views
		self.view.addSubview(guideMainListLabel)
		self.view.addSubview(guideMainClockLabel)
		self.view.addSubview(guideMainSettingLabel)
		
		self.view.addSubview(guideMainStatsLabel)
		self.view.addSubview(guideGameLabel)
		
		self.view.addSubview(guideCharacterLabel)
		
		self.view.addSubview(guideMainBuyLabel)
	} //end func
	
	override func fitFrames() {
		super.fitFrames()
		
		let clockScrX:CGFloat = CGFloat(DeviceManager.scrSize!.width / 2 - ((240 * DeviceManager.maxScrRatioC) / 2))
		let clockScrY:CGFloat = CGFloat(DeviceManager.scrSize!.height / 2 - ((240 * DeviceManager.maxScrRatioC) / 2))
		
		guideMainClockImageView.frame = CGRect(
			x: clockScrX - 75 * DeviceManager.maxScrRatioC,
			y: clockScrY - 44 * DeviceManager.maxScrRatioC,
			width: 380.15 * DeviceManager.maxScrRatioC,
			height: 335.75 * DeviceManager.maxScrRatioC
		)
		
		guideMainBuyUPImage.frame = CGRect(
			x: 18 * DeviceManager.maxScrRatioC,
			y: 34 * DeviceManager.maxScrRatioC,
			width: 85.3 * DeviceManager.maxScrRatioC,
			height: 50.5 * DeviceManager.maxScrRatioC)
		guideMainStatsImage.frame = CGRect(
			x: 48 * DeviceManager.maxScrRatioC,
			y: DeviceManager.scrSize!.height - ((86 + 86) * DeviceManager.maxScrRatioC),
			width: 102 * DeviceManager.maxScrRatioC,
			height: 127.25 * DeviceManager.maxScrRatioC
		)
		
		guideCharacterImage.frame = CGRect(
			x: DeviceManager.scrSize!.width - (109 * DeviceManager.maxScrRatioC),
			y: DeviceManager.scrSize!.height - ((86 + 120) * DeviceManager.maxScrRatioC),
			width: 61.95 * DeviceManager.maxScrRatioC,
			height: 137.05 * DeviceManager.maxScrRatioC
		)
		
		//guideGameFloatingImage는 메인 뷰에서 업데이트
		guideGameStandingImage.frame = CGRect(
			x: DeviceManager.scrSize!.width - (200 * DeviceManager.maxScrRatioC),
			y: DeviceManager.scrSize!.height - ((86 + 2) * DeviceManager.maxScrRatioC),
			width: 80 * DeviceManager.maxScrRatioC,
			height: 47.65 * DeviceManager.maxScrRatioC
		)
		
		
		//// Label update //////////////////////
		//알람 시계 라벨
		guideMainClockLabel.frame = CGRect(
			x: guideMainClockImageView.frame.minX + (40 * DeviceManager.maxScrRatioC),
			y: guideMainClockImageView.frame.minY - (34 * DeviceManager.maxScrRatioC),
			width: 240 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		//알람 리스트 라벨
		guideMainListLabel.frame = CGRect(
			x: guideMainClockImageView.frame.maxX - ((18 + 240) * DeviceManager.maxScrRatioC),
			y: guideMainClockImageView.frame.minY - (31 * DeviceManager.maxScrRatioC),
			width: 240 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		//환경설정 라벨
		guideMainSettingLabel.frame = CGRect(
			x: guideMainClockImageView.frame.minX + (149 * DeviceManager.maxScrRatioC),
			y: guideMainClockImageView.frame.maxY - (18 * DeviceManager.maxScrRatioC),
			width: 240 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
		//통계 라벨
		guideMainStatsLabel.frame = CGRect(
			x: guideMainStatsImage.frame.minX - (12 * DeviceManager.maxScrRatioC),
			y: guideMainStatsImage.frame.maxY + (4 * DeviceManager.maxScrRatioC),
			width: 240 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		//게임하기 라벨
		guideGameLabel.frame = CGRect(
			x: guideGameStandingImage.frame.minX - (18 * DeviceManager.maxScrRatioC),
			y: guideGameStandingImage.frame.maxY + (4 * DeviceManager.maxScrRatioC),
			width: 240 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
		//캐릭터 정보 라벨
		guideCharacterLabel.frame = CGRect(
			x: guideCharacterImage.frame.minX - ((240 - 36) * DeviceManager.maxScrRatioC),
			y: guideCharacterImage.frame.minY - (30 * DeviceManager.maxScrRatioC),
			width: 240 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
		//UP 확장팩 구매 라벨
		guideMainBuyLabel.frame = CGRect(
			x: guideMainBuyUPImage.frame.maxX + (9 * DeviceManager.maxScrRatioC),
			y: guideMainBuyUPImage.frame.midY - (22 * DeviceManager.maxScrRatioC),
			width: 240 * DeviceManager.maxScrRatioC, height: 28 * DeviceManager.maxScrRatioC
		)
		
	} //end func override fitframes
	
}
