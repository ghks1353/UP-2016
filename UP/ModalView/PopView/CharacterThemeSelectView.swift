//
//  CharacterThemeSelectView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 10..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class CharacterThemeSelectView:UIModalPopView {
	
	//// Theme category (default value is main)
	var currentThemeCategory:ThemeManager.ThemeGroup = ThemeManager.ThemeGroup.Main
	var selectedThemeData:ThemeData?
	
	////////// Draw Skin window
	let themeWindowSideMargin:CGFloat = 12
	var themeWindowUpsideMargin:CGFloat = 18
	
	let themeItemsMargin:CGFloat = 6
	
	//////////////////////////////////////////////////////
	let tWindowLT:UIImageView = UIImageView() //Left top
	let tWindowT:UIImageView = UIImageView() // Top
	let tWindowRT:UIImageView = UIImageView() //Right top
	let tWindowLB:UIImageView = UIImageView() //Left bottom
	let tWindowB:UIImageView = UIImageView() //Bottom
	let tWindowRB:UIImageView = UIImageView() //Right bottom
	let tWindowSLT:UIView = UIView() //Side-Left Top
	let tWindowSLB:UIView = UIView() //Side-Left Bottom
	let tWindowSRT:UIView = UIView() //Side-Right Top
	let tWindowSRB:UIView = UIView() //Side-Right Bottom
	//////////////////////////////////////////////////
	let tWindowInnerView:UIView = UIView()
	let tWindowM:UIView = UIView() // center blue-line
	let tWindowSelectView:UIScrollView = UIScrollView()
	//////////////////////////////////////////////////
	var tSelectedWrapper:UIView = UIView()
	var tSelectedImage:UIImage?
	var tSelectedImageView:UIImageView = UIImageView()
	var tSelectedMaskImageView:UIImageView = UIImageView()
	var tSelectedAlphaUIView:UIView = UIView()
	
	var tSelectedThemeTitle:UILabel = UILabel()
	var tSelectedThemeDescription:UILabel = UILabel()
	
	///////////////////////////////
	let tItemBackgroundImage:UIImage = UIImage( named: "themes-select-item.png" )!
	let tItemLockedImage:UIImage = UIImage( named: "themes-select-item-locked.png" )!
	
	var tItemsArray:Array<UIButton> = []
	///////////////////////////////
	var selectedThemeIndex:Int = 0
	
	var navHeight:CGFloat = 0
	
	override func viewDidLoad() {
		super.viewDidLoad( title: LanguagesManager.$("userTheme") )
		
		navHeight = self.navigationController!.navigationBar.frame.size.height
		
		//background add
		let skinBackground:UIImageView = UIImageView( image: UIImage( named: "themes-select-background.png" ))
		skinBackground.frame = CGRect( x: 0, y: navHeight, width: DeviceManager.defaultModalSizeRect.width, height: DeviceManager.defaultModalSizeRect.height - navHeight)
		self.view.addSubview(skinBackground) //subview for background
		
		//////// Draw window
		
		////////// Draw edges
		tWindowLT.image = UIImage( named: "themes-select-side-up-left.png" )
		tWindowRT.image = UIImage( named: "themes-select-side-up-right.png" )
		tWindowLB.image = UIImage( named: "themes-select-side-down-left.png" )
		tWindowRB.image = UIImage( named: "themes-select-side-down-right.png" )
		
		self.view.addSubview(tWindowLT)
		self.view.addSubview(tWindowRT)
		self.view.addSubview(tWindowLB)
		self.view.addSubview(tWindowRB)
		
		tWindowLT.frame = CGRect( x: themeWindowSideMargin, y: themeWindowUpsideMargin + navHeight, width: 6, height: 6 )
		tWindowRT.frame = CGRect( x: DeviceManager.defaultModalSizeRect.width - themeWindowSideMargin - 6, y: themeWindowUpsideMargin + navHeight, width: 6, height: 6 )
		tWindowLB.frame = CGRect( x: themeWindowSideMargin, y: skinBackground.frame.height + navHeight - themeWindowUpsideMargin - 6, width: 6, height: 6 )
		tWindowRB.frame = CGRect( x: tWindowRT.frame.minX, y: tWindowLB.frame.minY, width: 6, height: 6 )
		
		//////////// Draw up/downside lines
		tWindowT.image = UIImage( named: "themes-select-side-up.png" )
		tWindowB.image = UIImage( named: "themes-select-side-down.png" )
		
		tWindowT.frame = CGRect( x: tWindowLT.frame.maxX, y: tWindowLT.frame.minY, width: tWindowRT.frame.minX - tWindowLT.frame.maxX, height: tWindowLT.frame.height )
		tWindowB.frame = CGRect( x: tWindowLB.frame.maxX, y: tWindowLB.frame.minY, width: tWindowRB.frame.minX - tWindowLB.frame.maxX, height: tWindowLT.frame.height )
		
		self.view.addSubview(tWindowT)
		self.view.addSubview(tWindowB)
		
		///////////////// Draw Side colors
		let previewWindowHeight:CGFloat = (110 + 7.8) * DeviceManager.maxScrRatioC
		
		tWindowSLT.backgroundColor = UPUtils.colorWithHexString("#747474")
		tWindowSRT.backgroundColor = tWindowSLT.backgroundColor
		tWindowSLB.backgroundColor = UPUtils.colorWithHexString("#5D5858")
		tWindowSRB.backgroundColor = tWindowSLB.backgroundColor
		
		tWindowSLT.frame = CGRect(x: tWindowLT.frame.minX, y: tWindowLT.frame.maxY, width: tWindowLT.frame.width, height: previewWindowHeight + 7.8)
		tWindowSRT.frame = CGRect(x: tWindowRT.frame.minX, y: tWindowRT.frame.maxY, width: tWindowRT.frame.width, height: tWindowSLT.frame.height)
		tWindowSLB.frame = CGRect(x: tWindowSLT.frame.minX, y: tWindowSLT.frame.maxY, width: tWindowSLT.frame.width, height: (tWindowLB.frame.minY - tWindowLT.frame.maxY - 122.15 - tWindowLB.frame.height))
		tWindowSRB.frame = CGRect(x: tWindowSRT.frame.minX, y: tWindowSRT.frame.maxY, width: tWindowSRT.frame.width, height: tWindowSLB.frame.height)
		
		self.view.addSubview(tWindowSLT)
		self.view.addSubview(tWindowSRT)
		self.view.addSubview(tWindowSLB)
		self.view.addSubview(tWindowSRB)
		
		///////////////// Draw inner-views
		tWindowInnerView.backgroundColor = UIColor.white
		tWindowInnerView.frame = CGRect( x: tWindowLT.frame.maxX, y: tWindowLT.frame.maxY, width: tWindowRT.frame.minX - tWindowLT.frame.maxX, height: tWindowLB.frame.minY - tWindowLT.frame.maxY )
		self.view.addSubview(tWindowInnerView)
		
		tWindowM.backgroundColor = UPUtils.colorWithHexString("#5F87C2")
		tWindowM.frame = CGRect( x: tWindowInnerView.frame.minX, y: tWindowInnerView.frame.minY + previewWindowHeight, width: tWindowInnerView.frame.width, height: 7.8 )
		self.view.addSubview(tWindowM)
		
		tWindowSelectView.backgroundColor = UPUtils.colorWithHexString("#4E5596")
		tWindowSelectView.frame = CGRect( x: tWindowLT.frame.maxX, y: tWindowM.frame.maxY, width: tWindowInnerView.frame.width, height: tWindowLB.frame.minY - tWindowM.frame.maxY )
		self.view.addSubview(tWindowSelectView)
		
		////////////////////////////////////////
		//////////////////// Draw theme details
		tSelectedWrapper.backgroundColor = UIColor.brown
		tSelectedWrapper.frame = CGRect( x: 0, y: 0, width: previewWindowHeight, height: previewWindowHeight )
		
		tSelectedWrapper.addSubview(tSelectedImageView)
		
		//add to innerview
		tWindowInnerView.addSubview(tSelectedWrapper)
		//////////////////////////////////////////
		//////////////////// theme details label
		tSelectedThemeTitle.frame = CGRect(x: tSelectedWrapper.frame.maxX, y: 0, width: tWindowInnerView.frame.width - tSelectedWrapper.frame.width, height: 20)
		tSelectedThemeTitle.font = UIFont.boldSystemFont(ofSize: 15)
		tSelectedThemeTitle.textColor = UIColor.black
		tSelectedThemeTitle.textAlignment = .left
		
		tWindowInnerView.addSubview(tSelectedThemeTitle)
		
	} /////////// end func
	
	///////// select category
	func setThemeCategory( themeCategory:ThemeManager.ThemeGroup ) {
		currentThemeCategory = themeCategory
	} //end func
	
	override func viewWillAppear(_ animated: Bool) {
		//// draw and load skin lists.
		
		switch (currentThemeCategory) {
			case .Main:
				self.title = LanguagesManager.$("userThemeGroupMain")
				break
			case .StatsSign:
				self.title = LanguagesManager.$("userThemeGroupStats")
				break
			case .GameIcon:
				self.title = LanguagesManager.$("userThemeGroupGame")
				break
			case .Character:
				self.title = LanguagesManager.$("userThemeGroupCharacter")
				break
			default: break
		} //end switch
		
		drawItems( themeCategory: currentThemeCategory )
		showThemeDetails(index: selectedThemeIndex)
	} //end func
	
	////////////////////////////////
	func drawItems( themeCategory:ThemeManager.ThemeGroup ) {
		if (ThemeManager.themesData[ themeCategory ] == nil) {
			print("Error: themes data not found for group", themeCategory)
			return
		} //end if
		//// Remove existing views
		for i:Int in 0 ..< tItemsArray.count {
			tItemsArray[i].removeFromSuperview()
		} //end for
		tItemsArray.removeAll()
		
		let listData:Array<ThemeData> = ThemeManager.themesData[ themeCategory ]!
		
		/// 몇개를 배열할지 정함.
		//tWindowSelectView.frame.width
		//themeItemsMargin
		let itemsPerLine:Int = Int(floor( tWindowSelectView.frame.width / (55.2 + themeItemsMargin) ))
		let itemsListMargin:CGFloat = (tWindowSelectView.frame.width - (((55.2 + themeItemsMargin) * CGFloat(itemsPerLine)) - themeItemsMargin)) / 2
		
		print("Items per:", itemsPerLine)
		
		for i:Int in 0 ..< listData.count {
			if (listData[i].themeHidden == true) {
				continue //숨겨진 테마일 경우 그리지 않음
			} //////////////////////////////////
			
			//선택된 테마는 인덱스를 저장해서 자동선택 되도록.
			if (listData[i].themeID == ThemeManager.selectedThemes[ themeCategory ]) {
				selectedThemeIndex = i
			} //end if
			
			let tmpUIButton:UIButton = UIButton()
			let tmpUIView:UIView = UIView() //add images to uiview
			
			let tmpButtonBackgroundImageView:UIImageView = UIImageView( image: tItemBackgroundImage )
			let tmpButtonThumbs:UIImageView = UIImageView()
			tmpButtonBackgroundImageView.frame = CGRect( x: 0, y: 0, width: 55.2, height: 55.2 )
			tmpButtonThumbs.frame = tmpButtonBackgroundImageView.frame
			
			tmpButtonThumbs.image = UIImage( named: ThemeManager.getAssetPresets(themeGroup: themeCategory, themeID: listData[i].themeID) + ThemeManager.getName( ThemeManager.ThemeFileNames.Thumbnails + "-" + ThemeManager.getGroupStr( themeCategory ) ) )
			
			tmpUIView.addSubview( tmpButtonBackgroundImageView )
			tmpUIView.addSubview( tmpButtonThumbs )
			
			tmpUIButton.frame = CGRect( x: itemsListMargin + ((55.2 + themeItemsMargin) * CGFloat(i % itemsPerLine)), y: itemsListMargin + ((55.2 + themeItemsMargin) * floor(CGFloat(i / itemsPerLine))), width: 55.2, height: 55.2 )
			
			tmpUIButton.addSubview( tmpUIView )
			tItemsArray.append( tmpUIButton )
			
			tmpUIButton.tag = i
			tmpUIButton.addTarget(self, action: #selector(self.showDetailsFor(sender:)), for: .touchUpInside)
			tmpUIButton.isUserInteractionEnabled = true
			tWindowSelectView.addSubview( tmpUIButton )
		} //end for
		
		//set scrollview content height
		var maxItemYPosition:CGFloat = 0
		if (tItemsArray.count > 0) {
			maxItemYPosition = tItemsArray[tItemsArray.count - 1].frame.maxY + themeItemsMargin
		} //end if
		
		tWindowSelectView.contentSize = CGSize( width: tWindowSelectView.frame.width, height: max( tWindowSelectView.frame.height, maxItemYPosition ) )
	} //end func
	
	func showThemeDetails( index:Int ) {
		if (ThemeManager.themesData[ currentThemeCategory ]!.count < index) {
			print("Error: detail show failed. out of index.")
			return
		} //end if
		
		selectedThemeData = ThemeManager.themesData[ currentThemeCategory ]![index]
		print("You selected theme",selectedThemeData!.themeID)
		
		//Category별 대표 이미지 가져와야 함
		var previewImageForCategory:String = ""
		//Category별 scale factor
		var previewImageScaleFactor:CGFloat = 1
		
		switch( currentThemeCategory ) {
			case .Main:
				previewImageForCategory = ThemeManager.ThemeFileNames.AnalogClockBody
				break
			case .StatsSign:
				previewImageForCategory = ThemeManager.ThemeFileNames.ObjectStatistics
				previewImageScaleFactor = 2
				break
			case .GameIcon:
				previewImageForCategory = ThemeManager.ThemeFileNames.ObjectGameFloating
				previewImageScaleFactor = 4
				break
			case .Character:
				previewImageForCategory = ThemeManager.ThemeFileNames.Character
				previewImageScaleFactor = 2
				break
			default: break
		} //end switch
		
		var selectedImageNameStr:String = ""
		
		if (previewImageForCategory == ThemeManager.ThemeFileNames.Character) {
			//캐릭터의 경우, 캐릭터 1프레임에 있는 모습으로 보여줌
			selectedImageNameStr = ThemeManager.getAssetPresets(themeGroup: .Character) + ThemeManager.ThemeFileNames.Character + "-0" + ".png"
		} else {
			//다른 테마의 경우 기존 에셋 표시
			selectedImageNameStr = ThemeManager.getAssetPresets(themeGroup: currentThemeCategory, themeID: selectedThemeData!.themeID) + ThemeManager.getName( previewImageForCategory )
		} //end if
		
		tSelectedImage = UIImage( named: selectedImageNameStr )!
		tSelectedImageView.image = tSelectedImage!
		
		tSelectedImageView.frame = CGRect( x: tSelectedWrapper.frame.midX - (tSelectedWrapper.frame.width * previewImageScaleFactor) / 2, y: tSelectedWrapper.frame.midY - (tSelectedWrapper.frame.height * previewImageScaleFactor) / 2, width: tSelectedWrapper.frame.width * previewImageScaleFactor, height: tSelectedWrapper.frame.height * previewImageScaleFactor )

		//// set label
		tSelectedThemeTitle.text = selectedThemeData!.name[ LanguagesManager.currentLocaleCode ]
		
	} //end func
	
	func showDetailsFor( sender:UIButton ) {
		showThemeDetails(index: sender.tag)
	} //end func
	
	
	
	
} //// end class
