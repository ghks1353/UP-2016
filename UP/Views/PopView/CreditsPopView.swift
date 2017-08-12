//
//  CreditsPopView.swift
//  UP
//
//  Created by ExFl on 2016. 6. 23..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class CreditsPopView:UIModalPopView {
	
	//클래스 외부접근을 위함
	static var selfView:CreditsPopView?
	
	var creditsScrollView:UIScrollView = UIScrollView()
	
	var creditLogo:UIImageView = UIImageView()
	var creditVersionInfo:UILabel = UILabel()
	
	var madeByImages:Array<UIImageView> = []
	var madeByNicknames:Array<UILabel> = []
	var madeByPositions:Array<UILabel> = []
	
	var creditTitleSpecialThanks:UILabel = UILabel()
	var creditContentsSpecialThanks:UILabel = UILabel()
	
	var creditTitleLicense:UILabel = UILabel()
	var creditContentsLicense:UILabel = UILabel()
	
	
	///////////////////////
	var easterEggGameCount:Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("settingsCredits") )
		CreditsPopView.selfView = self
		
		creditsScrollView.frame = CGRect(x: 0, y: 0, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height)
		
		/////// 크레딧 로고
		creditLogo.image = UIImage( named: "modal-credits-logo.png" )
		creditLogo.frame = CGRect(x: creditsScrollView.frame.width / 2 - (151.1 / 2), y: 32, width: 151.1, height: 23.1)
		creditsScrollView.addSubview(creditLogo)
		
		// 버전정보
		creditVersionInfo.frame = CGRect(x: 0, y: creditLogo.frame.maxY + 8, width: creditsScrollView.frame.width, height: 18)
		creditVersionInfo.font = UIFont.systemFont(ofSize: 15)
		creditVersionInfo.textColor = UIColor.gray
		creditVersionInfo.textAlignment = .center
		creditVersionInfo.text = "Version " + ((Bundle.main.infoDictionary?["CFBundleVersion"])! as! String)
		creditsScrollView.addSubview(creditVersionInfo)
		
		// 만든 인물들
		for i:Int in 0 ..< 2 {
			var position:String = ""
			var nickname:String = ""
			var positionLabeled:String = ""
			
			switch(i) {
				case 0:
					position = "programmer"
					nickname = "ExFl"
					positionLabeled = "Programming"
					break
				case 1:
					position = "graphic"
					nickname = "Penple"
					positionLabeled = "Graphic"
					break
				default: break
			} //end switch
			
			let tmpUIImageView:UIImageView = UIImageView( image: UIImage( named: "modal-credits-people-" +  position + ".png" ) )
			tmpUIImageView.frame = CGRect(
				x: (creditsScrollView.frame.width / 2 + CGFloat((i-1) * 72)) + (i == 0 ? -4 : 4)
				, y: creditVersionInfo.frame.maxY + 32, width: 72, height: 72)
			let tmpNickLabel:UILabel = UILabel()
			let tmpPositions:UILabel = UILabel()
			
			tmpNickLabel.frame = CGRect(x: tmpUIImageView.frame.minX, y: tmpUIImageView.frame.maxY + 4, width: 72, height: 18)
			tmpNickLabel.textColor = UIColor.black
			tmpNickLabel.textAlignment = .center
			tmpNickLabel.font = UIFont.boldSystemFont(ofSize: 15)
			tmpNickLabel.text = nickname
			
			tmpPositions.frame = CGRect(x: tmpUIImageView.frame.minX - 3, y: tmpNickLabel.frame.maxY - 1, width: 76, height: 16)
			tmpPositions.textColor = UIColor.gray
			tmpPositions.textAlignment = .center
			tmpPositions.font = UIFont.systemFont(ofSize: 12)
			tmpPositions.text = positionLabeled
			
			creditsScrollView.addSubview(tmpUIImageView)
			creditsScrollView.addSubview(tmpNickLabel)
			creditsScrollView.addSubview(tmpPositions)
			
			// add touch gesture
			let tGest:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector( creatorSelectionHandler ))
			tmpUIImageView.tag = i
			tmpUIImageView.isUserInteractionEnabled = true
			tmpUIImageView.addGestureRecognizer(tGest)
			
			madeByImages += [tmpUIImageView]
			madeByNicknames += [tmpNickLabel]
			madeByPositions += [tmpPositions]
		} //만든 인물들 끝
		
		
		//ㄱㅅ
		creditTitleSpecialThanks.frame = CGRect(x: 0, y: madeByPositions[madeByPositions.count - 1].frame.maxY + 48, width: creditsScrollView.frame.width, height: 24)
		creditTitleSpecialThanks.textColor = UIColor.black
		creditTitleSpecialThanks.textAlignment = .center
		creditTitleSpecialThanks.font = UIFont.systemFont(ofSize: 20)
		creditTitleSpecialThanks.text = "Special Thanks"
		
		creditContentsSpecialThanks.frame = CGRect(x: 12, y: creditTitleSpecialThanks.frame.maxY + 18, width: creditsScrollView.frame.width - 24, height: 0);
		creditContentsSpecialThanks.numberOfLines = 0; creditContentsSpecialThanks.lineBreakMode = .byWordWrapping;
		creditContentsSpecialThanks.textColor = UPUtils.colorWithHexString("#444444"); creditContentsSpecialThanks.textAlignment = .center;
		creditContentsSpecialThanks.font = UIFont.systemFont(ofSize: 10)
		creditContentsSpecialThanks.text = "Thanks to CellularHacker, NotonAlcyone, Sang Wook Park, Seung Yeon Seo, Dae Yang Choi and Joong Wan Koo for helping us with our project."
		creditContentsSpecialThanks.sizeToFit()
		
		creditsScrollView.addSubview(creditTitleSpecialThanks)
		creditsScrollView.addSubview(creditContentsSpecialThanks)
		
		//라이센스
		creditTitleLicense.frame = CGRect(x: 0, y: creditContentsSpecialThanks.frame.maxY + 48, width: creditsScrollView.frame.width, height: 24)
		creditTitleLicense.textColor = UIColor.black
		creditTitleLicense.textAlignment = .center
		creditTitleLicense.font = UIFont.systemFont(ofSize: 20)
		creditTitleLicense.text = "License"
		
		creditContentsLicense.frame = CGRect(x: 12, y: creditTitleLicense.frame.maxY + 18, width: creditsScrollView.frame.width - 24, height: 0)
		creditContentsLicense.numberOfLines = 0
		creditContentsLicense.lineBreakMode = .byWordWrapping
		creditContentsLicense.textColor = UPUtils.colorWithHexString("#444444")
		creditContentsLicense.textAlignment = .center
		creditContentsLicense.font = UIFont.systemFont(ofSize: 10)
		
		creditContentsLicense.lineBreakMode = .byCharWrapping
		creditContentsLicense.text =
			"Open source license\n\n" +
			"gifu by Reda Lemeden, MIT License\n" +
			"SwiftyStoreKit by Andrea Bizzotto, MIT License\n" +
			"SwiftyJSON by Ruoyu Fu, MIT License\n" +
			"SQLite.swift by Stephen Celis, MIT License\n" +
			"CryptoSwift by Marcin Krzyżanowski, zlib License\n" +
			"Charts by Daniel Cohen Gindi & Philipp Jahoda, Apache License\n" +
			"pop by Facebook, BSD License\n" +
			
			"\n\n\nCopyright (c) 2016-2017 <Project UP> by SeokHwan An and Seungha Hwang."
		creditContentsLicense.sizeToFit()
		
		creditsScrollView.addSubview(creditTitleLicense)
		creditsScrollView.addSubview(creditContentsLicense)
		
		//컨텐츠 크기 설정
		creditsScrollView.contentSize = CGSize(width: DeviceManager.defaultModalSizeRect.width, height: max(DeviceManager.defaultModalSizeRect.height - (self.navigationController?.navigationBar.frame.size.height)!, creditContentsLicense.frame.maxY + 20))
		self.view.addSubview(creditsScrollView)
		
		
		////// Easter egg! :)
		let tGesture = UITapGestureRecognizer(target:self, action: #selector(self.gozaGogo(_:)))
		creditLogo.isUserInteractionEnabled = true
		creditLogo.addGestureRecognizer(tGesture)
	} ////////// end initial func
	
	//////////////////////////////
	
	func creatorSelectionHandler ( _ sender:UIGestureRecognizer ) {
		if (sender.view == nil) {
			return
		} // end if
		
		//print( "tag touched",sender.view!.tag   )
		switch( sender.view!.tag ) {
			case 0: // ExFl 터치
				
				break
			case 1: // 황승하 터치
				SoundManager.playEffectSound(SoundManager.bundleSystemSounds.seungHaKundae.rawValue)
				break
			default: break
		} // end switch
		
	} // end func
	
	func gozaGogo( _ gst:UIGestureRecognizer ) {
		if (LanguagesManager.currentLocaleCode != LanguagesManager.LanguageCode.Korean) {
			return //다른 로케일이면 막음
		} //end if
		
		easterEggGameCount += 1
		
		if (easterEggGameCount > 10) {
			GameModeView.setGame( 573573 )
			
			SettingsView.selfView!.dismiss(animated: true, completion: { _ in
				ViewController.selfView!.runGame() //게임 시작 호출
			})
		} // end if
	} ////////// end func
	
}
