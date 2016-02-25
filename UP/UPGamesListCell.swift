//
//  UPGamesListCell.swift
//  UP
//
//  Created by ExFl on 2016. 2. 17..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class UPGamesListCell:UITableViewCell {
	
	internal var gameID:Int = -1;
	internal var gameCheckImageView:UIImageView?;
	internal var gameInfoObj:GameInfoObj?;
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesBegan(touches, withEvent: event);
	}
	
}