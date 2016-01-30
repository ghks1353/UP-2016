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
    var modalView:UIView = UIView();
    
    //Navigationbar view
    var navigation:UINavigationBar = UINavigationBar();
    //Table for menu
    var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
    
    var settingsArray:Array<SettingsElement> = [];
    var tablesArray:Array<AnyObject> = [];
	
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = .clearColor()
        
        //Background blur
        let visuaEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visuaEffectView.frame = self.view.bounds
        visuaEffectView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight];
        visuaEffectView.translatesAutoresizingMaskIntoConstraints = true;
        self.view.addSubview(visuaEffectView);
        
        //ModalView
        modalView.backgroundColor = colorWithHexString("#FAFAFA");
        self.view.addSubview(modalView);
        
        //Modal components in...
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
        let naviItems:UINavigationItem = UINavigationItem();
        navigation.barTintColor = colorWithHexString("#333333");
        navigation.titleTextAttributes = titleDict as? [String : AnyObject];
        
        //let navUIButton:UIButton = UIButton();
        //navUIButton.
        
        naviItems.rightBarButtonItem = UIBarButtonItem(title: Languages.$("generalClose"), style: .Plain, target: self, action: "viewCloseAction");
        naviItems.rightBarButtonItem?.tintColor = colorWithHexString("#FFFFFF");
        naviItems.title = Languages.$("settingsMenu");
        navigation.items = [naviItems];
        navigation.frame = CGRectMake(0, 0, modalView.frame.width, CGFloat(42));
        modalView.addSubview(navigation);
        
        //add table to modal
        tableView.frame = CGRectMake(0, CGFloat(42), modalView.frame.width, modalView.frame.height - CGFloat(42));
        //stableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLineEtched; //구분선 제거.
        tableView.rowHeight = UITableViewAutomaticDimension;
        modalView.addSubview(tableView);
        
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
        tableView.backgroundColor = modalView.backgroundColor;
        
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
			
        //add touch listener each ele
        /*for (var i:Int = 0; i < settingsArray.count; ++i) {
            
        }*/
        /*for (var i:Int = 0; i < tablesArray.count; ++i) {
            for (var j:Int = 0; j < (tablesArray[i] as! Array<AnyObject>).count; ++j ) {
                let uTableCell:AnyObject = (tablesArray[i] as! Array<AnyObject>)[j]; //(tablesArray[i] as! Array<AnyObject>)[j] as! CustomTableCell; // as! UITableViewCell;
                let gestureEvtHandler:UITapGestureRecognizer = UITapGestureRecognizer(target: uTableCell, action: "optionsTouchEventHandler:");
                tableView.addGestureRecognizer(gestureEvtHandler);
                //(tablesArray[i][j] as! UITableViewCell).touchesBegan;
                
            }
        }*/
        
        
        //navigation.setTitleVerticalPositionAdjustment(CGFloat(6 * maxDeviceGeneral.scrRatio), forBarMetrics: .Default);
        
    }
	
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
        modalView.frame = frame;
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
        tLabel.frame = CGRectMake(16, 0, self.modalView.frame.width * 0.75, CGFloat(45));
        tCell.frame = CGRectMake(0, 0, self.modalView.frame.width, 45 /*CGFloat(45 * maxDeviceGeneral.scrRatio)*/ );
        tCell.backgroundColor = colorWithHexString("#FFFFFF");
        
        
        //tSwitch.frame = CGRectMake(, , CGFloat(36 * maxDeviceGeneral.scrRatio), CGFloat(24 * maxDeviceGeneral.scrRatio));
        //tSwitch.transform = CGAffineTransformMakeScale(CGFloat(maxDeviceGeneral.scrRatio), CGFloat(maxDeviceGeneral.scrRatio));
        
        tSwitch.frame.origin.x = self.modalView.frame.width - tSwitch.frame.width - CGFloat(8);
        tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
        tSwitch.selected = defaultState;
        
        tCell.addSubview(tLabel); tCell.addSubview(tSwitch);
        //tCell.d
        
        tLabel.text = name; //tLabel.font = UIFont(name: "", size: CGFloat(18 * maxDeviceGeneral.scrRatio));
        tLabel.font = UIFont.systemFontOfSize(16);
        
        tCell.selectionStyle = UITableViewCellSelectionStyle.None;
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
        tLabel.frame = CGRectMake(16, 0, self.modalView.frame.width, 45);
        tCell.frame = CGRectMake(0, 0, self.modalView.frame.width, 45);
        tCell.backgroundColor = colorWithHexString("#FFFFFF");
        
        tCell.addSubview(tLabel);
        tLabel.text = name;
        tCell.selectionStyle = UITableViewCellSelectionStyle.None;
        tCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator;
        tLabel.font = UIFont.systemFontOfSize(16);
        
        settingsArray += [settingsObj];
        
        return tCell;
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