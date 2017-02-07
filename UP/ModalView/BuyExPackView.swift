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
	var expansionIconAstroImage:UIImageView = UIImageView()
	
	var informationScrollView:UIScrollView = UIScrollView()
	var buyButtonUIButton:UIButton = UIButton()
	
	var productAvaliable:Bool = false
	var productProcessing:Bool = false
	//////////////////////////////
	var viewPresenting:Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad( LanguagesManager.$("settingsBuyPremium"), barColor: UPUtils.colorWithHexString("#005454") )
		
		/// 히오스 문양
		// 크기는 디바이스 배율에 맞추지 않음 (x위치 제외
		greenHeroesOfTheStormImage.image = UIImage( named: "modal-buy-heroesofthestorm.png" )
		greenHeroesOfTheStormImage.frame = CGRect(
			x: (DeviceManager.defaultModalSizeRect.width / 2 - (434 * DeviceManager.maxScrRatioC) / 2), y: -64, width: 434 * DeviceManager.maxScrRatioC, height: 434 * DeviceManager.maxScrRatioC
		)
		
		/// 아스트로 그림.
		expansionIconAstroImage.image = UIImage( named: "modal-buy-astro.png" )
		expansionIconAstroImage.frame = CGRect( x: (DeviceManager.defaultModalSizeRect.width / 2 - (130 * DeviceManager.maxScrRatioC) / 2), y: navigationBarHeight + 24 * DeviceManager.maxScrRatioC, width: 130 * DeviceManager.maxScrRatioC, height: 205 * DeviceManager.maxScrRatioC)
		
		modalView.view.addSubview(greenHeroesOfTheStormImage)
		modalView.view.addSubview(expansionIconAstroImage)
		
		///////// Buy button
		buyButtonUIButton.frame = CGRect(x: (18 * DeviceManager.maxScrRatioC) , y: DeviceManager.defaultModalSizeRect.height - 50 - (18 * DeviceManager.maxScrRatioC), width: DeviceManager.defaultModalSizeRect.width - (36 * DeviceManager.maxScrRatioC), height: 50)
		
		//구매 라벨 (가격반영)
		buyButtonUIButton.setTitleColor(UIColor.white, for: .normal)
		buyButtonUIButton.setTitleColor(UPUtils.colorWithHexString("#E9E9E9"), for: .highlighted)
		buyButtonUIButton.titleLabel!.font = UIFont.systemFont(ofSize: 15)
		modalView.view.addSubview(buyButtonUIButton)
		buyButtonUIButton.addTarget(self, action: #selector(self.buyRequestHandler), for: .touchUpInside)
		
		///////// ScrollView
		
		let infoScrollPages:Int = 4
		
		informationScrollView.delegate = self
		informationScrollView.isPagingEnabled = true
		informationScrollView.frame = CGRect(x: 0, y: expansionIconAstroImage.frame.maxY, width: self.view.frame.width, height: buyButtonUIButton.frame.minY - expansionIconAstroImage.frame.maxY)
		informationScrollView.contentSize = CGSize( width: self.view.frame.width * CGFloat(infoScrollPages), height: informationScrollView.frame.height )
		informationScrollView.showsVerticalScrollIndicator = false
		informationScrollView.showsHorizontalScrollIndicator = false
		modalView.view.addSubview(informationScrollView)
		
		
		//TEST
		informationScrollView.backgroundColor = UIColor.brown
		
		//self.greenHeroesOfTheStormImage.transform = CGAffineTransform(rotationAngle: CGFloat((0 * CGFloat(M_PI) / 180 )))
	} ///end init func
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
		viewPresenting = true
		rotateDecorationImage()
		expProductLoadStart()
	} //end func
	
	override func viewCloseAction() {
		// 로딩 중에는 못 나가게
		if (productProcessing == true) {
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
		buyButtonUIButton.setTitle( LanguagesManager.$("generalLoading"), for: .normal)
		
		productAvaliable = false
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
		} //end if
	} //end func
	
	func loadExpansionPackInfo() {
		SwiftyStoreKit.retrieveProductsInfo([ PurchaseManager.ProductsID.ExpansionPack.rawValue ]) { result in
			if let product = result.retrievedProducts.first {
				//Product loaded. 버튼 활성화 및 가격 표시
				self.productAvaliable = true
				
				self.buyButtonUIButton.backgroundColor = UPUtils.colorWithHexString("#0FAA81")
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
		
		UIView.animateKeyframes(withDuration: 10, delay: 0, options: UIViewKeyframeAnimationOptions(rawValue: UIViewAnimationOptions.curveLinear.rawValue), animations: {
			self.greenHeroesOfTheStormImage.transform = self.greenHeroesOfTheStormImage.transform.rotated( by: CGFloat(M_PI) )
		}, completion: {_ in
			self.rotateDecorationImage()
		})
	} //end func
	
	
} //end class
