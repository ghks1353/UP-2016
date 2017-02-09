//
//  CharacterSkinMainView.swift
//  UP
//
//  Created by ExFl on 2016. 7. 25..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;


class CharacterSkinMainView:UIModalPopView {
	
	//클래스 외부접근을 위함
	static var selfView:CharacterSkinMainView?
	
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
		let clockScrX:CGFloat = CGFloat(DeviceManager.defaultModalSizeRect.width / 2 - (CGFloat(202.1 * DeviceManager.modalRatioC) / 2))
		let clockRightScrX:CGFloat = CGFloat(DeviceManager.defaultModalSizeRect.width / 2 + (CGFloat(202.1 * DeviceManager.modalRatioC) / 2))
		let clockScrY:CGFloat = self.navigationController!.navigationBar.frame.size.height +
			CGFloat(skinBackground.frame.height / 2 - (CGFloat(350 * DeviceManager.modalRatioC) / 2))
		
		analogClockHoursImageView.transform = CGAffineTransform.identity; analogClockMinutesImageView.transform = CGAffineTransform.identity;
		analogClockSecondsImageView.transform = CGAffineTransform.identity;
		
		analogClockImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: 202.1 * DeviceManager.modalRatioC, height: 202.1 * DeviceManager.modalRatioC )
		
		
		analogClockHoursImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: analogClockImageView.frame.width, height: analogClockImageView.frame.height )
		analogClockMinutesImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: analogClockImageView.frame.width, height: analogClockImageView.frame.height )
		analogClockSecondsImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: analogClockImageView.frame.width, height: analogClockImageView.frame.height )
		analogClockCenterImageView.frame = CGRect( x: clockScrX, y: clockScrY, width: analogClockImageView.frame.width, height: analogClockImageView.frame.height )
		
		menuSettingsImageView.frame = CGRect( x: clockScrX - ((86 * DeviceManager.modalRatioC) / 2), y: clockScrY + (100 * DeviceManager.modalRatioC) , width: (109.5 * DeviceManager.modalRatioC), height: (109.5 * DeviceManager.modalRatioC) );
		menuListImageView.frame = CGRect( x: clockRightScrX - ((86 * DeviceManager.modalRatioC) / 2), y: menuSettingsImageView.frame.minY, width: (74.05 * DeviceManager.modalRatioC), height: (105.5 * DeviceManager.modalRatioC) );
		
		let groundMinY:CGFloat = self.navigationController!.navigationBar.frame.size.height + skinBackground.frame.height;
		
		groundCharacterImageView.frame =
			CGRect( x: DeviceManager.defaultModalSizeRect.width - (200 * DeviceManager.modalRatioC),
			            y: groundMinY - (254 * DeviceManager.modalRatioC),
			            width: 300 * DeviceManager.modalRatioC,
			            height: 300 * DeviceManager.modalRatioC )
		groundStatisticsImageView.frame =
			CGRect( x: 18 * DeviceManager.modalRatioC,
			            y: groundMinY - (159 * DeviceManager.modalRatioC),
			            width: 102 * DeviceManager.modalRatioC,
			            height: 102 * DeviceManager.modalRatioC )
		groundGamesStandingImageView.frame =
			CGRect( x: groundCharacterImageView.frame.midX - (120 * DeviceManager.modalRatioC),
			            y: groundMinY - (74 * DeviceManager.modalRatioC),
			            width: 72 * DeviceManager.modalRatioC,
			            height: 18 * DeviceManager.modalRatioC )
		groundGamesFloatingImageView.frame =
			CGRect( x: groundGamesStandingImageView.frame.origin.x + (16 * DeviceManager.modalRatioC),
			            y: groundMinY - (130 * DeviceManager.modalRatioC),
			            width: 40 * DeviceManager.modalRatioC,
			            height: 44 * DeviceManager.modalRatioC )
		
		
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
		
	} /////////// end func
	
	func setImagesToCurrentSkin() {
		
		analogClockImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-body.png" )
		
		analogClockHoursImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-hh.png" )
		analogClockMinutesImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-mh.png" )
		analogClockSecondsImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-sh.png" )
		analogClockCenterImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-ch.png" )
		
		//떠있는 버튼
		menuSettingsImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "object-st.png" )
		menuListImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "object-list.png" )
		
		groundStatisticsImageView.image = UIImage( named: SkinManager.getAssetPresetsStatistics() + "stat-object.png" )
		groundGamesStandingImageView.image = UIImage( named: SkinManager.getAssetPresetsPlay() + "standing-box.png" )
		groundGamesFloatingImageView.image = UIImage( named: SkinManager.getAssetPresetsPlay() + "floating-box.png" )
		
		groundCharacterImageView.image = UIImage( named: SkinManager.getAssetPresetsCharacter() + "character-" + "0" + ".png" )
		
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
