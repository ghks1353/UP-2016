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
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event);
		touchFunc( self );
	}
	
}
