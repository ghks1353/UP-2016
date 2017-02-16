//
//  StrArrayFormatter.swift
//  UP
//
//  Created by ExFl on 2016. 10. 24..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation

class StrArrayFormatter:NumberFormatter {
	public var strArr:Array<String> = Array<String>();
	override public func string(from number: NSNumber) -> String? {
		//print("checking number", number, "and count ", strArr.count)
		if (Int(number) < 0) {
			print("Negative number error");
			return "";
		}
		if (Int(number) >= strArr.count) {
			print("StrArrayFormatter outofindex");
			return "";
		}
		return strArr[Int(number)];
	}
}
