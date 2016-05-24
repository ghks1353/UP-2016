//
//  UPUtils.swift
//  UP
//
//  Created by ExFl on 2016. 2. 6..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;
import Google;
import CryptoSwift;

class UPUtils {
	
	static func addDays(date: NSDate, additionalDays: Int) -> NSDate {
		// adding $additionalDays
		let components = NSDateComponents()
		components.day = additionalDays
		
		// important: NSCalendarOptions(0)
		let futureDate = NSCalendar.currentCalendar()
			.dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(rawValue: 0))
		return futureDate!
	}
	
	static func colorWithHexString (hex:String) -> UIColor {
		var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
		
		if (cString.hasPrefix("#")) {
			cString = (cString as NSString).substringFromIndex(1)
		}
		
		if (cString.characters.count != 6) {
			return UIColor.grayColor()
		}
		
		let rString = (cString as NSString).substringToIndex(2)
		let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
		let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
		
		var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
		NSScanner(string: rString).scanHexInt(&r)
		NSScanner(string: gString).scanHexInt(&g)
		NSScanner(string: bString).scanHexInt(&b)
		
		
		return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
	}
	
	static func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
		return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
	}
	
	static func setInterval(interval:NSTimeInterval, block:()->Void) -> NSTimer {
		return NSTimer.scheduledTimerWithTimeInterval(interval, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: true)
	}
	
	//Encode sha256.
	static func SHA256(str:String) -> String {
		let plainData:NSData = str.dataUsingEncoding(NSUTF8StringEncoding)!;
		let encryptedData:NSData = plainData.sha256()!;
		
		return encryptedData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0));
	}
	
}