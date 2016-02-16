//
//  Languages.swift
//  	
//
//  Created by ExFl on 2016. 1. 29..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation

class Languages {
    
    static let supportedLanguages:Array<String> = ["ko"];
    static var languageJsonFile:NSDictionary?;
    
    static func initLanugages( localeCode:String ) -> Void {
		
		var found:Bool = false;
		for (var i:Int = 0; i < supportedLanguages.count; ++i) {
			if (supportedLanguages[i] == localeCode) {
				found = true; break;
			}
		}
		if (found == false) {
			print("Not supporting language.. using english file");
			initLanugages ("ko"); //영어파일이 준비되는대로 대치.
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
            
            initLanugages ("ko"); //영어파일이 준비되는대로 대치.
        }
        
    } //end init
    
    static func $(subject:String) -> String {
		if (languageJsonFile == nil) {
			initLanugages( NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as! String );
		}
		let translatedStr:String = (languageJsonFile?.objectForKey( subject ))! as! String;
		
        return translatedStr;
    }
    
}