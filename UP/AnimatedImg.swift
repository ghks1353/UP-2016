//
//  AnimatedImg.swift
//  UP
//
//  Created by ExFl on 2016. 5. 2..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;

class AnimatedImg {
	
	var target:UIView?;
	var movFactor:Float = 1.0; // 몇배만큼 움직일지 결정
	var movMaxFactor:Float = 60.0; //최대 얼마까지 움직일까 결정 (절대값)
	
	var movCurrentFactor:Float = 0;
	var movRdmFactor:Float = 1.0;
	var movReverse:Bool = false;
	
	init( targetView:UIView, defaultMovFactor:Float = 1.0, defaultMovMaxFactor:Float = 60.0, defaultMovRandomFactor:Float = 1.0 ) {
		//initial func
		target = targetView; movFactor = defaultMovFactor; movMaxFactor = defaultMovMaxFactor;
		movRdmFactor = defaultMovRandomFactor;
	}
	
	func movY( factor:Float ) {
		if (self.target == nil) {
			return;
		}
		if (Float(arc4random()) / Float(UINT32_MAX) > movRdmFactor) {
			return; //rdm.
		}
		
		self.target!.frame.origin.y += CGFloat(factor * movFactor) * (movReverse ? 1 : -1);
		movCurrentFactor += factor * movFactor;
		if (movCurrentFactor >= movMaxFactor) {
			movReverse = !movReverse;
			movCurrentFactor = 0;
		} //clear max factor
		
	}
	
}