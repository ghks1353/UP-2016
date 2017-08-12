//
//  Languages.swift
//  	
//
//  Created by ExFl on 2016. 1. 29..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation

class LanguagesManager {
	
	public enum LanguageCode {
		static let Korean:String = "ko"
		static let English:String = "en"
		static let Japanese:String = "ja"
		static let ChineseSimp:String = "zh"
	}
	
    static let supportedLanguages:Array<String> = [LanguageCode.Korean, LanguageCode.English, LanguageCode.Japanese, LanguageCode.ChineseSimp]
    static var languageJsonFile:NSDictionary?
	
	static var langInited:Bool = false
	static var currentLocaleCode:String = LanguageCode.English
	
	static func initLanugages( _ funcLocaleCode:String, ignoreForceLang:Bool = false ) -> Void {
		var localeCode:String = funcLocaleCode
		if (langInited == true) {
			print("Lang already inited. ignoring")
			return
		} //end if
		
		//init lang.
		if (ignoreForceLang == false) {
			DataManager.initDefaults()
			if (DataManager.nsDefaults.object(forKey: DataManager.settingsKeys.language) == nil) {
				//not force. because there is no key
			} else {
				let forceLang:String = DataManager.nsDefaults.object(forKey: DataManager.settingsKeys.language) as! String
				if (forceLang != "") {
					//apply language FORCE
					print("Applying force language.")
					localeCode = forceLang
				} //end if
			} //end if
		} //end if force
		
		var found:Bool = false
		for i:Int in 0 ..< supportedLanguages.count {
			if (supportedLanguages[i] == localeCode) {
				found = true
				break
			} //end if
		} //end for
		if (found == false) {
			print("Not supporting language.. using english file")
			initLanugages (LanguageCode.English, ignoreForceLang: true)
			return
		} //end if
		
        print("Initing with language", localeCode)
        if let path = Bundle.main.path(forResource: "" + localeCode, ofType: "json") {
            do {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions.mappedIfSafe);
                let jsonResult:NSDictionary = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                languageJsonFile = jsonResult
                print("File loaded")
				
				currentLocaleCode = localeCode
				langInited = true
            } catch {
                print("Json error")
            } //end try catch
        } else {
            print("File not found error. using english file")
            
            initLanugages(LanguageCode.English, ignoreForceLang: true)
        } //end if
    } //end init
	
	//Get language result from json file
    static func $(_ subject:String) -> String {
		if (languageJsonFile == nil) {
			initLanugages( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String )
		}
		var translatedStr:String = ""
		if (languageJsonFile?.object( forKey: subject ) != nil) {
			translatedStr = (languageJsonFile?.object( forKey: subject ))! as! String
		} else {
			print("Cannot find subject",subject);
		 	translatedStr = "ERR:" + subject; //cannot find subject
		} //end if
		
		//Parse escaped new-line moji to unescape
		translatedStr = translatedStr.replacingOccurrences(of: "\\n", with: "\n")
		
        return translatedStr
    } //end func
	
	//Parse special characters to variable
	//Ported from AvoidTap Reborn, AS3
	static func parseStr(_ str:String, args:AnyObject...) -> String {
		if (str == "") {
			return ""
		}
		if (str.characters.contains("$") == false) {
			return str
		}
		if (args.count == 0) {
			return str
		}
		//찾을 문자는 $로 하고, $0부터 시작해서 args의 length만큼 찾는다.
		
		var modifiableString:String = str
		for i:Int in 0 ..< args.count {
			modifiableString = modifiableString.replacingOccurrences(of: "$" + String(i), with: String(describing: args[i]))
		} //end for
		return modifiableString
	} //end func
	
	//Localize month
	static func localizeMonth( _ month:String, inShort:Bool = true ) -> String {
		let months:Int = Int(month)!
		switch(currentLocaleCode) {
			case LanguageCode.Korean, LanguageCode.Japanese:
				return month
			default: break
		} //end switch
		let locPreset:String = inShort ? "statsMonthMin" : "statsMonth"
		switch(months) {
			case 1: return $(locPreset + "January")
			case 2: return $(locPreset + "February")
			case 3: return $(locPreset + "March")
			case 4: return $(locPreset + "April")
			case 5: return $(locPreset + "May")
			case 6: return $(locPreset + "June")
			case 7: return $(locPreset + "July")
			case 8: return $(locPreset + "August")
			case 9: return $(locPreset + "September")
			case 10: return $(locPreset + "October")
			case 11: return $(locPreset + "November")
			case 12: return $(locPreset + "December")
			default: break
		} //end switch
		return month
	} //end func
	
} //end class
