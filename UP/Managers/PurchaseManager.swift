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
		
		SKPaymentQueue.defaultQueue().addTransactionObserver(self);
		
		if (SKPaymentQueue.canMakePayments()) {
			//결제 가능한 상태에서만 정보 요청
			let pRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: Set( productIDsArray ));
			pRequest.delegate = self; pRequest.start();
			
		} else {
			print("IAP not available!");
		}
		
	}
	
	@objc func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		productsArray = response.products;
		if (productsArray!.count <= 0) {
			print("Products not found");
			return;
		}
		PurchaseManager.isInited = true;
		
		for i:Int in 0 ..< productsArray!.count {
			print("-------------Prod " + String(i));
			print("NAME: " + productsArray![i].localizedTitle );
			print("PRICE: " + String(productsArray![i].price) );
			print("LPRICE: " + String(productsArray![i].localizedPrice()) );
			
		}
		//response.products[0].
	}
	
	@objc func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("Receiving payment trans");
		for trans:AnyObject in transactions {
			if let t:SKPaymentTransaction = trans as? SKPaymentTransaction {
				//Valid transcation
				switch (t.transactionState) {
					case .Purchasing: //Purchasing status
						
						break;
					case .Purchased: //Purchase done / purchased
						
						break;
					case .Restored: //Restored item
						
						break;
					case .Failed: //Purchase (pay) failed
						
						break;
					default:
						print("Trans unknown state");
						break;
				} //end switch states
				
			} //end if
		} //end for
		
		
	}
	
	///////////// static functions
	static func checkIsAvailableProduct( productID:String ) -> Bool {
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
	
	static func buyProduct() {
		
	}
	
	
	
	
}