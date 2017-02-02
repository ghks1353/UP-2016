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
	
	//오버레이: UP 구매
	var guideMainBuyUPImage:UIImageView = UIImageView()
	//통계
	var guideMainStatsImage:UIImageView = UIImageView()
	
	//플로팅, 스탠딩 게임칩
	var guideGameFloatingImage:UIImageView = UIImageView()
	var guideGameStandingImage:UIImageView = UIImageView()
	
	//캐릭터
	var guideCharacterImage:UIImageView = UIImageView()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		///// Image setup
		guideMainClockImageView.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-center.png" )
		guideMainBuyUPImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-buy.png" )
		guideMainStatsImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-stats.png" )
		
		guideGameFloatingImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-ground-hover.png" )
		guideGameStandingImage.image = UIImage( named: SkinManager.getDefaultAssetPresets() + "guide-ground.png" )
		
		
		//////add views
		self.view.addSubview(guideMainClockImageView)
		self.view.addSubview(guideMainBuyUPImage)
		self.view.addSubview(guideMainStatsImage)
		
		self.view.addSubview(guideGameFloatingImage)
		self.view.addSubview(guideGameStandingImage)
		
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
		
		
	} //end func override fitframes
	
}
