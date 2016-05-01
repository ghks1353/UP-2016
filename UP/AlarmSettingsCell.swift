//
//  AlarmSettingsCell.swift
//  	
//
//  Created by ExFl on 2016. 2. 1..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class AlarmSettingsCell:UITableDottedCell {
	
	internal var cellID:String = "";
	internal var cellElement:AnyObject?;
	internal var cellSubElement:AnyObject?;
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		//AddAlarmView.selfView!.cellFunc(self.cellID);
		
		super.touchesBegan(touches, withEvent: event);
	}
	
}