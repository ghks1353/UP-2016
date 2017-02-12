//
//  SkinManager.swift
//  UP
//
//  Created by ExFl on 2016. 3. 30..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ThemeManager {
	
	//todo: 스킨같은 경우 통합 관리하도록 했지만 따로 관리할 수 있도록도 수정해야 함.
	//따로 관리 항목: character(astro), background, clock 등
	
	public enum ThemeGroup {
		case Main
		case StatsSign
		case GameIcon
		case Character
		case DigitalClock
	} //end enum
	
	// Parse할 때 사용할 enum.
	public enum ThemeGroupParseStr:String {
		case Main = "main"
		case StatsSign = "stats"
		case GameIcon = "games"
		case Character = "character"
		case DigitalClock = "digitalclock"
	} //end enum
	
	//// 스킨 표시 시 사용할 String enum (Filename)
	public enum ThemeFileNames {
		/// AnalogClock
		static let AnalogClockBody:String = "time-clock"
		static let AnalogClockCenter:String = "time-center"
		static let AnalogClockHour:String = "time-hour"
		static let AnalogClockMinute:String = "time-minute"
		static let AnalogClockSecond:String = "time-second"
		
		//Object
		static let ObjectSettings:String = "object-settings"
		static let ObjectSettingsShadow:String = "object-settings-shadow"
		static let ObjectList:String = "object-list"
		static let ObjectListShadow:String = "object-list-shadow"
		
		// Background
		static let BackgroundMorning:String = "back-morning"
		static let BackgroundDaytime:String = "back-daytime"
		static let BackgroundSunset:String = "back-sunset"
		static let BackgroundNight:String = "back-night"
		
		// Main character
		static let Character:String = "character"
		
		// DigitalClock (White and Black)
		static let DigitalClock:String = "" //empty (currently)
		static let DigitalClockBlack:String = "black"
		static let DigitalClockCol:String = "col"
		static let DigitalClockAM:String = "am"
		static let DigitalClockPM:String = "pm"
		
		// Ground
		static let GroundMorning:String = "ground-morning"
		static let GroundDaytime:String = "ground-daytime"
		static let GroundSunset:String = "ground-sunset"
		static let GroundNight:String = "ground-night"
		
		// Floating-standing game box
		static let ObjectGameStanding:String = "object-standing"
		static let ObjectGameFloating:String = "object-floating"
		// Statistics sign
		static let ObjectStatistics:String = "object-statistics"
		
	} //end enum
	public enum ThemePresets {
		static let BundlePreset:String = "theme-"
		static let iPhone4S:String = "-4s"
		static let PadPortrait:String = "-pad43"
		static let PadLandscape:String = "-pad34"
	} //end enum
	
	/////////////////////////
	
	//// 스킨이 선택되어있지 않거나 오류가 발생했을 때 기본 스킨.
	static var legacyDefaultTheme:String = "theme-default"
	static var legacyDefaultThemeBundleID:String = "default"
	///// 선택된 스킨 딕셔너리
	static var selectedThemes:[ThemeGroup:String] = [:]
	///// 스킨들 데이터.
	static var themesData:[ThemeGroup:Array<ThemeData>] = [:]
	
	static func initManager() {
		//load theme presets, and init
		
		var jStr:String = ""
		if let Path = Bundle.main.path(forResource: "themes", ofType: "json") {
			do {
				jStr = try NSString(contentsOfFile: Path, usedEncoding: nil) as String
			} catch {
				// contents could not be loaded
			} //end try-catch
		} //end if
		
		///// initalize each themegroup themedata array
		themesData[ThemeGroup.Main] = []
		themesData[ThemeGroup.StatsSign] = []
		themesData[ThemeGroup.GameIcon] = []
		themesData[ThemeGroup.Character] = []
		themesData[ThemeGroup.DigitalClock] = []
		
		///// fetch and parse JSON data
		let jData:JSON = JSON.parse(jStr)
		
		//// Parse it
		for i:Int in 0 ..< jData.arrayValue.count {
			let tmpThemeData:ThemeData = ThemeData()
			tmpThemeData.themeID = jData[i]["id"].string!
			tmpThemeData.themeBundleImageID = jData[i]["bundle-image-id"].string!
			tmpThemeData.themeProductID = jData[i]["product-id"].string!
			
			switch(jData[i]["category"].string!) {
				case ThemeGroupParseStr.Main.rawValue:
					tmpThemeData.themeCategory = ThemeGroup.Main
					break
				case ThemeGroupParseStr.StatsSign.rawValue:
					tmpThemeData.themeCategory = ThemeGroup.StatsSign
					break
				case ThemeGroupParseStr.GameIcon.rawValue:
					tmpThemeData.themeCategory = ThemeGroup.GameIcon
					break
				case ThemeGroupParseStr.Character.rawValue:
					tmpThemeData.themeCategory = ThemeGroup.Character
					break
				case ThemeGroupParseStr.DigitalClock.rawValue:
					tmpThemeData.themeCategory = ThemeGroup.DigitalClock
					break
				default:
					print("Error: ThemeCategory is unknown: ", jData[i]["category"].string!)
					break
			} //end switch
			
			tmpThemeData.themeForceUnlocked = jData[i]["force-unlocked"].bool!
			tmpThemeData.themeHidden = jData[i]["hidden-theme"].bool!
			
			for (key, value):(String, JSON) in jData[i]["name"] {
				tmpThemeData.name[ key ] = value.string!
			} //// end for
			for (key, value):(String, JSON) in jData[i]["description"] {
				tmpThemeData.description[ key ] = value.string!
			} //// end for
			
			//push new data
			themesData[ tmpThemeData.themeCategory ]!.append( tmpThemeData )
		} //end for
		
		//Default setup- skin by default
		selectedThemes[ThemeGroup.Main] = legacyDefaultTheme
		selectedThemes[ThemeGroup.Character] = legacyDefaultTheme
		selectedThemes[ThemeGroup.GameIcon] = legacyDefaultTheme
		selectedThemes[ThemeGroup.StatsSign] = legacyDefaultTheme
		
		/////////////////
		selectedThemes[ThemeGroup.DigitalClock] = legacyDefaultTheme
		
		print("[ThemeManager] inited")
	} //end func
	
	static func getAssetPresets( themeGroup:ThemeGroup, bundleIDOnly:Bool = false ) -> String {
		//return Selected preset
		return getAssetPresets( themeGroup: themeGroup, themeID: selectedThemes[ themeGroup ]!, bundleIDOnly: bundleIDOnly )
	}
	static func getAssetPresets( themeGroup:ThemeGroup, themeID:String, bundleIDOnly:Bool = false ) -> String {
		//// group에서 해당하는 id에 대한 프리셋 값 얻어옴
		for i:Int in 0 ..< themesData[themeGroup]!.count {
			if (themesData[themeGroup]![i].themeID == themeID) {
				return bundleIDOnly ? themesData[themeGroup]![i].themeBundleImageID : ThemePresets.BundlePreset + themesData[themeGroup]![i].themeBundleImageID + "-"
			}
		} //end for
		
		print("[ThemeManager] Error: Can not find themeID", themeID, ": returned legacy theme ID.")
		return bundleIDOnly ? legacyDefaultThemeBundleID : ThemePresets.BundlePreset + legacyDefaultThemeBundleID + "-"
	} //end func
	
	static func getName( _ themeFileName:String ) -> String {
		return themeFileName + ".png"
	} //end func
}
