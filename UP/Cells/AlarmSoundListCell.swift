//
//  AlarmSoundListCell.swift
//  UP
//
//  Created by ExFl on 2016. 2. 8..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class AlarmSoundListCell:UITableDottedCell {
	
	var cellID:String = ""
	var soundInfoObject:SoundData?
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		//AlarmSoundListView.selfView!.cellFunc(self.soundInfoObject!);
		super.touchesBegan(touches, with: event)
	}
	
}
