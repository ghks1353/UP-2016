//
//  UITouchableSegmentControl.swift
//  UP
//
//  Created by ExFl on 2016. 2. 10..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class UITouchableSegmentControl:UISegmentedControl {
	
	internal var touchFunc: (UITouchableSegmentControl)->() = {_ in };
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesEnded(touches, withEvent: event);
		touchFunc( self );
	}
	
}