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
	
	var currentAccessory:UITableViewCellAccessoryType = .none;
	
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
		dottedArrowAccessory.isHidden = true; dottedCheckAccessory.isHidden = true;
	}
	
	
	override internal var accessoryType: UITableViewCellAccessoryType {
		get {
			return self.currentAccessory;
		}
		set {
			self.currentAccessory = newValue;
			
			//set frame of accessory
			dottedArrowAccessory.frame =
				CGRect( x: self.frame.width - (5.05 * 0.8) - 18, y: (self.frame.height / 2) - ((15.3 * 0.8) / 2), width: 10.1 * 0.8, height: 15.3 * 0.8 );
			dottedCheckAccessory.frame =
				CGRect( x: self.frame.width - (10.1 * 0.8) - 24, y: dottedArrowAccessory.frame.minY, width: 20.2 * 0.8, height: 15.3 * 0.8 );
			
			dottedArrowAccessory.isHidden = true; dottedCheckAccessory.isHidden = true;
			//update img
			switch(newValue) {
				case .disclosureIndicator:
					dottedArrowAccessory.isHidden = false;
					break;
				case .checkmark:
					dottedCheckAccessory.isHidden = false;
					break;
				case .none: break;
				default: break;
			} //end switch
		} //end set
		
	} //end func
	
}
