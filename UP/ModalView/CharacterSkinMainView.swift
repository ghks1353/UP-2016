//
//  CharacterSkinMainView.swift
//  UP
//
//  Created by ExFl on 2016. 7. 25..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class CharacterSkinMainView:UIModalPopView {
	
	//클래스 외부접근을 위함
	static var selfView:CharacterSkinMainView?
	
	////// 스킨 상세보기 pop view
	var skinSelectView:CharacterThemeSelectView = CharacterThemeSelectView()
	
	//스킨 종류들 이미지.
	var analogClockImageView:UIImageView = UIImageView()
	var analogClockHoursImageView:UIImageView = UIImageView()
	var analogClockMinutesImageView:UIImageView = UIImageView()
	var analogClockSecondsImageView:UIImageView = UIImageView()
	var analogClockCenterImageView:UIImageView = UIImageView()
	
	var menuSettingsImageView:UIImageView = UIImageView()
	var menuListImageView:UIImageView = UIImageView()
	
	var groundStatisticsImageView:UIImageView = UIImageView()
	var groundGamesStandingImageView:UIImageView = UIImageView()
	var groundGamesFloatingImageView:UIImageView = UIImageView()
	var groundCharacterImageView:UIImageView = UIImageView()
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("userTheme") )
		CharacterSkinMainView.selfView = self
		
		//background add
		let skinBackground:UIImageView = UIImageView( image: UIImage( named: "themes-main-background.png" ))
		skinBackground.frame = CGRect( x: 0, y: self.navigationController!.navigationBar.frame.size.height, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height - self.navigationController!.navigationBar.frame.size.height)
		self.view.addSubview(skinBackground) //subview for background
		
		//Set size
		let clockScrX:CGFloat = CGFloat(DeviceManager.defaultModalSizeRect.width / 2 - (CGFloat(252 * DeviceManager.modalRatioC) / 2))
		let clockRightScrX:CGFloat = CGFloat(DeviceManager.defaultModalSizeRect.width / 2 + (CGFloat(252 * DeviceManager.modalRatioC) / 2))
		let clockScrY:CGFloat = self.navigationController!.navigationBar.frame.size.height +
			CGFloat(skinBackground.frame.height / 2 - (CGFloat(392 * DeviceManager.modalRatioC) / 2))
		
		analogClockHoursImageView.transform = CGAffineTransform.identity; analogClockMinutesImageView.transform = CGAffineTransform.identity;
		analogClockSecondsImageView.transform = CGAffineTransform.identity;
		
		analogClockImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: 252 * DeviceManager.modalRatioC, height: 252 * DeviceManager.modalRatioC )
		
		
		analogClockHoursImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: analogClockImageView.frame.width, height: analogClockImageView.frame.height )
		analogClockMinutesImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: analogClockImageView.frame.width, height: analogClockImageView.frame.height )
		analogClockSecondsImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: analogClockImageView.frame.width, height: analogClockImageView.frame.height )
		analogClockCenterImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: analogClockImageView.frame.width, height: analogClockImageView.frame.height )
		
		menuSettingsImageView.frame = CGRect( x: clockScrX - ((140 * DeviceManager.modalRatioC) / 2), y: clockScrY + (70 * DeviceManager.modalRatioC) , width: (220 * DeviceManager.modalRatioC), height: (220 * DeviceManager.modalRatioC) );
		menuListImageView.frame = CGRect( x: clockRightScrX - ((280 * DeviceManager.modalRatioC) / 2), y: menuSettingsImageView.frame.minY, width: (220 * DeviceManager.modalRatioC), height: (220 * DeviceManager.modalRatioC) );
		
		let groundMinY:CGFloat = self.navigationController!.navigationBar.frame.size.height + skinBackground.frame.height;
		
		groundCharacterImageView.frame =
			CGRect( x: DeviceManager.defaultModalSizeRect.width - (200 * DeviceManager.modalRatioC),
			            y: groundMinY - (254 * DeviceManager.modalRatioC),
			            width: 300 * DeviceManager.modalRatioC,
			            height: 300 * DeviceManager.modalRatioC )
		groundStatisticsImageView.frame =
			CGRect( x: -72 * DeviceManager.modalRatioC,
			            y: groundMinY - (258 * DeviceManager.modalRatioC),
			            width: 300 * DeviceManager.modalRatioC,
			            height: 300 * DeviceManager.modalRatioC )
		groundGamesStandingImageView.frame =
			CGRect( x: groundCharacterImageView.frame.midX - (234 * DeviceManager.modalRatioC),
			            y: groundMinY - (216 * DeviceManager.modalRatioC),
			            width: 300 * DeviceManager.modalRatioC,
			            height: 300 * DeviceManager.modalRatioC )
		groundGamesFloatingImageView.frame =
			CGRect( x: groundGamesStandingImageView.frame.minX ,
			            y: groundMinY - (260 * DeviceManager.modalRatioC),
			            width: 300 * DeviceManager.modalRatioC,
			            height: 300 * DeviceManager.modalRatioC )
		
		
		self.view.addSubview(analogClockImageView)
		
		self.view.addSubview(analogClockHoursImageView)
		self.view.addSubview(analogClockMinutesImageView)
		self.view.addSubview(analogClockSecondsImageView)
		self.view.addSubview(analogClockCenterImageView)
		
		self.view.addSubview(menuSettingsImageView)
		self.view.addSubview(menuListImageView)
		
		self.view.addSubview(groundStatisticsImageView)
		self.view.addSubview(groundGamesStandingImageView)
		self.view.addSubview(groundGamesFloatingImageView)
		self.view.addSubview(groundCharacterImageView)
		
		////////// listener add
		//skinSelectView
		var tGesture = UITapGestureRecognizer(target:self, action: #selector(self.selectThemeMain(_:)))
		analogClockCenterImageView.isUserInteractionEnabled = true
		analogClockCenterImageView.addGestureRecognizer(tGesture)
		
		tGesture = UITapGestureRecognizer(target:self, action: #selector(self.selectThemeMain(_:)))
		menuSettingsImageView.isUserInteractionEnabled = true
		menuSettingsImageView.addGestureRecognizer(tGesture)
		
		tGesture = UITapGestureRecognizer(target:self, action: #selector(self.selectThemeMain(_:)))
		menuListImageView.isUserInteractionEnabled = true
		menuListImageView.addGestureRecognizer(tGesture)
		
	} /////////// end func
	
	func selectThemeMain( _ gst:UITapGestureRecognizer ) {
		openThemeSelectView( .Main )
	} //end func
	
	/////////////////////////////
	func openThemeSelectView( _ themeCategory:ThemeManager.ThemeGroup ) {
		skinSelectView.setThemeCategory( themeCategory: themeCategory )
		self.navigationController!.pushViewController(skinSelectView, animated: true)
	} //end func
	
	
	////////////////////////////
	func setImagesToCurrentSkin() {
		
		analogClockImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName( ThemeManager.ThemeFileNames.AnalogClockBody ) )
		
		analogClockHoursImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName( ThemeManager.ThemeFileNames.AnalogClockHour ) )
		analogClockMinutesImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName( ThemeManager.ThemeFileNames.AnalogClockMinute ) )
		analogClockSecondsImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName( ThemeManager.ThemeFileNames.AnalogClockSecond ) )
		analogClockCenterImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName( ThemeManager.ThemeFileNames.AnalogClockCenter ) )
		
		//떠있는 버튼
		menuSettingsImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName( ThemeManager.ThemeFileNames.ObjectSettings ) )
		menuListImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Main) + ThemeManager.getName( ThemeManager.ThemeFileNames.ObjectList ) )
		
		groundStatisticsImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .StatsSign) + ThemeManager.getName( ThemeManager.ThemeFileNames.ObjectStatistics ) )
		groundGamesStandingImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .GameIcon) + ThemeManager.getName( ThemeManager.ThemeFileNames.ObjectGameStanding ) )
		groundGamesFloatingImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .GameIcon) + ThemeManager.getName( ThemeManager.ThemeFileNames.ObjectGameFloating ) )
		
		groundCharacterImageView.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Character) + ThemeManager.ThemeFileNames.Character + "-0" + ".png" )
		
	} /// end func
	
	override func viewWillAppear(_ animated: Bool) {
		setImagesToCurrentSkin()
	}
	
	/////////////////////////////
	override func popToRootAction() {
		ViewController.selfView!.modalCharacterInformationView.fadeInGuideButton( false )
		
		super.popToRootAction()
	} ////end func
} //// end class
