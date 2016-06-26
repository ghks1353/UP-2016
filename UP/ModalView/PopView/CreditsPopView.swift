//
//  CreditsPopView.swift
//  UP
//
//  Created by ExFl on 2016. 6. 23..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;


class CreditsPopView:UIViewController {
	
	//클래스 외부접근을 위함
	static var selfView:CreditsPopView?;
	
	var creditsScrollView:UIScrollView = UIScrollView();
	
	var creditLogo:UIImageView = UIImageView();
	var creditVersionInfo:UILabel = UILabel();
	
	var madeByImages:Array<UIImageView> = [];
	var madeByNicknames:Array<UILabel> = [];
	var madeByPositions:Array<UILabel> = [];
	
	var creditTitleSpecialThanks:UILabel = UILabel();
	var creditContentsSpecialThanks:UILabel = UILabel();
	
	var creditTitleLicense:UILabel = UILabel();
	var creditContentsLicense:UILabel = UILabel();
	
	override func viewDidLoad() {
		super.viewDidLoad();
		CreditsPopView.selfView = self;
		
		self.view.backgroundColor = .clearColor();
		
		//ModalView
		self.view.backgroundColor = UIColor.whiteColor();
		self.title = Languages.$("settingsCredits");
		
		// Make modal custom image buttons
		let navLeftPadding:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil);
		navLeftPadding.width = -12; //Button left padding
		let navCloseButton:UIButton = UIButton(); //Add image into UIButton
		navCloseButton.setImage( UIImage(named: "modal-back"), forState: .Normal);
		navCloseButton.frame = CGRectMake(0, 0, 45, 45); //Image frame size
		navCloseButton.addTarget(self, action: #selector(CreditsPopView.popToRootAction), forControlEvents: .TouchUpInside);
		self.navigationItem.leftBarButtonItems = [ navLeftPadding, UIBarButtonItem(customView: navCloseButton) ];
		self.navigationItem.hidesBackButton = true; //뒤로 버튼을 커스텀했기 때문에, 가림
		
		creditsScrollView.frame = CGRectMake(0, 0, DeviceGeneral.defaultModalSizeRect.width, DeviceGeneral.defaultModalSizeRect.height);
		
		/////// 크레딧 로고
		creditLogo.image = UIImage( named: "modal-credits-logo.png" );
		creditLogo.frame = CGRectMake(creditsScrollView.frame.width / 2 - (151.1 / 2), 32, 151.1, 23.1);
		creditsScrollView.addSubview(creditLogo);
		//버전정보
		creditVersionInfo.frame = CGRectMake(0, creditLogo.frame.maxY + 8, creditsScrollView.frame.width, 18);
		creditVersionInfo.font = UIFont.systemFontOfSize(15);
		creditVersionInfo.textColor = UIColor.grayColor(); creditVersionInfo.textAlignment = .Center;
		creditVersionInfo.text = "Version " + ((NSBundle.mainBundle().infoDictionary?["CFBundleVersion"])! as! String);
		creditsScrollView.addSubview(creditVersionInfo);
		
		//만든 인물들
		for i:Int in 0 ..< 3 {
			var position:String = ""; var nickname:String = ""; var positionLabeled:String = "";
			switch(i) {
				case 0:
					position = "programmer";
					nickname = "ExFl";
					positionLabeled = "Programming";
					break;
				case 1:
					position = "graphic";
					nickname = "Penple";
					positionLabeled = "Graphic";
					break;
				case 2:
					position = "plan";
					nickname = "Noton";
					positionLabeled = "Design";
					break;
				default: break;
			}
			let tmpUIImageView:UIImageView = UIImageView( image: UIImage( named: "modal-credits-people-" +  position + ".png" ) );
			tmpUIImageView.frame = CGRectMake(
				(creditsScrollView.frame.width / 2 + CGFloat((i-1) * (72 + 7))) - (72 / 2)
				, creditVersionInfo.frame.maxY + 32, 72, 72);
			let tmpNickLabel:UILabel = UILabel(); let tmpPositions:UILabel = UILabel();
			tmpNickLabel.frame = CGRectMake(tmpUIImageView.frame.minX, tmpUIImageView.frame.maxY + 4, 72, 18);
			tmpNickLabel.textColor = UIColor.blackColor(); tmpNickLabel.textAlignment = .Center;
			tmpNickLabel.font = UIFont.boldSystemFontOfSize(15); tmpNickLabel.text = nickname;
			tmpPositions.frame = CGRectMake(tmpUIImageView.frame.minX - 3, tmpNickLabel.frame.maxY - 1, 76, 16);
			tmpPositions.textColor = UIColor.grayColor(); tmpPositions.textAlignment = .Center;
			tmpPositions.font = UIFont.systemFontOfSize(12); tmpPositions.text = positionLabeled;
			
			creditsScrollView.addSubview(tmpUIImageView);
			creditsScrollView.addSubview(tmpNickLabel);
			creditsScrollView.addSubview(tmpPositions);
			madeByImages += [tmpUIImageView];
			madeByNicknames += [tmpNickLabel];
			madeByPositions += [tmpPositions];
		} //만든 인물들 끝
		
		
		//ㄱㅅ
		creditTitleSpecialThanks.frame = CGRectMake(0, madeByPositions[madeByPositions.count - 1].frame.maxY + 48, creditsScrollView.frame.width, 24);
		creditTitleSpecialThanks.textColor = UIColor.blackColor(); creditTitleSpecialThanks.textAlignment = .Center;
		creditTitleSpecialThanks.font = UIFont.systemFontOfSize(20);
		creditTitleSpecialThanks.text = "Special Thanks"; creditsScrollView.addSubview(creditTitleSpecialThanks);
		
		creditContentsSpecialThanks.frame = CGRectMake(12, creditTitleSpecialThanks.frame.maxY + 18, creditsScrollView.frame.width - 24, 0);
		creditContentsSpecialThanks.numberOfLines = 0; creditContentsSpecialThanks.lineBreakMode = .ByWordWrapping;
		creditContentsSpecialThanks.textColor = UPUtils.colorWithHexString("#444444"); creditContentsSpecialThanks.textAlignment = .Center;
		creditContentsSpecialThanks.font = UIFont.systemFontOfSize(10);
		creditContentsSpecialThanks.text = "Thanks to CellularHacker, Sang Wook Park, Seung Yeon Seo, Dae Yang Choi and Joong Wan Koo for helping us with our project.";
		creditContentsSpecialThanks.sizeToFit();
		creditsScrollView.addSubview(creditContentsSpecialThanks);
		
		//라이센스
		creditTitleLicense.frame = CGRectMake(0, creditContentsSpecialThanks.frame.maxY + 48, creditsScrollView.frame.width, 24);
		creditTitleLicense.textColor = UIColor.blackColor(); creditTitleLicense.textAlignment = .Center;
		creditTitleLicense.font = UIFont.systemFontOfSize(20);
		creditTitleLicense.text = "License"; creditsScrollView.addSubview(creditTitleLicense);
		
		creditContentsLicense.frame = CGRectMake(12, creditTitleLicense.frame.maxY + 18, creditsScrollView.frame.width - 24, 0);
		creditContentsLicense.numberOfLines = 0; creditContentsLicense.lineBreakMode = .ByWordWrapping;
		creditContentsLicense.textColor = UPUtils.colorWithHexString("#444444"); creditContentsLicense.textAlignment = .Center;
		creditContentsLicense.font = UIFont.systemFontOfSize(10);
		creditContentsLicense.text =
			"Cryptoswift is copyrighted by Marcin Krzyżanowski, SwiftyJSON is copyrighted by Ruoyu Fu licensed under the MIT, Gifu is copyrighted by Reda Lemeden licensed under the MIT, Charts is copyrighted by Daniel Cohen Gindi & Philipp Jahoda licensed under the Apache License 2.0\n\nCopyright (c) 2016 <Project UP> by Seokhwan An and Seungha hwang.";
		creditContentsLicense.sizeToFit();
		creditsScrollView.addSubview(creditContentsLicense);
		
		//컨텐츠 크기 설정
		creditsScrollView.contentSize = CGSizeMake(DeviceGeneral.defaultModalSizeRect.width, max(DeviceGeneral.defaultModalSizeRect.height - (self.navigationController?.navigationBar.frame.size.height)!, creditContentsLicense.frame.maxY + 20));
		
		self.view.addSubview(creditsScrollView);
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