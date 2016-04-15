//
//  Languages.swift
//  	
//
//  Created by ExFl on 2016. 1. 29..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation

class Languages {
    
    static let supportedLanguages:Array<String> = ["ko", "en", "ja"];
    static var languageJsonFile:NSDictionary?;
    
    static func initLanugages( localeCode:String ) -> Void {
		
		var found:Bool = false;
		for i:Int in 0 ..< supportedLanguages.count {
			if (supportedLanguages[i] == localeCode) {
				found = true; break;
			}
		}
		if (found == false) {
			print("Not supporting language.. using english file");
			initLanugages ("en");
			return;
		}
		
        print("Initing with language", localeCode);
        if let path = NSBundle.mainBundle().pathForResource("" + localeCode, ofType: "json") {
            
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe);
                let jsonResult:NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary;
                languageJsonFile = jsonResult;
                print("File loaded");
            } catch {
                print("Json error");
            }
            
        } else {
            print("File not found error. using english file");
            
            initLanugages ("en");
        }
        
    } //end init
	
	//Get language result from json file
    static func $(subject:String) -> String {
		if (languageJsonFile == nil) {
			initLanugages( NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String );
		}
		var translatedStr:String = "";
		if (languageJsonFile?.objectForKey( subject ) != nil) {
			translatedStr = (languageJsonFile?.objectForKey( subject ))! as! String;
		} else {
			print("Cannot find subject",subject);
		 	translatedStr = "ERR:" + subject; //cannot find subject
		}
        return translatedStr;
    } //end func
	
	//Parse special characters to variable
	//Ported from AvoidTap Reborn, AS3
	static func parseStr(str:String, args:AnyObject...) -> String {
		if (str == "") {
			return "";
		}
		if (str.characters.contains("$") == false) {
			return str;
		}
		if (args.count == 0) {
			return str;
		}
		//찾을 문자는 $로 하고, $0부터 시작해서 args의 length만큼 찾는다.
		
		var modifiableString:String = str;
		for i:Int in 0 ..< args.count {
			modifiableString = modifiableString.stringByReplacingOccurrencesOfString("$" + String(i), withString: String(args[i]));
		}
		return modifiableString;
	} //end func
	
	
}