//
//  SkinManager.swift
//  UP
//
//  Created by ExFl on 2016. 3. 30..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;

class SkinManager {
	
	//todo: 스킨같은 경우 통합 관리하도록 했지만 따로 관리할 수 있도록도 수정해야 함.
	//따로 관리 항목: character(astro), background, clock 등
	
	static var skinPresetStr:String = "skin_";
	static var skinSelected:String = "default";
	static var skinList:Array<String> = [
		"default"
	];
	
	static func getAssetPresets() -> String {
		return skinPresetStr + skinSelected + "_";
	}
	static func getDefaultAssetPresets() -> String {
		//Default 고정
		return skinPresetStr + "default" + "_";
	}
	
}