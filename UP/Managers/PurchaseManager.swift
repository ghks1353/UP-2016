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
						productId: PurchaseManager.ProductsID.ExpansionPack.rawValue,
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
		} //end verify
	} //end func
	
	//// 구매 항목 복원
	static func restorePurchases( callback:@escaping (( _ result:Bool ) -> Void) ) {
		SwiftyStoreKit.restorePurchases(atomically: true) { results in
			if results.restoreFailedProducts.count > 0 {
				print("Restore Failed: \(results.restoreFailedProducts)")
				callback( false )
				return
			} else if results.restoredProducts.count > 0 {
				print("Restore Success: \(results.restoredProducts)")
			} else {
				print("Nothing to Restore")
			}
			
			autoVerifyPurchases( callback: callback )
		} //end result
	} //end if
	
}
