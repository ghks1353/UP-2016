//
//  AlarmListCell.swift
//  UP
//
//  Created by ExFl on 2016. 2. 10..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class AlarmListCell:UITableViewCell {
	
	internal var alarmID:Int = 0;
	
	internal var backgroundImage:UIImageView?;
	internal var timeText:UILabel?;
	internal var alarmName:UILabel?;
	
	internal var timeHour:Int = 0;
	internal var timeMinute:Int = 0;
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		//AddAlarmView.selfView!.cellFunc(self.cellID);
		
		//super.touchesBegan(touches, withEvent: event);
	}
	
}