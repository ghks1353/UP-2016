//
//  UITableDottedCell.swift
//  UP
//
//  Created by ExFl on 2016. 4. 27..
//  Copyright © 2016년 Project UP. All rights reserved.
//

import Foundation;
import UIKit;

class UITableDottedCell:UITableViewCell {
	
	var currentAccessory:UITableViewCellAccessoryType = .None;
	
	//its override accessory
	var dottedArrowAccessory:UIImageView = UIImageView(image: UIImage( named: "comp-cell-arrow.png" ));
	var dottedCheckAccessory:UIImageView = UIImageView(image: UIImage( named: "comp-cell-check.png" ));
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!;
	}
	override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
		super.init(style: style, reuseIdentifier: reuseIdentifier);
		
		//init
		self.addSubview(dottedArrowAccessory); self.addSubview(dottedCheckAccessory);
		dottedArrowAccessory.hidden = true; dottedCheckAccessory.hidden = true;
	}
	
	
	override internal var accessoryType: UITableViewCellAccessoryType {
		get {
			return self.currentAccessory;
		}
		set {
			self.currentAccessory = newValue;
			
			//set frame of accessory
			dottedArrowAccessory.frame =
				CGRectMake( self.frame.width - (5.05 * 0.8) - 18, (self.frame.height / 2) - ((15.3 * 0.8) / 2), 10.1 * 0.8, 15.3 * 0.8 );
			dottedCheckAccessory.frame =
				CGRectMake( self.frame.width - (10.1 * 0.8) - 24, dottedArrowAccessory.frame.minY, 20.2 * 0.8, 15.3 * 0.8 );
			
			dottedArrowAccessory.hidden = true; dottedCheckAccessory.hidden = true;
			//update img
			switch(newValue) {
				case .DisclosureIndicator:
					dottedArrowAccessory.hidden = false;
					break;
				case .Checkmark:
					dottedCheckAccessory.hidden = false;
					break;
				case .None: break;
				default: break;
			} //end switch
		} //end set
		
	} //end func
	
}