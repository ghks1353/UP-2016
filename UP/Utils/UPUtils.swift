//
//  UPUtils.swift
//  UP
//
//  Created by ExFl on 2016. 2. 6..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;
import Google;
import CryptoSwift;

class UPUtils {
	
	static func addDays(_ date: Date, additionalDays: Int) -> Date {
		// adding $additionalDays
		var components = DateComponents()
		components.day = additionalDays
		
		// important: NSCalendarOptions(0)
		let futureDate = (Calendar.current as NSCalendar)
			.date(byAdding: components, to: date, options: NSCalendar.Options(rawValue: 0))
		return futureDate!
	}
	
	static func colorWithHexString (_ hex:String) -> UIColor {
		var cString:String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString = (cString as NSString).substring(from: 1)
		}
		
		if (cString.characters.count != 6) {
			return UIColor.gray
		}
		
		let rString = (cString as NSString).substring(to: 2)
		let gString = ((cString as NSString).substring(from: 2) as NSString).substring(to: 2)
		let bString = ((cString as NSString).substring(from: 4) as NSString).substring(to: 2)
		
		var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
		Scanner(string: rString).scanHexInt32(&r)
		Scanner(string: gString).scanHexInt32(&g)
		Scanner(string: bString).scanHexInt32(&b)
		
		
		return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
	}
	
	static func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
		return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
	}
	
	static func setInterval(_ interval:TimeInterval, block:@escaping ()->Void) -> Timer {
		return Timer.scheduledTimer(timeInterval: interval, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: true)
	}
	
	//Encode sha256.
	static func SHA256(_ str:String) -> String {
		let plainData:Data = str.data(using: String.Encoding.utf8)!;
		let encryptedData:Data = plainData.sha256();
		
		return encryptedData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0));
	}
	
}
