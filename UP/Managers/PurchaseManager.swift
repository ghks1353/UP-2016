//
//  PurchaseManager.swift
//  UP
//
//  Created by ExFl on 2016. 7. 12..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import StoreKit;

class PurchaseManager:NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
	
	static var instance:PurchaseManager?;
	static var isInited:Bool = false;
	
	//Callback
	static var callbackFunc:((SKPaymentTransactionState) -> Void)? = nil;
	
	enum productIDs {
		static let PREMIUM:String = "unlock_features";
	}
	
	var productsArray:Array<SKProduct>?;
	
	//상품 ID배열
	var productIDsArray:Array<String> = [];
	
	
	static func initInstance() { //Protocol을 static쪽에 물리기가 힘들어서, 인스턴스로 만들고 static 비슷하게 사용함
		PurchaseManager.instance = PurchaseManager();
	}
	
	//인스턴스 init
	override init() {
		super.init();
		initManager();
	}
	
	//상품 정보 받아오기
	func initManager() {
		if (PurchaseManager.isInited) {
			return;
		}
		print("PurchaseManager init started");
		
		//상품 ID 넣기
		productIDsArray += [ PurchaseManager.productIDs.PREMIUM ]; //정식버전
		
		SKPaymentQueue.default().add(self);
		//SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
		if (SKPaymentQueue.canMakePayments()) {
			//결제 가능한 상태에서만 정보 요청
			let pRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: Set( productIDsArray ));
			pRequest.delegate = self; pRequest.start();
			
		} else {
			print("IAP not available!");
		}
		
	}
	
	@objc func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		productsArray = response.products;
		if (productsArray!.count <= 0) {
			print("Products not found");
			return;
		}
		PurchaseManager.isInited = true;
		
		for i:Int in 0 ..< productsArray!.count {
			print("-------------Prod " + String(i));
			print("NAME: " + productsArray![i].localizedTitle );
			print("PRICE: " + String(describing: productsArray![i].price) );
			print("LPRICE: " + String(productsArray![i].localizedPrice()) );
			
		}
		//response.products[0].
	}
	
	@objc func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("Receiving payment trans");
		for trans:AnyObject in transactions {
			if let t:SKPaymentTransaction = trans as? SKPaymentTransaction {
				//Valid transcation
				print("ID:",t.payment.productIdentifier, t.transactionDate);
				switch (t.transactionState) {
					case .purchasing: //Purchasing status
						print("Purchase: ongoing");
						
						break;
					case .purchased: //Purchase done / purchased
						print(t.transactionIdentifier, "=> Purchase: OK");
						
						SKPaymentQueue.default().finishTransaction(t);
						break;
					case .restored: //Restored item
						print(t.transactionIdentifier, "=> Purchase: restored");
						
						SKPaymentQueue.default().finishTransaction(t);
						break;
					case .failed: //Purchase (pay) failed
						print(t.transactionIdentifier, "=> Purchase: failed");
						
						SKPaymentQueue.default().finishTransaction(t);
						break;
					default:
						print(t.transactionIdentifier, "=> Trans unknown state");
						break;
				} //end switch states
				if (PurchaseManager.callbackFunc != nil) {
					PurchaseManager.callbackFunc!(t.transactionState);
				}
			} //end if
		} //end for
		
		PurchaseManager.callbackFunc = nil;
	}
	
	///////////// static functions
	static func checkIsAvailableProduct( _ productID:String ) -> Bool {
		/////////// TEST
		//ALWAYS RETURN FALSE. 20160917 for BETA 0.0.3
		return false;
		
		if (PurchaseManager.isInited == false) {
			return false;
		}
		if (PurchaseManager.instance == nil) {
			return false; //not inited
		}
		
		for i:Int in 0 ..< PurchaseManager.instance!.productsArray!.count {
			if (PurchaseManager.instance!.productsArray![i].productIdentifier == productID) {
				return true; //found
			}
		}
		
		return false; //not found
	}
	static func getProductObjectWithID( _ productID:String ) -> SKProduct? {
		for i:Int in 0 ..< PurchaseManager.instance!.productsArray!.count {
			if (PurchaseManager.instance!.productsArray![i].productIdentifier == productID) {
				return PurchaseManager.instance!.productsArray![i]; //found
			}
		}
		
		return nil; //not found
	}
	
	/// 상품이 사용 가능한 상태인지 체크한 후 진행
	static func requestBuyProduct( _ productID:String ) -> Bool {
		let prod:SKProduct? = getProductObjectWithID( productID );
		if (prod == nil) {
			return false;
		}
		
		let payment:SKPayment = SKPayment(product: prod!);
		SKPaymentQueue.default().add(payment); //request payment
		
		return true;
	}
	
	////// 상품 복원 / 복구
	static func requestRestoreProducts( _ callback:((SKPaymentTransactionState) -> Void)? = nil ) -> Bool {
		if (PurchaseManager.isInited == false) {
			return false;
		}
		if (PurchaseManager.instance == nil) {
			return false; //not inited
		}
		
		PurchaseManager.callbackFunc = callback;
		
		SKPaymentQueue.default().restoreCompletedTransactions();
		
		return true;
	}
	
	
	
	
}
