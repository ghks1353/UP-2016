//
//  AlarmSettingsCell.swift
//  	
//
//  Created by ExFl on 2016. 2. 1..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class AlarmSettingsCell:UITableViewCell {
	
	internal var cellID:String = "";
	internal var cellElement:AnyObject?;
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		AddAlarmView.selfView!.cellFunc(self.cellID);
		/*switch(self.cellID) {
			
			default:
				break;
		}
		
		print(self.cellID);*/
	}
	
}