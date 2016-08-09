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