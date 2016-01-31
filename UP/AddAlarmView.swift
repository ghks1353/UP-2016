//
//  AddAlarmView.swift
//  	
//
//  Created by ExFl on 2016. 1. 31..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//


import Foundation
import UIKit

class AddAlarmView:UIViewController /*, UITableViewDataSource, UITableViewDelegate*/ {
	
	//Inner-modal view
	var modalView:UIView = UIView();
	//Navigationbar view
	var navigation:UINavigationBar = UINavigationBar();
	
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor()
		
		//Background blur
		if #available(iOS 8.0, *) {
			let visuaEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light));
			visuaEffectView.frame = self.view.bounds
			visuaEffectView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight];
			visuaEffectView.translatesAutoresizingMaskIntoConstraints = true;
			self.view.addSubview(visuaEffectView);
		} else {
			// Fallback on earlier versions
		}
		
		//ModalView
		modalView.backgroundColor = colorWithHexString("#FAFAFA");
		self.view.addSubview(modalView);
		
		//Modal components in...
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		let naviItems:UINavigationItem = UINavigationItem();
		navigation.barTintColor = colorWithHexString("#1C6A94");
		navigation.titleTextAttributes = titleDict as? [String : AnyObject];
		naviItems.rightBarButtonItem = UIBarButtonItem(title: Languages.$("generalClose"), style: .Plain, target: self, action: "viewCloseAction");
		naviItems.rightBarButtonItem?.tintColor = colorWithHexString("#FFFFFF");
		naviItems.leftBarButtonItem?.tintColor = colorWithHexString("#FFFFFF");
		naviItems.title = Languages.$("addAlarm");
		navigation.items = [naviItems];
		navigation.frame = CGRectMake(0, 0, modalView.frame.width, 42);
		modalView.addSubview(navigation);
		
	}
	
	func setupModalView(frame:CGRect) {
		modalView.frame = frame;
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		//Close this view
		self.dismissViewControllerAnimated(true, completion: nil);
	}
	
	
	//////////////////comment
	
	func colorWithHexString (hex:String) -> UIColor {
		var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
		
		if (cString.hasPrefix("#")) {
			cString = (cString as NSString).substringFromIndex(1)
		}
		
		if (cString.characters.count != 6) {
			return UIColor.grayColor()
		}
		
		let rString = (cString as NSString).substringToIndex(2)
		let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
		let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
		
		var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
		NSScanner(string: rString).scanHexInt(&r)
		NSScanner(string: gString).scanHexInt(&g)
		NSScanner(string: bString).scanHexInt(&b)
		
		
		return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
	}
}