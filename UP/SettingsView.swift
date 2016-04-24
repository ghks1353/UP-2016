//
//  SettingsView.swift
//  	
//
//  Created by ExFl on 2016. 1. 28..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation;
import UIKit;
import QuartzCore;

class SettingsView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
    //Table for menu
    internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
    
    var settingsArray:Array<SettingsElement> = [];
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
		modalView.title = Languages.$("settingsMenu");
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: #selector(SettingsView.viewCloseAction));
		modalView.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor();
		self.view.addSubview(navigationCtrl.view);
		
        //add table to modal
        tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
        modalView.view.addSubview(tableView);
        
        //add table cells (options)
        tablesArray = [
            [ /* SECTION 1 */
             createSettingsToggle( Languages.$("settingsIconBadgeSetting") , defaultState: false, settingsID: "showIconBadge")
            , createSettingsToggle( Languages.$("settingsiCloud") , defaultState: false, settingsID: "syncToiCloud")
            ],
            [ /* SECTION 2*/
                createSettingsOnlyLabel( Languages.$("settingsStartingGuide") , menuID: "startGuide")
                , createSettingsOnlyLabel( Languages.$("settingsRatingApp") , menuID: "ratingApplication")
                , createSettingsOnlyLabel( Languages.$("settingsShowNewgame") , menuID: "newGame")
                , createSettingsOnlyLabel( Languages.$("settingsGotoAVN") , menuID: "gotoAVNGraphic")
            ]
            
        ];
        tableView.delegate = self; tableView.dataSource = self;
        tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
        
        //get data from local
		DataManager.initDefaults();
		var tmpOption:Bool = DataManager.nsDefaults.boolForKey(DataManager.settingsKeys.showBadge);
		if (tmpOption == true) { /* badge option is true? */
			setSwitchData("showIconBadge", value: true);
		}
		//icloud chk
		tmpOption = DataManager.nsDefaults.boolForKey(DataManager.settingsKeys.syncToiCloud);
		if (tmpOption == true) { /* icloud option is true? */
			setSwitchData("syncToiCloud", value: true);
		}
		
		//DISABLE AUTORESIZE
		self.view.autoresizesSubviews = false;
		//self.view.autoresizingMask = .None;
		
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
	
	func setSwitchData(settingsID:String, value:Bool) {
		for i:Int in 0 ..< settingsArray.count {
			if (settingsArray[i].settingsID == settingsID) {
				(settingsArray[i].settingsElement as! UISwitch).on = true;
				print("Saved data is on:", settingsArray[i].settingsID);
				break;
			}
		} //end for
		
		//saveChasngesToSystem();
	}
	
	
    /// table setup
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell:CustomTableCell = tableView.cellForRowAtIndexPath(indexPath) as! CustomTableCell;
		//element touch handler
		
		switch (cell.cellID) {
			case "gotoAVNGraphic":
				UIApplication.sharedApplication().openURL(NSURL(string: "http://avngraphic.kr/")!);
				break;
			default: break;
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	} //end func
	
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
            case 0:
                return Languages.$("generalSettings");
            case 1:
                return Languages.$("generalGuide");
            default:
                return "-";
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tablesArray[section] as! Array<AnyObject>).count;
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		return UITableViewAutomaticDimension;
		
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
        return cell;
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38;
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
		//Save changes
		saveChasngesToSystem();
		
		ViewController.viewSelf!.showHideBlurview(false);
        self.dismissViewControllerAnimated(true, completion: nil);
    }
	
	func saveChasngesToSystem() {
		for i:Int in 0 ..< settingsArray.count {
			switch(settingsArray[i].settingsID) {
				case "showIconBadge":
					DataManager.nsDefaults.setBool((settingsArray[i].settingsElement as! UISwitch).on, forKey: DataManager.settingsKeys.showBadge);
					break;
				case "syncToiCloud":
					DataManager.nsDefaults.setBool((settingsArray[i].settingsElement as! UISwitch).on, forKey: DataManager.settingsKeys.syncToiCloud);
					break;
				default: //잉어킹: 잉어.. 잉어!! 그러나 아무 일도 일어나지 않았다
					break;
			}
		}
		
		DataManager.nsDefaults.synchronize();
	}
	
	func switchChangedEvent( target:UISwitch ) {
		print("switch changed. saving.");
		saveChasngesToSystem();
	}
	
    //Tableview cell view create
    func createSettingsToggle(name:String, defaultState:Bool, settingsID:String ) -> CustomTableCell {
        let tCell:CustomTableCell = CustomTableCell();
        let tLabel:UILabel = UILabel();
        let tSwitch:UISwitch = UISwitch();
        
        let settingsObj:SettingsElement = SettingsElement();
        settingsObj.settingsID = settingsID; tCell.cellID = settingsID;
        settingsObj.settingsElement = tSwitch; //Anyobject
        
        //해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
        tLabel.frame = CGRectMake(16, 0, self.modalView.view.frame.width * 0.75, 45);
        tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45 /*CGFloat(45 * maxDeviceGeneral.scrRatio)*/ );
        tCell.backgroundColor = UIColor.whiteColor();
		
        tSwitch.frame.origin.x = self.modalView.view.frame.width - tSwitch.frame.width - 8;
        tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
        //tSwitch.selected = defaultState;
        
        tCell.addSubview(tLabel); tCell.addSubview(tSwitch);
		
		tSwitch.addTarget(self, action: #selector(SettingsView.switchChangedEvent(_:)), forControlEvents: .ValueChanged);
		
        tLabel.text = name;
		tLabel.font = UIFont.systemFontOfSize(16);
		
        //push to settingselement
        settingsArray += [settingsObj];
        
        return tCell;
    }
	
    func createSettingsOnlyLabel(name:String, menuID:String ) -> CustomTableCell {
        let tCell:CustomTableCell = CustomTableCell();
        let tLabel:UILabel = UILabel();
        
        let settingsObj:SettingsElement = SettingsElement();
        settingsObj.settingsID = menuID; tCell.cellID = menuID;
        settingsObj.settingsElement = nil; //Anyobject
        
        //해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
        tLabel.frame = CGRectMake(16, 0, self.modalView.view.frame.width, 45);
        tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45);
        tCell.backgroundColor = UIColor.whiteColor();
        
        tCell.addSubview(tLabel);
        tLabel.text = name;
        //tCell.selectionStyle = UITableViewCellSelectionStyle.None;
        tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
        tLabel.font = UIFont.systemFontOfSize(16);
        
        settingsArray += [settingsObj];
        
        return tCell;
    }
	
}