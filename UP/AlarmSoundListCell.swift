//
//  AlarmSoundListCell.swift
//  UP
//
//  Created by ExFl on 2016. 2. 8..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class AlarmSoundListCell:UITableViewCell {
	
	internal var cellID:String = "";
	internal var soundInfoObject:SoundInfoObj?;
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		//AlarmSoundListView.selfView!.cellFunc(self.soundInfoObject!);
		super.touchesBegan(touches, withEvent: event);
	}
	
}