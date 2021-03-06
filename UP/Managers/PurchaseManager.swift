//
//  PurchaseManager.swift
//  UP
//
//  Created by ExFl on 2016. 7. 12..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import SwiftyStoreKit

class PurchaseManager {
	
	public enum ProductsID:String {
		case ExpansionPack = "up.premium_feature"
	}
	
	//Purchased 항목 Key-Value Dictionary
	static var purchasedItems:[String:Bool] = [:]
	
	static var localReceipts:Data!
	static let purchaseSharedSecret:String = "86e4dd4d3cdb4e13a5fb31eae24e94e5"
	
	static var pValidator:AppleReceiptValidator?
	static var isInited:Bool = false
	
	//Callback
	//static var restoreCallbackFunc:(() -> Void)? = nil
	
	static func initManager() {
		//complete transcations
		completeTranscations()
		
		//Validator type set
		#if DEBUG
			pValidator = AppleReceiptValidator(service: .sandbox)
		#else
			pValidator = AppleReceiptValidator(service: .production)
		#endif
		
		localReceipts = SwiftyStoreKit.localReceiptData
		autoVerifyPurchases()
		
		isInited = true
	}
	
	//트랜지션 완료함수
	static func completeTranscations() {
		SwiftyStoreKit.completeTransactions(atomically: true) { products in
			for product in products {
				if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
					if product.needsFinishTransaction {
						// Deliver content from server, then:
						SwiftyStoreKit.finishTransaction(product.transaction)
					}
					print("Product transcation finished: \(product)")
				}
			}
		}
		
	} //end func
	
	//자동 결제된 항목 체크 함수 (필요한 것들만)
	static func autoVerifyPurchases( callback:((_ result:Bool ) -> Void)? = nil ) {
		if (!isInited) {
			return
		}
		
		print("[PurchaseManager] Product verify ongoing")
		
		//Verify UP Ext pack subscription
		SwiftyStoreKit.verifyReceipt(using: pValidator!, password: purchaseSharedSecret) { result in
			switch result {
				case .success(let receipt):
					let purchaseResult = SwiftyStoreKit.verifySubscription(
						type: SubscriptionType.autoRenewable, productId: PurchaseManager.ProductsID.ExpansionPack.rawValue,
						inReceipt: receipt, validUntil: Date()
					) //Verify done
					switch purchaseResult {
						case .purchased:
							purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] = true
						case .expired(let expiresDate):
							//Product expired (requires renew!)
							print("Product expired: date: ", expiresDate)
							purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] = false
						case .notPurchased:
							purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] = false
					} //end switch
					
				case .error(let error):
					print("Product val error:", error)
					purchasedItems[PurchaseManager.ProductsID.ExpansionPack.rawValue] = false
			}
			if (callback != nil) {
				callback!( true )
			}
			
			updateVisibleComponents()
		} //end verify
	} //end func
	
	//// 구매 항목 복원
	static func restorePurchases( callback:@escaping (( _ result:Bool ) -> Void) ) {
		SwiftyStoreKit.restorePurchases(atomically: true) { results in
			if results.restoreFailedPurchases.count > 0 {
				print("Restore Failed: \(results.restoreFailedPurchases)")
				callback( false )
				return
			} else if results.restoredPurchases.count > 0 {
				print("Restore Success: \(results.restoredPurchases)")
			} else {
				print("Nothing to Restore")
			}
			
			autoVerifyPurchases( callback: callback )
		} //end result
	} //end if
	
	////////
	//보이는 컴포넌트를 구매 여부에 따라 표시/숨김할 수 있도록 도와주는 함수.
	//auto verify 이후에 call됨
	static func updateVisibleComponents() {
		
		//메인 화면 업데이트
		if (ViewController.selfView != nil) {
			ViewController.selfView!.updatePurchaseStates()
		}
	} //end func
	
}
