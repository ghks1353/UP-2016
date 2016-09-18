//
//  SKProductExtension.swift
//  UP
//
//  Created by ExFl on 2016. 7. 14..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import StoreKit;

extension SKProduct {
	
	func localizedPrice() -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = self.priceLocale
		return formatter.string(from: self.price)!
	}
	
}
