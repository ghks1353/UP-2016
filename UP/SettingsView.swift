//
//  SettingsView.swift
//  	
//
//  Created by ExFl on 2016. 1. 28..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//

import Foundation
import UIKit

class SettingsView:UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//Inner-modal view
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
    //Table for menu
    internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
    
    var settingsArray:Array<SettingsElement> = [];
    var tablesArray:Array<AnyObject> = [];
	
	//Background for iOS7 fallback
	var modalBackground:UIImageView?; var modalBackgroundBlackCover:UIView?;
	
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = .clearColor()
		
		//iOS7 fallback
		if #available(iOS 8.0, *) {
		} else {
			modalBackground = UIImageView(); modalBackgroundBlackCover = UIView();
			modalBackgroundBlackCover!.backgroundColor = UIColor.blackColor();
			modalBackgroundBlackCover!.alpha = 0.7;
			modalBackground!.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height);
			modalBackgroundBlackCover!.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height);
		} //End of iOS7 fallback
		
		//ModalView
        modalView.view.backgroundColor = UIColor.whiteColor();
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#333333");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("settingsMenu");
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Languages.$("generalClose"), style: .Plain, target: self, action: "viewCloseAction");
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
	
	}
	
	// iOS7 Background fallback
	override func viewDidAppear(animated: Bool) {
		if #available(iOS 8.0, *) {
		} else {
			modalBackground!.image = ViewController.viewSelf!.viewImage;
			modalBackgroundBlackCover!.removeFromSuperview(); modalBackground!.removeFromSuperview();
			self.view.addSubview(modalBackgroundBlackCover!); self.view.addSubview(modalBackground!);
			self.view.sendSubviewToBack(modalBackgroundBlackCover!); self.view.sendSubviewToBack(modalBackground!);
			modalBackgroundBlackCover!.alpha = 0;
			UIView.animateWithDuration(0.32, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
				self.modalBackgroundBlackCover!.alpha = 0.7;
				}, completion: nil);
		}
	} // iOS7 Background fallback end
	
	func setSwitchData(settingsID:String, value:Bool) {
		for (var i:Int = 0; i < settingsArray.count; ++i) {
			if (settingsArray[i].settingsID == settingsID) {
				(settingsArray[i].settingsElement as! UISwitch).on = true;
				print("Saved data is on:", settingsArray[i].settingsID);
				break;
			}
		} //end for
	}
	
	
	
    /// table setup
    
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
		if #available(iOS 8.0, *) {
			return UITableViewAutomaticDimension;
		} else {
			return 45;
		}
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (tablesArray[indexPath.section] as! Array<AnyObject>)[indexPath.row] as! UITableViewCell;
        return cell;
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 38;
    }
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true);
	}
    
    ////////////////
    
    func setupModalView(frame:CGRect) {
        modalView.view.frame = frame;
    }
	
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewCloseAction() {
		//Save changes
		//DataManager.initDefaults();
		for (var i:Int = 0; i < settingsArray.count; ++i) {
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
		
        //Close this view
		if (modalBackgroundBlackCover != nil) { //iOS7 Fallback (Should work on iOS7 only)
			modalBackgroundBlackCover!.removeFromSuperview(); modalBackground!.removeFromSuperview();
		}
		
		ViewController.viewSelf?.showHideBlurview(false);
        self.dismissViewControllerAnimated(true, completion: nil);
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
        
        
        //tSwitch.frame = CGRectMake(, , CGFloat(36 * maxDeviceGeneral.scrRatio), CGFloat(24 * maxDeviceGeneral.scrRatio));
        //tSwitch.transform = CGAffineTransformMakeScale(CGFloat(maxDeviceGeneral.scrRatio), CGFloat(maxDeviceGeneral.scrRatio));
        
        tSwitch.frame.origin.x = self.modalView.view.frame.width - tSwitch.frame.width - 8;
        tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
        //tSwitch.selected = defaultState;
        
        tCell.addSubview(tLabel); tCell.addSubview(tSwitch);
        //tCell.d
        
        tLabel.text = name; //tLabel.font = UIFont(name: "", size: CGFloat(18 * maxDeviceGeneral.scrRatio));
        tLabel.font = UIFont.systemFontOfSize(16);
        
        //tCell.selectionStyle = UITableViewCellSelectionStyle.None;
        //tCell.clipsToBounds = true;
        
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