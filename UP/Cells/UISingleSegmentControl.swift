//
//  UISingleSegmentControl.swift
//  UP
//
//  Created by ExFl on 2016. 2. 9..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class UISingleSegmentControl:UISegmentedControl {
	
	internal var segmentID:Int = 0
	internal var touchFunc: (UISingleSegmentControl)->() = {_ in }
	
	internal func setFrame(_ x:CGFloat, y:CGFloat) {
		//self.segmen
		self.frame = CGRect(x: x, y: y, width: 33, height: 33)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.selectedSegmentIndex = self.selectedSegmentIndex == -1 ? 0 : -1
		//if (touchFunc != nil) {
		touchFunc( self )
		//}
	}
	
}
