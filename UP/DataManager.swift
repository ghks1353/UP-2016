//
//  DataManager.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation

class DataManager {
    enum settingsKeys {
        static let showBadge:String = "settings_showbadge";
        static let syncToiCloud:String = "settings_synctoicloud";
    }
    
    static var nsDefaults = NSUserDefaults.standardUserDefaults();
	
	static func initDefaults() {
		nsDefaults = NSUserDefaults.standardUserDefaults();
	}
    
}