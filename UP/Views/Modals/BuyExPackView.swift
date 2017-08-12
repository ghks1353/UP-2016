//
//  BuyExPackView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 7..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit

class BuyExPackView:UIModalView, UIScrollViewDelegate {
	
	var greenHeroesOfTheStormImage:UIImageView = UIImageView()
	var realHOSImage:UIImageView = UIImageView()
	
	var expansionIconAstroImage:UIImageView = UIImageView()
	
	var informationScrollView:UIScrollView = UIScrollView()
	var scrollViewPageControl:UIPageControl = UIPageControl()
	
	var scrollViewDescriptionLabels:Array<UILabel> = []
	
	var buyButtonUIButton:UIButton = UIButton()
	
	///////////// HOS 뷰 (UIView를 풀로 띄우고 이미지만 animation)
	var heroesUIView:UIView = UIView()
	var heroesFullLogoImage:UIImageView = UIImageView()
	
	var productAvaliable:Bool = false
	var productProcessing:Bool = false
	//////////////////////////////
	var viewPresenting:Bool = false
	
	////////////// HEROES OF THE STORM
	var heroesOfTheStormsSpeed:TimeInterval = 0
	var heroesOfTheStormPassSpeed:TimeInterval = 4
	var hosShowed:Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad( LanguagesManager.$("settingsBuyPremium"), barColor: UPUtils.colorWithHexString("#005454") )
		
		/// 히오스 문양
		// 크기는 디바이스 배율에 맞추지 않음 (x위치 제외
		greenHeroesOfTheStormImage.image = UIImage( named: "modal-buy-heroesofthestorm.png" )
		greenHeroesOfTheStormImage.frame = CGRect(
			x: (DeviceManager.defaultModalSizeRect.width / 2 - (434 * DeviceManager.maxScrRatioC) / 2), y: -64, width: 434 * DeviceManager.maxScrRatioC, height: 434 * DeviceManager.maxScrRatioC
		)
		realHOSImage.image = UIImage( named: "modal-buy-heroes-real.png" )
		realHOSImage.frame = greenHeroesOfTheStormImage.frame
		realHOSImage.alpha = 0
		
		/// 아스트로 그림.
		expansionIconAstroImage.image = UIImage( named: "modal-buy-astro.png" )
		expansionIconAstroImage.frame = CGRect( x: (DeviceManager.defaultModalSizeRect.width / 2 - (130 * DeviceManager.maxScrRatioC) / 2), y: navigationBarHeight + 24 * DeviceManager.maxScrRatioC, width: 130 * DeviceManager.maxScrRatioC, height: 205 * DeviceManager.maxScrRatioC)
		
		modalView.view.addSubview(greenHeroesOfTheStormImage)
		modalView.view.addSubview(realHOSImage)
		modalView.view.addSubview(expansionIconAstroImage)
		
		///////// Buy button
		buyButtonUIButton.frame = CGRect(x: (18 * DeviceManager.maxScrRatioC) , y: DeviceManager.defaultModalSizeRect.height - (64 * DeviceManager.maxScrRatioC) - (18 * DeviceManager.maxScrRatioC), width: DeviceManager.defaultModalSizeRect.width - (36 * DeviceManager.maxScrRatioC), height: 64 * DeviceManager.maxScrRatioC)
		
		//구매 라벨 (가격반영)
		buyButtonUIButton.setTitleColor(UIColor.white, for: .normal)
		buyButtonUIButton.setTitleColor(UPUtils.colorWithHexString("#E9E9E9"), for: .highlighted)
		
		//패드는 창이 커서 폰트크기 늘림.
		if (UIDevice.current.userInterfaceIdiom == .pad) {
			buyButtonUIButton.titleLabel!.font = UIFont.systemFont(ofSize: 16)
		} else {
			buyButtonUIButton.titleLabel!.font = UIFont.systemFont(ofSize: 14)
		}
		
