//
//  CharacterSkinMainView.swift
//  UP
//
//  Created by ExFl on 2016. 7. 25..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;


class CharacterSkinMainView:UIViewController {
	
	//클래스 외부접근을 위함
	static var selfView:CharacterSkinMainView?;
	
	//스킨 종류들 이미지.
	var analogClockImageView:UIImageView = UIImageView();
	var analogClockHoursImageView:UIImageView = UIImageView();
	var analogClockMinutesImageView:UIImageView = UIImageView();
	var analogClockSecondsImageView:UIImageView = UIImageView();
	var analogClockCenterImageView:UIImageView = UIImageView();
	
	var menuSettingsImageView:UIImageView = UIImageView();
	var menuListImageView:UIImageView = UIImageView();
	
	var groundStatisticsImageView:UIImageView = UIImageView();
	var groundGamesStandingImageView:UIImageView = UIImageView();
	var groundGamesFloatingImageView:UIImageView = UIImageView();
	var groundCharacterImageView:UIImageView = UIImageView();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		CharacterSkinMainView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("userTheme");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(CharacterSkinMainView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		//background add
		let skinBackground:UIImageView = UIImageView( image: UIImage( named: "themes-main-background.png" ));
		skinBackground.frame = CGRectMake( 0, self.navigationController!.navigationBar.frame.size.height, DeviceManager.defaultModalSizeRect.width, DeviceManager.defaultModalSizeRect.height - self.navigationController!.navigationBar.frame.size.height);
		
		self.view.addSubview(skinBackground); //subview for background
		
		
		//Set size
		let clockScrX:CGFloat = CGFloat(DeviceManager.defaultModalSizeRect.width / 2 - (CGFloat(202.1 * DeviceManager.modalRatioC) / 2));
		let clockRightScrX:CGFloat = CGFloat(DeviceManager.defaultModalSizeRect.width / 2 + (CGFloat(202.1 * DeviceManager.modalRatioC) / 2));
		let clockScrY:CGFloat = self.navigationController!.navigationBar.frame.size.height +
			CGFloat(skinBackground.frame.height / 2 - (CGFloat(350 * DeviceManager.modalRatioC) / 2));
		//let clockScrY:CGFloat = CGFloat(skinBackground.frame.height / 2 - 110);
		
		//clockScrY += 10 * DeviceManager.modalRatioC;
		
		analogClockHoursImageView.transform = CGAffineTransformIdentity; analogClockMinutesImageView.transform = CGAffineTransformIdentity;
		analogClockSecondsImageView.transform = CGAffineTransformIdentity;
		
		analogClockImageView.frame = CGRectMake( clockScrX, clockScrY, 202.1 * DeviceManager.modalRatioC, 202.1 * DeviceManager.modalRatioC );
		
		
		analogClockHoursImageView.frame = CGRectMake( clockScrX, clockScrY, analogClockImageView.frame.width, analogClockImageView.frame.height );
		analogClockMinutesImageView.frame = CGRectMake( clockScrX, clockScrY, analogClockImageView.frame.width, analogClockImageView.frame.height );
		analogClockSecondsImageView.frame = CGRectMake( clockScrX, clockScrY, analogClockImageView.frame.width, analogClockImageView.frame.height );
		analogClockCenterImageView.frame = CGRectMake( clockScrX, clockScrY, analogClockImageView.frame.width, analogClockImageView.frame.height );
		
		menuSettingsImageView.frame = CGRectMake( clockScrX - ((86 * DeviceManager.modalRatioC) / 2), clockScrY + (100 * DeviceManager.modalRatioC) , (109.5 * DeviceManager.modalRatioC), (109.5 * DeviceManager.modalRatioC) );
		menuListImageView.frame = CGRectMake( clockRightScrX - ((86 * DeviceManager.modalRatioC) / 2), menuSettingsImageView.frame.minY, (74.05 * DeviceManager.modalRatioC), (105.5 * DeviceManager.modalRatioC) );
		
		let groundMinY:CGFloat = self.navigationController!.navigationBar.frame.size.height + skinBackground.frame.height; // - 13; // * DeviceManager.modalRatioC;
		
		groundCharacterImageView.frame =
			CGRectMake( DeviceManager.defaultModalSizeRect.width - (200 * DeviceManager.modalRatioC),
			            groundMinY - (254 * DeviceManager.modalRatioC),
			            300 * DeviceManager.modalRatioC,
			            300 * DeviceManager.modalRatioC );
		groundStatisticsImageView.frame =
			CGRectMake( 18 * DeviceManager.modalRatioC,
			            groundMinY - (159 * DeviceManager.modalRatioC),
			            102 * DeviceManager.modalRatioC,
			            102 * DeviceManager.modalRatioC );
		groundGamesStandingImageView.frame =
			CGRectMake( groundCharacterImageView.frame.midX - (120 * DeviceManager.modalRatioC),
			            groundMinY - (74 * DeviceManager.modalRatioC),
			            72 * DeviceManager.modalRatioC,
			            18 * DeviceManager.modalRatioC );
		groundGamesFloatingImageView.frame =
			CGRectMake( groundGamesStandingImageView.frame.origin.x + (16 * DeviceManager.modalRatioC),
			            groundMinY - (130 * DeviceManager.modalRatioC),
			            40 * DeviceManager.modalRatioC,
			            44 * DeviceManager.modalRatioC );
		
		
		self.view.addSubview(analogClockImageView);
		
		self.view.addSubview(analogClockHoursImageView);
		self.view.addSubview(analogClockMinutesImageView);
		self.view.addSubview(analogClockSecondsImageView);
		self.view.addSubview(analogClockCenterImageView);
		
		self.view.addSubview(menuSettingsImageView);
		self.view.addSubview(menuListImageView);
		
		self.view.addSubview(groundStatisticsImageView);
		self.view.addSubview(groundGamesStandingImageView);
		self.view.addSubview(groundGamesFloatingImageView);
		self.view.addSubview(groundCharacterImageView);
		
		
	}
	
	func setImagesToCurrentSkin() {
		
		analogClockImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-body.png" );
		
		analogClockHoursImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-hh.png" );
		analogClockMinutesImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-mh.png" );
		analogClockSecondsImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-sh.png" );
		analogClockCenterImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "time-ch.png" );
		
		//떠있는 버튼
		menuSettingsImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "object-st.png" );
		menuListImageView.image = UIImage( named: SkinManager.getAssetPresetsMenus() + "object-list.png" );
		
		groundStatisticsImageView.image = UIImage( named: SkinManager.getAssetPresetsStatistics() + "stat-object.png" );
		groundGamesStandingImageView.image = UIImage( named: SkinManager.getAssetPresetsPlay() + "standing-box.png" );
		groundGamesFloatingImageView.image = UIImage( named: SkinManager.getAssetPresetsPlay() + "floating-box.png" );
		
		groundCharacterImageView.image = UIImage( named: SkinManager.getAssetPresetsCharacter() + "character-" + "0001" + ".png" );
		
	}
	
	override func viewWillAppear(animated: Bool) {
		setImagesToCurrentSkin();
	}
	
	func popToRootAction() {
		//Pop to root by back button
		self.navigationController?.popViewControllerAnimated(true);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
}