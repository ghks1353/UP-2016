//
//  SkinManager.swift
//  UP
//
//  Created by ExFl on 2016. 3. 30..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class SkinManager {
	
	//todo: 스킨같은 경우 통합 관리하도록 했지만 따로 관리할 수 있도록도 수정해야 함.
	//따로 관리 항목: character(astro), background, clock 등
	
	static var selectedSkin_Menus:String = "default"
	static var selectedSkin_Statistics:String = "default"
	static var selectedSkin_Play:String = "default"
	static var selectedSkin_Character:String = "default"
	
	//스킨 접두어.
	static var skinPresetStr:String = "skin-"
	
	// 시스템 스킨 종류 일람 /////
	static var skins_Menus:Array<String> = [
		"default"
	];
	static var skins_Statistics:Array<String> = [
		"default"
	];
	static var skins_Play:Array<String> = [
		"default"
	];
	static var skins_Character:Array<String> = [
		"default"
	]; /////////////////////
	
	static func getAssetPresetsMenus() -> String { //현재 선택된 메인 스킨에 대한 경로
		return skinPresetStr + selectedSkin_Menus + "-"
	}
	static func getAssetPresetsStatistics() -> String { //통계 스킨
		return skinPresetStr + selectedSkin_Statistics + "-"
	}
	static func getAssetPresetsPlay() -> String { //게임하기 스킨
		return skinPresetStr + selectedSkin_Play + "-"
	}
	static func getAssetPresetsCharacter() -> String { //캐릭터 스킨
		return skinPresetStr + selectedSkin_Character + "-"
	}
	
	//스킨명만 얻기
	static func getSelectedSkinCharacter() -> String {
		return selectedSkin_Character
	}
	
	static func getDefaultAssetPresets() -> String { //기본 스킨 디렉터리에서 불러와서 쓰는 것들만 해당
		//Default 고정
		return skinPresetStr + "default" + "-"
	}
	
}
