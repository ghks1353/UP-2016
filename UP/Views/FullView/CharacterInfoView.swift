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
import Gifu

class CharacterInfoView:UIViewController {
	
	///// 화면 에셋
	var cLevelWrapper:UIImageView = UIImageView()
	var cLevelIndicator:UIImageView = UIImageView()
	
	var cExpWrapper:UIImageView = UIImageView()
	var cExpMaskView:UIView = UIView() //Exp 내용물 마스크 처리를 위함
	var cExpProgress:UIView = UIView()
	var cExpProgressAnimation:GIFImageView = GIFImageView()
	
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
	/////////////////////////////
	////// Digital number 제작
	var digitalNumberImages:[UIImage] = []
	var digitalNumberViews:[UIImageView] = []
	var digitalNumberWrapper:UIView = UIView()
	
	//////////// 메인에 띄울 캐릭터 및 wrapper
	var cCharacterWrapper:UIView = UIView()
	var cCharacter:UIImageView = UIImageView()
	var cCharacterGround:UIImageView = UIImageView()
	
	//////////// 캐릭터 상품 설명 wrapper 및 내용
	var cThemeInformationWrapper:UIView = UIView()
	
	var cThemeInformationTitle:UILabel = UILabel()
	var cThemeInformationDescription:UILabel = UILabel()
	
	var cThemeInformationBuy:UIButton = UIButton()
	
	/////////////////////// 테마 선택 화면 윈도우
	///////////// Wrapper
	var tWindowView:UIView = UIView()
	//////////// iPad 전용 ImageView (Background 사용 전용)
	var tWindowBackgroundImageView:UIImageView = UIImageView()
	//////////// iPhone/Pod 전용 Background UIView
	var tWindowBackgroundTopView:UIView = UIView()
	var tWindowBackgroundBottomView:UIView = UIView()
	var tWindowCloseView:UIButton = UIButton()
	//////////// 테마 상품 컨테이너
	var tWindowContainer:UIScrollView = UIScrollView()
	
	
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
		
		labelAchievement.frame = CGRect(x: cAchievementBackgroundView.frame.minX + -15 * DeviceManager.maxScrRatioC, y: cAchievementBackgroundView.frame.maxY + 6 * DeviceManager.maxScrRatioC, width: 106 * DeviceManager.maxScrRatioC, height: 24)
		labelAchievement.font = UIFont.systemFont(ofSize: 14)
		labelAchievement.textColor = UIColor.white
		labelAchievement.textAlignment = .center
		labelAchievement.text = LanguagesManager.$("achievements")
		
		labelClose.frame = CGRect(x: cClose.frame.minX + -15 * DeviceManager.maxScrRatioC, y: labelAchievement.frame.minY, width: labelAchievement.frame.width, height: labelAchievement.frame.height)
		labelClose.font = UIFont.systemFont(ofSize: 14)
		labelClose.textColor = UIColor.white
		labelClose.textAlignment = .center
		labelClose.text = LanguagesManager.$("generalClose")
		
		labelTheme.frame = CGRect(x: cThemeBackgroundView.frame.minX + -15 * DeviceManager.maxScrRatioC, y: labelAchievement.frame.minY, width: labelAchievement.frame.width, height: labelAchievement.frame.height)
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
		////////// Draw character
		
		//Character image의 경우, 스킨변경 확인 함수쪽에서 작업함. 위치만 조정
		cCharacter.frame = CGRect(x: 0, y: 0, width: 300 * DeviceManager.maxScrRatioC, height: 300 * DeviceManager.maxScrRatioC)
		cCharacterGround.image = UIImage( named: "characterinfo-themes-ground.png" )
		cCharacterGround.frame = CGRect(x: cCharacter.frame.midX - (51.3 * DeviceManager.maxScrRatioC) / 2, y: cCharacter.frame.midY + 32 * DeviceManager.maxScrRatioC, width: 51.3 * DeviceManager.maxScrRatioC, height: 79.75 * DeviceManager.maxScrRatioC)
		
		cCharacterWrapper.addSubview(cCharacterGround)
		cCharacterWrapper.addSubview(cCharacter)
		
		cCharacterWrapper.frame = CGRect(x: 0, y: 0, width: cCharacter.frame.maxX, height: cCharacter.frame.maxY)
		self.view.addSubview(cCharacterWrapper)
		
		//// draw top background
		cTopBackgroundView.image = UIImage( named: "characterinfo-background.png" )
		self.view.addSubview(cTopBackgroundView)
		
		///////// Draw theme description
		//Wrapper: cThemeInformationWrapper
		
