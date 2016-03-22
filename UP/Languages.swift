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
    }
    
}