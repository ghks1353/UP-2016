//
//  RemoteConfigManager.swift
//  UP
//
//  Created by ExFl on 2017. 2. 1..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import Firebase

class RemoteConfigManager {
	
	static var rConfig:RemoteConfig? = nil
	static var rDeveloperMode:Bool = false
	static var rExpDuration:TimeInterval = 3600 * 2;
	
	public enum configs:String {
		case CanPurchase = "can_purchase";
	}
	
	/* default values */
	static let rDefaultValues:[String: NSObject] = [
		RemoteConfigManager.configs.CanPurchase.rawValue: false as NSObject
	]
	
	static func initManager() {
		rConfig = RemoteConfig.remoteConfig()
		#if DEBUG
			rDeveloperMode = true
			rExpDuration = 0
		#endif
		rConfig!.configSettings = RemoteConfigSettings(developerModeEnabled: rDeveloperMode)!
		rConfig!.setDefaults(rDefaultValues)
		
		rConfig!.fetch(withExpirationDuration: rExpDuration) { (status, error) -> Void in
			if status == .success {
				print("[FIRConfig] Config successfully fetched and activated")
				self.rConfig!.activateFetched()
			} else {
				print("[FIRConfig] Config fetch error: \(error!.localizedDescription)")
			} //end if
		} //end fetch
		
	} //end func
	
}