		cThemeInformationTitle.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width - cCharacterGround.frame.width - 14 - 12 - 12, height: 22)
		cThemeInformationDescription.frame = CGRect(x: 0, y: cThemeInformationTitle.frame.maxY + 8, width: cThemeInformationTitle.frame.width, height: (cCharacterGround.frame.height * 2) - 22 - 8)
		
		cThemeInformationTitle.font = UIFont.boldSystemFont(ofSize: 18)
		cThemeInformationTitle.textColor = UIColor.white
		cThemeInformationTitle.textAlignment = .left
		cThemeInformationTitle.text = "TESTESSTTSTSTS"
		
		cThemeInformationDescription.font = UIFont.systemFont(ofSize: 15)
		cThemeInformationDescription.textColor = UIColor.white
		cThemeInformationDescription.textAlignment = .left
		
		cThemeInformationDescription.text = "TESSESAEASEASEASESEASEASEㅁㅇ너ㅣㅏㅁㅇ니ㅏㅓㅁㅇ너ㅣㅏㅓㅣㅏadsasadsadsadsads"
		cThemeInformationDescription.numberOfLines = 0
		cThemeInformationDescription.sizeToFit() // 나중에 텍스트, 갱신후에도 프레임 잡아주고 호출할 필요가 있음
		
		cThemeInformationWrapper.addSubview(cThemeInformationTitle)
		cThemeInformationWrapper.addSubview(cThemeInformationDescription)
		
		cThemeInformationWrapper.backgroundColor = UIColor.brown
		self.view.addSubview(cThemeInformationWrapper)
		
		/////////////// Draw battery, level and indicator
		cLevelWrapper.image = UIImage( named: "characterinfo-level-wrapper.png" )
		cLevelIndicator.image = UIImage( named: "characterinfo-level.png" )
		cExpWrapper.image = UIImage( named: "characterinfo-exp-wrapper.png" )
		
		self.view.addSubview(cLevelWrapper)
		self.view.addSubview(cLevelIndicator)
		self.view.addSubview(cExpWrapper)
		
		cExpWrapper.frame = CGRect( x: cTopBackgroundView.frame.minX + 34 * DeviceManager.maxScrRatioC, y: 95 * DeviceManager.maxScrRatioC
			,width: 123.95 * DeviceManager.maxScrRatioC, height: 73.85 * DeviceManager.maxScrRatioC)
		
		//////// MaskView
		cExpMaskView.frame = CGRect( x: cExpWrapper.frame.minX + 6 * DeviceManager.maxScrRatioC, y: cExpWrapper.frame.minY + 6 * DeviceManager.maxScrRatioC, width: cExpWrapper.frame.width - 17 * DeviceManager.maxScrRatioC, height: cExpWrapper.frame.height - 12 * DeviceManager.maxScrRatioC )
		cExpMaskView.backgroundColor = UIColor.clear
		
		self.view.addSubview(cExpMaskView)
		
		let cExpMaskLayer:CAShapeLayer = CAShapeLayer()
		let cExpMaskRect:CGRect = CGRect(x: 0, y: 0, width: cExpMaskView.frame.width, height: cExpMaskView.frame.height )
		let cExpMaskPath:CGPath = CGPath(rect: cExpMaskRect, transform: nil)
		cExpMaskLayer.path = cExpMaskPath
		cExpMaskView.layer.mask = cExpMaskLayer
		
		///// Exp progress bar
		cExpProgress.backgroundColor = UPUtils.colorWithHexString("#00CC33")
		
		//width 100% => 100%
		cExpProgress.frame = CGRect(x: 0, y: 0, width: cExpMaskView.frame.width, height: cExpMaskView.frame.height)
		cExpMaskView.addSubview(cExpProgress)
		
		//x position to progress maxX
		cExpProgressAnimation.frame = CGRect( x: 0, y: 0, width: 62 * DeviceManager.maxScrRatioC, height: 62 * DeviceManager.maxScrRatioC )
		cExpProgressAnimation.animate(withGIFNamed: "characterinfo-exp.gif")
		//cExpProgressAnimation.
		cExpMaskView.addSubview(cExpProgressAnimation)
		
		//////// Make number sprite
		for i:Int in 0 ..< 10 {
			let tmpUIImage:UIImage = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .DigitalClock) + ThemeManager.getName( ThemeManager.ThemeFileNames.DigitalClock + "-" + String(i)) )!
			digitalNumberImages += [ tmpUIImage ]
			
		} //end for
		
		//////// Make number view and set position
		let lvImgMargin:CGFloat = 5 * DeviceManager.maxModalRatioC
		let lvImgSize:CGSize = CGSize(width: 26.4 * DeviceManager.maxModalRatioC, height: 36.9 * DeviceManager.maxModalRatioC)
		for i:Int in 0 ..< 3 {
			let tmpImgView:UIImageView = UIImageView()
			tmpImgView.image = digitalNumberImages[0] //init with zero number
			tmpImgView.frame = CGRect(x: (lvImgSize.width + lvImgMargin) * CGFloat(i), y: 0, width: lvImgSize.width, height: lvImgSize.height)
			
			digitalNumberWrapper.addSubview(tmpImgView)
			digitalNumberViews += [tmpImgView]
		} //end for
		
		digitalNumberWrapper.frame = CGRect(x: 0, y: 0, width: (lvImgSize.width + lvImgMargin) * 3 - lvImgMargin, height: lvImgSize.height)
		self.view.addSubview(digitalNumberWrapper)
		
		//// Touch listener
		var tGst:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.closeView(_:)))
		cClose.isUserInteractionEnabled = true
		cClose.addGestureRecognizer(tGst)
		
		tGst = UITapGestureRecognizer(target: self, action: #selector(self.openUserThemeSelect(_:)))
		cTheme.isUserInteractionEnabled = true
		cTheme.addGestureRecognizer(tGst)
		
		/////////////// Draw theme wrapper
		tWindowBackgroundImageView.image = UIImage( named: "characterinfo-themes-ipad.png" )
		tWindowBackgroundImageView.frame = CGRect( x: 0, y: 0, width: 303.85 * DeviceManager.maxScrRatioC, height: 247.1 * DeviceManager.maxScrRatioC )
		
		tWindowBackgroundTopView.backgroundColor = UPUtils.colorWithHexString("#232D4B")
		tWindowBackgroundBottomView.backgroundColor = UPUtils.colorWithHexString("#4A528D")
		tWindowBackgroundTopView.frame = CGRect( x: 0, y: 0, width: DeviceManager.scrSize!.width, height: 44.65 )
		tWindowBackgroundBottomView.frame = CGRect( x: 0, y: tWindowBackgroundTopView.frame.maxY, width: tWindowBackgroundTopView.frame.width, height: 160 + 24 )
		
		tWindowView.addSubview( tWindowContainer )
		
		//// Create close button (for iPhone)
		tWindowCloseView.setImage( UIImage(named: "modal-close"), for: UIControlState())
		
		//// add to wrapper 
		if (DeviceManager.isiPad) { //Pad일경우 전용 레이아웃으로 구성
			tWindowView.addSubview( tWindowBackgroundImageView )
			
			
		} else { //Phone일경우 전용 레이아웃 따로 구성
			tWindowView.addSubview( tWindowBackgroundTopView )
			tWindowView.addSubview( tWindowBackgroundBottomView )
			tWindowView.addSubview( tWindowCloseView )
			
			tWindowCloseView.frame = CGRect(x: 2, y: (tWindowBackgroundTopView.frame.maxY - 45) / 2, width: 45, height: 45)
			tWindowContainer.frame = CGRect( x: 0, y: tWindowBackgroundTopView.frame.maxY, width: tWindowBackgroundTopView.frame.width, height: tWindowBackgroundBottomView.frame.height )
			
			//Add touch event
			tWindowCloseView.addTarget(self, action: #selector(self.closeThemeView), for: .touchUpInside)
			
			//터치범위가 좁아서 추가함
			tGst = UITapGestureRecognizer(target: self, action: #selector(self.closeThemeView(_:)))
			tWindowBackgroundTopView.isUserInteractionEnabled = true
			tWindowBackgroundTopView.addGestureRecognizer(tGst)
			
		} //end if
		
		//// 초기상태 설정.
		tWindowView.alpha = 0
		tWindowView.isHidden = true
		self.view.addSubview(tWindowView)
		
	} //end init func
	//////////////////
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
		//get data from local
		DataManager.initDefaults()
		
		fitFrames()
		//현재 Select된 테마 이미지로 변경
		updateTheme()
		
	} //end func
	
	/////////////// Fit frames to center
	func fitFrames() {
		
		let wrapperWidth:CGFloat = cThemeBackgroundView.frame.maxX - cAchievementBackgroundView.frame.minX
		cBottomButtonsWrapper.frame = CGRect( x: DeviceManager.scrSize!.width / 2 - wrapperWidth / 2, y: DeviceManager.scrSize!.height - labelAchievement.frame.maxY - 64 * DeviceManager.maxScrRatioC, width: wrapperWidth, height: labelAchievement.frame.maxY )
		
		cTopBackgroundView.frame = CGRect( x: DeviceManager.scrSize!.width / 2 - (414 * DeviceManager.maxScrRatioC) / 2, y: 0, width: 414 * DeviceManager.maxScrRatioC, height: 247.85 * DeviceManager.maxScrRatioC )
		
		cLevelWrapper.frame = CGRect( x: cTopBackgroundView.frame.maxX - 21 * DeviceManager.maxScrRatioC - 139.8 * DeviceManager.maxScrRatioC,
		                              y: 40 * DeviceManager.maxScrRatioC
			, width: 139.8 * DeviceManager.maxScrRatioC, height: 84.35 * DeviceManager.maxScrRatioC)
		cLevelIndicator.frame = CGRect( x: cLevelWrapper.frame.minX - 10 * DeviceManager.maxScrRatioC - 58.05 * DeviceManager.maxScrRatioC,
		                                y: 79 * DeviceManager.maxScrRatioC
			, width: 58.05 * DeviceManager.maxScrRatioC, height: 44.8 * DeviceManager.maxScrRatioC)
		cExpWrapper.frame = CGRect( x: cTopBackgroundView.frame.minX + 34 * DeviceManager.maxScrRatioC, y: 95 * DeviceManager.maxScrRatioC
			,width: 123.95 * DeviceManager.maxScrRatioC, height: 73.85 * DeviceManager.maxScrRatioC)
		
		cCharacterWrapper.frame = CGRect(x: DeviceManager.scrSize!.width / 2 - cCharacterWrapper.frame.width / 2, y: DeviceManager.scrSize!.height / 2 - cCharacterWrapper.frame.height / 2, width: cCharacter.frame.maxX, height: cCharacter.frame.maxY)
		
		cExpMaskView.frame = CGRect( x: cExpWrapper.frame.minX + 6 * DeviceManager.maxScrRatioC, y: cExpWrapper.frame.minY + 6 * DeviceManager.maxScrRatioC, width: cExpWrapper.frame.width - 17 * DeviceManager.maxScrRatioC, height: cExpWrapper.frame.height - 12 * DeviceManager.maxScrRatioC )
		
		digitalNumberWrapper.frame = CGRect( x: cLevelWrapper.frame.minX + (cLevelWrapper.frame.width - digitalNumberWrapper.frame.width) / 2 , y: cLevelWrapper.frame.minY + (cLevelWrapper.frame.height - digitalNumberWrapper.frame.height) / 2 , width: digitalNumberWrapper.frame.width, height: digitalNumberWrapper.frame.height )
		
		tWindowView.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height - tWindowBackgroundBottomView.frame.maxY, width: DeviceManager.scrSize!.width, height: tWindowBackgroundBottomView.frame.maxY)
		
		cThemeInformationWrapper.frame = CGRect(x: cCharacterWrapper.frame.midX + cCharacterGround.frame.width / 2 + 24 * DeviceManager.maxScrRatioC, y: cCharacterWrapper.frame.midY - cCharacterGround.frame.height + 22, width: cThemeInformationTitle.frame.width, height: cThemeInformationDescription.frame.maxY)
		
		
	} //end func
	
	func updateTheme() {
		//현재 설정중인 미리보기로 변경.
		cTheme.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Default) + ThemeManager.ThemeFileNames.Thumbnails )
		
		//Load selected character's 0 frame
		cCharacter.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: .Default) + ThemeManager.ThemeFileNames.Character + "-" + "0")
	} //end func
	
	////////// Close view
	func closeView( _ gst:UITapGestureRecognizer ) {
		if (self.presentingViewController is ViewController) {
			(self.presentingViewController as! ViewController).showHideBlurview( false )
		} //end if
		self.dismiss(animated: true, completion: nil)
	} //end func
	
	//// Show theme select window (pad, phone)
	func openUserThemeSelect( _ gst:UITapGestureRecognizer ) {
		if (tWindowView.isHidden == false) {
			return
		} // end if
		
		if (DeviceManager.isiPad) {
			//Run ipad transition
			
		} else { //Run iPhone/pod transition
			
			tWindowView.isHidden = false
			tWindowView.alpha = 0
			tWindowView.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
			                         width: DeviceManager.scrSize!.width, height: tWindowView.frame.height)
			UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
				self.tWindowView.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height - self.tWindowBackgroundBottomView.frame.maxY + 24,
				                                width: DeviceManager.scrSize!.width, height: self.tWindowView.frame.height)
				self.tWindowView.alpha = 1
			}) { _ in //start completeion block
			} //end animation block
			
			
		} //end if
		
		
	} //end func
	
	// Close theme view (phone, pad)
	func closeThemeView ( _ gst:UITapGestureRecognizer? = nil ) {
		if (tWindowView.isHidden) {
			return
		} // end if
		
		if (DeviceManager.isiPad) {
			//Run ipad transition
			
		} else { //Run iPhone/pod transition
			
			UIView.animate(withDuration: 0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .curveEaseIn, animations: {
				self.tWindowView.frame = CGRect(x: 0, y: DeviceManager.scrSize!.height,
				                                width: DeviceManager.scrSize!.width, height: self.tWindowView.frame.height)
			}) { _ in //start completeion block
				
				self.tWindowView.isHidden = true
				self.tWindowView.alpha = 0
				
			} //end animation block
			
		} //end if
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
