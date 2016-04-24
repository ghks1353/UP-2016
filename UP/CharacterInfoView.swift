//
//  CharacterInfoView.swift
//  UP
//
//  Created by ExFl on 2016. 4. 9..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;

class CharacterInfoView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
	//Table for menu
	internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
	
	var tablesArray:Array<AnyObject> = [];
	
	override func viewDidLoad() {
		super.viewDidLoad();
		self.view.backgroundColor = .clearColor()
		
		//ModalView
		modalView.view.backgroundColor = UIColor.whiteColor();
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#333333");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("userCharacterInformation");
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(SettingsView.viewCloseAction));
		modalView.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor();
		self.view.addSubview(navigationCtrl.view);
		
		//add table to modal
		tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
		modalView.view.addSubview(tableView);
		
		//add table cells (options)
		tablesArray = [
			[ /* SECTION 1 */
				createCellWithNextArrow("testview", menuID: "test")
			]
			
		];
		tableView.delegate = self; tableView.dataSource = self;
		tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
		
		//get data from local (stat data)
		DataManager.initDefaults();
		
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		
		FitModalLocationToCenter();
	}
	
	
	/////// View transition animation
	override func viewWillAppear(animated: Bool) {
		//setup bounce animation
		self.view.alpha = 0;
	}
	override func viewDidAppear(animated: Bool) {
		//queue bounce animation
		self.view.frame = CGRectMake(0, DeviceGeneral.scrSize!.height,
		                             DeviceGeneral.scrSize!.width, DeviceGeneral.scrSize!.height);
		UIView.animateWithDuration(0.56, delay: 0, usingSpringWithDamping: 0.72, initialSpringVelocity: 1.5, options: .CurveEaseIn, animations: {
			self.view.frame = CGRectMake(0, 0,
				DeviceGeneral.scrSize!.width, DeviceGeneral.scrSize!.height);
			self.view.alpha = 1;
		}) { _ in
		}
	} ///////////////////////////////
	
	
	/// table setup
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1;
	}
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch(section) {
		default:
			return "";
		}
	} //end func
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (tablesArray[section] as! Array<AnyObject>).count;
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		//return UITableViewAutomaticDimension;
		switch(indexPath.section) {
		case 0:
			return 45;
		default:
			return UITableViewAutomaticDimension;
		}
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
		return cell;
	}
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		switch( section ) {
			default:
				return 38;
		}
		
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
	
	////////////////
	
	func setupModalView(frame:CGRect) {
		modalView.view.frame = frame;
	}
	func FitModalLocationToCenter() {
		navigationCtrl.view.frame.origin.x = DeviceGeneral.defaultModalSizeRect.minX;
		navigationCtrl.view.frame.origin.y = DeviceGeneral.defaultModalSizeRect.minY;
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func viewCloseAction() {
		ViewController.viewSelf!.showHideBlurview(false);
		self.dismissViewControllerAnimated(true, completion: nil);
	} //end close func
	
	
	func createCellWithNextArrow( name:String, menuID:String ) -> CustomTableCell {
		let tCell:CustomTableCell = CustomTableCell();
		let tLabel:UILabel = UILabel();
		
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRectMake(16, 0, self.modalView.view.frame.width, 45);
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45);
		tCell.backgroundColor = UIColor.whiteColor();
		
		tCell.addSubview(tLabel);
		tLabel.text = name;
		
		tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
		tLabel.font = UIFont.systemFontOfSize(16);
		
		return tCell;
	} //end func
	
}