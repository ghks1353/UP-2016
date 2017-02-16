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
	
	////////// Theme 기존에서 변경
	//// 
	//// Main - 메인 전부 및 캐릭터 포함
	//// DigitalClock - 시계
	//// Background - 배경
	
	//// 테마 정보는 기본적으로 Main 카테고리 포함.
	//// Additional Category에서 추가적으로 같이 적용되는 카테고리로 적용됨.
	
	public enum ThemeGroup {
		case Default
		case DigitalClock
		case Background
	} //end enum
	
	// Parse할 때 혹은 bundle에서 찾을 때 사용할 enum.
	public enum ThemeGroupParseStr:String {
		case Default = "default"
		case DigitalClock = "digitalclock"
		case Background = "background"
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
		
		// Ground
		static let GroundMorning:String = "ground-morning"
		static let GroundDaytime:String = "ground-daytime"
		static let GroundSunset:String = "ground-sunset"
		static let GroundNight:String = "ground-night"
		
		//Time list background
		static let BackgroundAlarmMorning:String = "list-back-morning"
		static let BackgroundAlarmDaytime:String = "list-back-daytime"
		static let BackgroundAlarmSunset:String = "list-back-sunset"
		static let BackgroundAlarmNight:String = "list-back-night"
		
		// Main character
		static let Character:String = "character"
		
		// DigitalClock (White and Black)
		static let DigitalClock:String = "digital"
		static let DigitalClockBlack:String = "digital-black"
		static let DigitalClockCol:String = "col"
		static let DigitalClockAM:String = "am"
		static let DigitalClockPM:String = "pm"
		
		// Floating-standing game box
		static let ObjectGameStanding:String = "object-standing"
		static let ObjectGameFloating:String = "object-floating"
		// Statistics sign
		static let ObjectStatistics:String = "object-statistics"
		
		//Skin-select thumbnail
		static let Thumbnails:String = "thumbnails"
		
	} //end enum
	public enum ThemePresets {
		static let BundlePreset:String = "theme-"
		
		static let iPhone4S:String = "-4s"
		static let iPad:String = "-ipad"
		static let PadPortrait:String = "-pad43"
		static let PadLandscape:String = "-pad34"
		
		static let LDPI:String = "-ldpi"
		static let On:String = "-on"
		static let Off:String = "-off"
		
		static let Game:String = "-games"
		static let GameStrOnly:String = "games"
	} //end enum
	public enum ThemeGameNames {
		static let JumpUP:String = "jumpup"
	}
	public enum ThemeGamePresets {
		static let Jump:String = "-jump"
		static let Move:String = "-move"
	}
	
	/////////////////////////
	
	//// 스킨이 선택되어있지 않거나 오류가 발생했을 때 기본 스킨.
	static var legacyDefaultTheme:String = "theme-default"
	static var legacyDefaultThemeBundleID:String = "default"
	///// 선택된 스킨 딕셔너리
	static var selectedThemeID:[ThemeGroup:String] = [:]
	///// 스킨들 데이터.
	static var themesData:Array<ThemeData> = []
	
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
		
		///// fetch and parse JSON data
		let jData:JSON = JSON.parse(jStr)
		
		//// Parse it
		for i:Int in 0 ..< jData.arrayValue.count {
			let tmpThemeData:ThemeData = ThemeData()
			tmpThemeData.themeID = jData[i]["id"].string!
			tmpThemeData.themeBundleImageID = jData[i]["bundle-image-id"].string!
			tmpThemeData.themeProductID = jData[i]["product-id"].string!
			
			/////// Array for additional-category supported
			let tAdditionalArr:[String] = jData[i]["additional"].arrayValue.map { $0.string! }
			for j:Int in 0 ..< tAdditionalArr.count {
				switch(tAdditionalArr[j]) {
					case ThemeGroupParseStr.DigitalClock.rawValue:
						tmpThemeData.additionalThemes.append( ThemeGroup.DigitalClock )
						break
					case ThemeGroupParseStr.Background.rawValue:
						tmpThemeData.additionalThemes.append( ThemeGroup.Background )
						break
					default:
						print("Error: ThemeCategory is unknown: ", tAdditionalArr[j])
						break
				} //end switch
			} //end for
			
			tmpThemeData.themeForceUnlocked = jData[i]["force-unlocked"].bool!
			tmpThemeData.themeHidden = jData[i]["hidden-theme"].bool!
			
			for (key, value):(String, JSON) in jData[i]["name"] {
				tmpThemeData.name[ key ] = value.string!
			} //// end for
			for (key, value):(String, JSON) in jData[i]["description"] {
				tmpThemeData.description[ key ] = value.string!
			} //// end for
			
			//push new data
			themesData.append( tmpThemeData )
		} //end for
		
		//Default setup- skin by default
		selectedThemeID[ThemeGroup.Default] = legacyDefaultTheme
		selectedThemeID[ThemeGroup.DigitalClock] = legacyDefaultTheme
		selectedThemeID[ThemeGroup.Background] = legacyDefaultTheme
		
		print("[ThemeManager] inited")
	} //end func
	
	static func getAssetPresets( themeGroup:ThemeGroup, bundleIDOnly:Bool = false ) -> String {
		//return Selected preset
		return getAssetPresets( themeGroup: themeGroup, themeID: selectedThemeID[ themeGroup ]!, bundleIDOnly: bundleIDOnly )
	}
	static func getAssetPresets( themeGroup:ThemeGroup, themeID:String, bundleIDOnly:Bool = false ) -> String {
		//// group에서 해당하는 id에 대한 프리셋 값 얻어옴
		for i:Int in 0 ..< themesData.count {
			if (themesData[i].themeID == themeID) {
				
				return bundleIDOnly ? themesData[i].themeBundleImageID : ThemePresets.BundlePreset + themesData[i].themeBundleImageID + "-"
			}
		} //end for
		
		print("[ThemeManager] Error: Can not find themeID", themeID, ": returned legacy theme ID.")
		return bundleIDOnly ? legacyDefaultThemeBundleID : ThemePresets.BundlePreset + legacyDefaultThemeBundleID + "-"
	} //end func
	static func getAssetPresets( gameName:String, themeTarget:String, gamePreset:String, index:Int = -1 ) -> String {
		//index가 있을 경우, -1 -2 -3 ..같이 번호를 부여해줌
		//이 함수는 .png확장자까지 같이 반환함
		let indexPreset:String = index == -1 ? "" : "-" + String(index)
		
		return ThemePresets.BundlePreset + ThemePresets.GameStrOnly + "-" + gameName + "-" + themeTarget + "-" + getThemeInformation(selectedThemeID[ThemeGroup.Default]!)!.themeBundleImageID + gamePreset + indexPreset + ".png"
		
	} //end func
	
	static func getThemeInformation(_ themeID:String ) -> ThemeData? {
		for i:Int in 0 ..< themesData.count {
			if (themesData[i].themeID == themeID) {
				return themesData[i]
			}
		}
		return nil
	}
	
	static func getGroupStr(_ themeGroup:ThemeGroup ) -> String {
		switch(themeGroup) {
			case .Default:
				return ThemeGroupParseStr.Default.rawValue
			case .DigitalClock:
				return ThemeGroupParseStr.DigitalClock.rawValue
			case .Background:
				return ThemeGroupParseStr.Background.rawValue
		} //end switch
	} //end func
	
	static func getName( _ themeFileName:String ) -> String {
		return themeFileName + ".png"
	} //end func
}
