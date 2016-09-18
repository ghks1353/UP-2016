//
//  UnityAdsManager.swift
//  UP
//
//  Created by ExFl on 2016. 7. 25..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UnityAds;

class UnityAdsManager:NSObject, UnityAdsDelegate {
	
	static let IS_TEST_MODE:Bool = true;
	static let PLACEMENT_SKIPABLE:String = "video";
	static let PLACEMENT_GAMECONTINUE:String = "gameContinueAD";
	
	static var instance:UnityAdsManager?;
	static var callbackFunc:(() -> Void)? = nil;
	
	static func initManager() {
		instance = UnityAdsManager();
		instance!.initInstance();
	}
	
	static func showUnityAD( _ viewController:UIViewController, placementID:String, callbackFunction:@escaping (() -> Void) ) {
		if (UnityAds.isReady(placementID) == true) {
			UnityAds.show(viewController, placementId: placementID);
			callbackFunc = callbackFunction;
		} else {
			print("UnityAds " + placementID + " not ready");
		}
	}
	
	///////////////// instance functions
	func initInstance() {
		print("UnityADs init...");
		UnityAds.initialize("1085659", delegate: self, testMode: UnityAdsManager.IS_TEST_MODE);
	}
	
	@objc func unityAdsReady(_ placementId: String) {
		print("UnityAds is READY");
		
	}
	@objc func unityAdsDidStart(_ placementId: String) {
		print("UnityAds started");
		
	}
	@objc func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
		print("UnityAds error with message: " + message);
		
		
		
	}
	@objc func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
		print("UnityAds finished advertising: " + placementId);
		
		switch(placementId) {
			case UnityAdsManager.PLACEMENT_GAMECONTINUE:
				//게임 이어하기 기능으로 컨티뉴하는 겨웅
				
				break;
			case UnityAdsManager.PLACEMENT_SKIPABLE:
				//스킵 가능 광고. 예: 알람 후
				
				break;
			default: break;
		}
		
		//Run callback
		if (UnityAdsManager.callbackFunc != nil) {
			UnityAdsManager.callbackFunc!();
			UnityAdsManager.callbackFunc = nil;
		}
	}
	
	
	
}
