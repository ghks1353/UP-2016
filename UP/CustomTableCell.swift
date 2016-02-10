//
//  CustomTableCell.swift
//  	
//
//  Created by ExFl on 2016. 1. 28..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class CustomTableCell:UITableViewCell {
    
    internal var cellID:String = "";
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch(self.cellID) {
            case "gotoAVNGraphic":
                UIApplication.sharedApplication().openURL(NSURL(string: "http://avngraphic.kr/")!);
            break;
            default:
            break;
        }
        
        print(self.cellID);
		super.touchesBegan(touches, withEvent: event);
    }
    
}