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
	
	internal var segmentID:Int = 0;
	internal var touchFunc: (UISingleSegmentControl)->() = {_ in };
	
	internal func setFrame(x:CGFloat, y:CGFloat) {
		//self.segmen
		self.frame = CGRectMake(x, y, 33, 33);
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.selectedSegmentIndex = self.selectedSegmentIndex == -1 ? 0 : -1;
		//if (touchFunc != nil) {
		touchFunc( self );
		//}
	}
	
}