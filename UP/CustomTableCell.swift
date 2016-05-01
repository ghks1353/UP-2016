//
//  CustomTableCell.swift
//  	
//
//  Created by ExFl on 2016. 1. 28..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class CustomTableCell:UITableDottedCell {
    
    internal var cellID:String = "";
	
	//CellID를 가진 범용 커스텀 테이블셀
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		super.touchesBegan(touches, withEvent: event);
    }
}