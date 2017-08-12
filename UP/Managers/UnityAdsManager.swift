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
	
	static var unityAdsTestMode:Bool = true
	
	public enum PlacementAds:String {
		case alarmFinishAD = "alarmFinishVideo"
		case gameContinueAD = "gameContinueAD"
		case alarmADsOff = "alarmADsOff"
		case donateManuallyAD = "donateManuallyAD"
	}
	
	static var instance:UnityAdsManager?
	static var callbackFunc:(() -> Void)? = nil
	
	static func initManager() {
		instance = UnityAdsManager()
		instance!.initInstance()
	}
	
	static func showUnityAD( _ viewController:UIViewController, placementID:String, callbackFunction:@escaping (() -> Void), showFailCallbackFunction:@escaping(() -> Void) ) {
		#if DEBUG
			unityAdsTestMode = true
		#else
			unityAdsTestMode = false
		#endif
		
		if (UnityAds.isReady(placementID) == true) {
			UnityAds.show(viewController, placementId: placementID)
			callbackFunc = callbackFunction
		} else {
			//UnityAd Show failed
			showFailCallbackFunction()
			
			print("UnityAds " + placementID + " not ready")
		}
	}
	
	///////////////// instance functions
	func initInstance() {
		print("UnityADs init...")
		UnityAds.initialize("1085659", delegate: self, testMode: UnityAdsManager.unityAdsTestMode)
	}
	
	@objc func unityAdsReady(_ placementId: String) {
		print("UnityAds is READY")
		
	}
	@objc func unityAdsDidStart(_ placementId: String) {
		print("UnityAds started")
		
	}
	@objc func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
		print("UnityAds error with message: " + message)
		
		
		
	}
	@objc func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
		print("UnityAds finished advertising: " + placementId)
		/*
		switch(placementId) {
			case UnityAdsManager.PLACEMENT_GAMECONTINUE:
				//게임 이어하기 기능으로 컨티뉴하는 겨웅
				
				break;
			case UnityAdsManager.PLACEMENT_SKIPABLE:
				//스킵 가능 광고. 예: 알람 후
				
				break;
			default: break;
		}
		*/
		
		//Run callback
		UnityAdsManager.callbackFunc?()
		UnityAdsManager.callbackFunc = nil
	} // end func
	
	
	
}
