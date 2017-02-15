//
//  UPGamesListCell.swift
//  UP
//
//  Created by ExFl on 2016. 2. 17..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation
import UIKit

class UPGamesListCell:UITableViewCell {
	
	var gameID:Int = -1
	var gameCheckImageView:UIImageView?
	var gameInfoObj:GameData?
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
	}
	
}