		modalView.view.addSubview(buyButtonUIButton)
		buyButtonUIButton.addTarget(self, action: #selector(self.buyRequestHandler), for: .touchUpInside)
		
		///////// ScrollView
		
		let infoScrollPages:Int = 4
		
		informationScrollView.delegate = self
		informationScrollView.isPagingEnabled = true
		informationScrollView.frame = CGRect(x: 0, y: expansionIconAstroImage.frame.maxY - (48 * DeviceManager.maxScrRatioC), width: DeviceManager.defaultModalSizeRect.width, height: buyButtonUIButton.frame.minY - expansionIconAstroImage.frame.maxY + (48 * DeviceManager.maxScrRatioC))
		informationScrollView.contentSize = CGSize( width: informationScrollView.frame.width * CGFloat(infoScrollPages), height: informationScrollView.frame.height )
		informationScrollView.showsVerticalScrollIndicator = false
		informationScrollView.showsHorizontalScrollIndicator = false
		modalView.view.addSubview(informationScrollView)
		
		scrollViewPageControl.frame = CGRect(x: 0, y: buyButtonUIButton.frame.minY - 8 - 18, width: informationScrollView.frame.width, height: 24)
		modalView.view.addSubview(scrollViewPageControl)
		
		scrollViewPageControl.numberOfPages = infoScrollPages
		scrollViewPageControl.currentPage = 0
		scrollViewPageControl.pageIndicatorTintColor = UIColor.gray
		scrollViewPageControl.currentPageIndicatorTintColor = UPUtils.colorWithHexString("#0FAA81")
		
		
		//////////////// Scroll labels 추가
		for i:Int in 0 ..< infoScrollPages {
			let tmpDesUILabel:UILabel = UILabel()
			
			tmpDesUILabel.textAlignment = .center
			tmpDesUILabel.numberOfLines = 0
			
			if (UIDevice.current.userInterfaceIdiom == .pad) {
				tmpDesUILabel.font = UIFont.systemFont(ofSize: 15)
			} else {
				tmpDesUILabel.font = UIFont.systemFont(ofSize: 14)
			}
			
			tmpDesUILabel.text = LanguagesManager.$("guide-buypack-description-" + String(i))
			
			tmpDesUILabel.frame = CGRect(x: informationScrollView.frame.width * CGFloat(i), y: (28 * DeviceManager.maxScrRatioC), width: informationScrollView.frame.width, height: informationScrollView.frame.height - (28 * DeviceManager.maxScrRatioC))
			informationScrollView.addSubview(tmpDesUILabel)
			
			scrollViewDescriptionLabels.append(tmpDesUILabel)
		} //end for
		
		//TEST
		//informationScrollView.backgroundColor = UIColor.brown
		
		//self.greenHeroesOfTheStormImage.transform = CGAffineTransform(rotationAngle: CGFloat((0 * CGFloat(M_PI) / 180 )))
		
		/// hos view
		heroesUIView.backgroundColor = UIColor.black
		heroesUIView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
		self.view.addSubview(heroesUIView)
		
		
		heroesFullLogoImage.image = UIImage( named: "modal-buy-heroes-full-logo.png" )
		heroesFullLogoImage.frame = CGRect(x: DeviceManager.scrSize!.width / 2 - (120 * DeviceManager.maxScrRatioC), y: DeviceManager.scrSize!.height / 2 - ((112.9/2) * DeviceManager.maxScrRatioC), width: 240 * DeviceManager.maxScrRatioC, height: 112.9 * DeviceManager.maxScrRatioC)
		self.view.addSubview(heroesFullLogoImage)
		
		heroesUIView.isHidden = true
		heroesFullLogoImage.isHidden = true
		
		//////////////////////////
		
		////////// HEROES OF THE STORM
		let tGesture = UITapGestureRecognizer(target:self, action: #selector(self.heroesOfTheStromSpeedyFunction(_:)))
		expansionIconAstroImage.isUserInteractionEnabled = true
		expansionIconAstroImage.addGestureRecognizer(tGesture)
	} ///end init func
	
	///////////////////////
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let pageNumber:Int = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
		scrollViewPageControl.currentPage = pageNumber
	} //end func
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
		//스크롤뷰 위치 리셋
		informationScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
		scrollViewPageControl.currentPage = 0
		
		heroesOfTheStormsSpeed = 0
		realHOSImage.alpha = 0
		heroesUIView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
		heroesFullLogoImage.frame = CGRect(x: DeviceManager.scrSize!.width / 2 - (120 * DeviceManager.maxScrRatioC), y: DeviceManager.scrSize!.height / 2 - ((112.9/2) * DeviceManager.maxScrRatioC), width: 240 * DeviceManager.maxScrRatioC, height: 112.9 * DeviceManager.maxScrRatioC)
		heroesUIView.isHidden = true
		heroesFullLogoImage.isHidden = true
		
