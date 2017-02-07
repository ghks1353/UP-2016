//
//  BuyExPackView.swift
//  UP
//
//  Created by ExFl on 2017. 2. 7..
//  Copyright © 2017년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class BuyExPackView:UIModalView {
	
	override func viewDidLoad() {
		super.viewDidLoad( LanguagesManager.$("settingsBuyPremium"), barColor: UPUtils.colorWithHexString("#005857") )
	}
	
} //end class