		viewPresenting = true
		hosShowed = false
		rotateDecorationImage()
		expProductLoadStart()
	} //end func
	
	override func FitModalLocationToCenter() {
		super.FitModalLocationToCenter()
		
		heroesUIView.frame = CGRect(x: 0, y: 0, width: DeviceManager.scrSize!.width, height: DeviceManager.scrSize!.height)
		heroesFullLogoImage.frame = CGRect(x: DeviceManager.scrSize!.width / 2 - (120 * DeviceManager.maxScrRatioC), y: DeviceManager.scrSize!.height / 2 - ((112.9/2) * DeviceManager.maxScrRatioC), width: 240 * DeviceManager.maxScrRatioC, height: 112.9 * DeviceManager.maxScrRatioC)
	} //end func
	
	override func viewCloseAction() {
		// 로딩 중에는 못 나가게
		if (productProcessing == true) {
			return
		} //end if
		//히오스 중에는 못 나가게
		if (realHOSImage.alpha > 0.6 || heroesFullLogoImage.isHidden == false) {
			return
		} //end if
		
		super.viewCloseAction()
	} //end func
	
	override func viewAppearedCompleteHandler() {
		//Start animate
	} //end func
	
	func expProductLoadStart() {
		//상품정보 불러오는 중 표기
		buyButtonUIButton.backgroundColor = UPUtils.colorWithHexString("#333333")
		//buyButtonUIButton.setTitle( LanguagesManager.$("generalLoading"), for: .normal)
		
		productAvaliable = false
		self.buyButtonUIButton.setTitle( LanguagesManager.$("settingsBuyPremium"), for: .normal)
		
		/*
		if (PurchaseManager.purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] == true) {
			//구매 완료된 상태이면, 그냥 관리문구 띄움
			buyButtonUIButton.backgroundColor = UPUtils.colorWithHexString("#0FAA81")
			buyButtonUIButton.setTitle( LanguagesManager.$("expansionPackManage"), for: .normal)
		} else if (RemoteConfigManager.rConfig![RemoteConfigManager.configs.CanPurchase.rawValue].boolValue != true) {
			//상품 이용 불가능.
			buyButtonUIButton.setTitle( LanguagesManager.$("settingsBuyPremium"), for: .normal)
		} else {
			//RemoteConfig상으론 이용이 가능하니, 상품 정보를 스토어에서 불러와 실제 구매 가능한지 확인
			loadExpansionPackInfo()
		} //end if*/
	} //end func
	
	func loadExpansionPackInfo() {
		SwiftyStoreKit.retrieveProductsInfo([ PurchaseManager.ProductsID.ExpansionPack.rawValue ]) { result in
			if let product = result.retrievedProducts.first {
				//Product loaded. 버튼 활성화 및 가격 표시
				self.productAvaliable = true
				
				self.buyButtonUIButton.backgroundColor = UPUtils.colorWithHexString("#0FAA81")
				self.scrollViewDescriptionLabels[2].text = LanguagesManager.parseStr(LanguagesManager.$("guide-buypack-description-2"), args: product.localizedPrice! as AnyObject)
				//이미 결제 된 상태이면 관리 문구를 띄움
				if (PurchaseManager.purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] == true) {
					//관리하기 문구
					self.buyButtonUIButton.setTitle( LanguagesManager.$("expansionPackManage"), for: .normal)
				} else { //결제 문구
					self.buyButtonUIButton.setTitle( LanguagesManager.parseStr(LanguagesManager.$("expansionPackSubscribe"), args: product.localizedPrice! as AnyObject), for: .normal)
				} //end if
			} else {
				//상품 이용 불가능.
				self.buyButtonUIButton.setTitle( LanguagesManager.$("settingsBuyPremium"), for: .normal)
				
				print("Product info fetch error.")
			} //end if
		} //end completion block
	} //end func
	
	//////////
	func buyRequestHandler() {
		//구매 핸들러
		if (productProcessing == true) {
			return
		} //end if
		
		if (RemoteConfigManager.rConfig![RemoteConfigManager.configs.CanPurchase.rawValue].boolValue != true ||
			(productAvaliable == false && PurchaseManager.purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] != true)) {
			showProductNotAvailable()
		} else {
			//product buy phase
			productProcessing = true
			
			buyButtonUIButton.backgroundColor = UPUtils.colorWithHexString("#333333")
			buyButtonUIButton.setTitle( LanguagesManager.$("generalLoading"), for: .normal)
			
			SwiftyStoreKit.purchaseProduct(PurchaseManager.ProductsID.ExpansionPack.rawValue, atomically: true) { result in
				self.productProcessing = false
				switch result {
					case .success(let product):
						print("Purchase Success: \(product)")
						PurchaseManager.autoVerifyPurchases(callback: self.reloadBuyScreen)
						break
					case .error(let error):
						print("Purchase Failed: \(error)")
						self.expProductLoadStart()
						break
				} //end switch
			} //end purchase
		} //end if
	} //end func
	
	/// 구매 및 verify 완료 후 다시 상품정보를 가져오는 부분
	func reloadBuyScreen(_ verifySucced:Bool? ) {
		expProductLoadStart()
	}
	
	func showProductNotAvailable() {
		let alertWindow:UIAlertController = UIAlertController(title: LanguagesManager.$("generalAlert"), message: LanguagesManager.$("storeBuyNotAvailable"), preferredStyle: UIAlertControllerStyle.alert)
		alertWindow.addAction(UIAlertAction(title: LanguagesManager.$("generalOK"), style: .default, handler: { (action: UIAlertAction!) in
		}))
		present(alertWindow, animated: true, completion: nil)
	} //end function
	
	override func viewDisappearedCompleteHandler() {
		//Stop animate
		self.view.layer.removeAllAnimations()
		viewPresenting = false
	} //end func
	
	///////////////////
	func rotateDecorationImage() {
		if (!viewPresenting) {
			return
		} //cancel animation
		
		///////
		// 사실 여기서 거의다 히오스때문에 쓸데없는 코드가 늘어남 ㅋㅋ
		
		UIView.animateKeyframes(withDuration: 10 - heroesOfTheStormsSpeed, delay: 0, options: UIViewKeyframeAnimationOptions(rawValue: UIViewAnimationOptions.curveLinear.rawValue), animations: {
			self.greenHeroesOfTheStormImage.transform = self.greenHeroesOfTheStormImage.transform.rotated( by: CGFloat(Double.pi) )
			
			//히오스 코드
			self.realHOSImage.transform = self.greenHeroesOfTheStormImage.transform
		}, completion: {_ in
			
			////////////////////////////
			// 히오스 코드
			if (self.heroesOfTheStormsSpeed >= 8 && self.hosShowed == false) {
				//speed 9.5이상일경우 히오스 보여줌
				if (self.realHOSImage.alpha == 0) {
					UIView.animate(withDuration: 3, animations: { self.realHOSImage.alpha = 1 }, completion: {_ in
						self.heroesUIView.isHidden = false
						self.heroesFullLogoImage.isHidden = false
						
						self.heroesFullLogoImage.frame = CGRect(x: DeviceManager.scrSize!.width / 2 - (self.heroesFullLogoImage.frame.width * 2.5), y: DeviceManager.scrSize!.height / 2 - (self.heroesFullLogoImage.frame.height * 2.5), width: self.heroesFullLogoImage.frame.width * 5, height: self.heroesFullLogoImage.frame.height * 5)
						
						UIView.animate(withDuration: 0.32, delay: 0, options: .curveEaseOut, animations: {
							self.heroesFullLogoImage.frame = CGRect(x: DeviceManager.scrSize!.width / 2 - ((240 / 2) * DeviceManager.maxScrRatioC), y: DeviceManager.scrSize!.height / 2 - ((112.9 / 2) * DeviceManager.maxScrRatioC), width: 240 * DeviceManager.maxScrRatioC, height: 112.9 * DeviceManager.maxScrRatioC)
						}, completion: {_ in
							_ = UPUtils.setTimeout(3, block: self.hideHOSFunction)
						})
					}) ///end block
				} //end if
			} else if (self.heroesOfTheStormsSpeed > self.heroesOfTheStormPassSpeed && self.hosShowed == false) {
				//특정속도 이상이면 자동으로 올라감
				self.heroesOfTheStormsSpeed += 1
				
				self.rotateDecorationImage()
			} else {
				/////////////////////////////////////////
				// 아래 함수는 complete시 실행해야 일반 꾸밈 사진도 돌아감
				self.rotateDecorationImage()
			} //end if
			
		}) //end block
	} //end func
	
	// Heroes of the storm
	func heroesOfTheStromSpeedyFunction( _ gst:UIGestureRecognizer ) {
		if (LanguagesManager.currentLocaleCode != LanguagesManager.LanguageCode.Korean) {
			return //한국에서만 통하는 거니까.. 다른 로케일이면 막음
		} //end if
		if (hosShowed == true) {
			return
		} //////////////////////////////////////////////////////
		
		if (self.heroesOfTheStormsSpeed > self.heroesOfTheStormPassSpeed) {
			self.view.layer.removeAllAnimations()
			rotateDecorationImage()
			heroesOfTheStormsSpeed += 1
			return
		} //특정속도 이상이면 더이상 못 올림 (수동으로)
		
		self.view.layer.removeAllAnimations()
		rotateDecorationImage()
		
		heroesOfTheStormsSpeed += 0.5
	} //end func
	
	func hideHOSFunction() {
		hosShowed = true
		realHOSImage.alpha = 0.5
		heroesUIView.isHidden = true
		heroesFullLogoImage.isHidden = true
		
		heroesOfTheStormsSpeed = 0
		
		self.view.layer.removeAllAnimations()
		rotateDecorationImage()
	} //end func
	
	////////////////////////////////
	
} //end class
