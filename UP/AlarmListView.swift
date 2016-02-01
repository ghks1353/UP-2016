//
//  AlarmListView.swift
//  	
//
//  Created by ExFl on 2016. 1. 30..
//  Copyright © 2016년 AVN Graphic. All rights reserved.
//


import Foundation
import UIKit

class AlarmListView:UIViewController /*, UITableViewDataSource, UITableViewDelegate*/ {
    
    //Inner-modal view
    var modalView:UIView = UIView();
    
    //Navigationbar view
    var navigation:UINavigationBar = UINavigationBar();
    //Table for menu
    var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
    var tablesArray:Array<AnyObject> = [];
	
	//Alarm-add view
	var modalAlarmAddView:AddAlarmView?;
	
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
        navigation.barTintColor = colorWithHexString("#4D9429");
        navigation.titleTextAttributes = titleDict as? [String : AnyObject];
        naviItems.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "alarmAddAction");
		//naviItems.leftBarButtonItem?.
		
        naviItems.rightBarButtonItem = UIBarButtonItem(title: Languages.$("generalClose"), style: .Plain, target: self, action: "viewCloseAction");
        naviItems.rightBarButtonItem?.tintColor = colorWithHexString("#FFFFFF");
        naviItems.leftBarButtonItem?.tintColor = colorWithHexString("#FFFFFF");
        naviItems.title = Languages.$("alarmList");
        navigation.items = [naviItems];
        navigation.frame = CGRectMake(0, 0, modalView.frame.width, 42);
        modalView.addSubview(navigation);
        
        //add table to modal
        tableView.frame = CGRectMake(0, 42, modalView.frame.width, modalView.frame.height - 42);
        tableView.rowHeight = UITableViewAutomaticDimension;
        modalView.addSubview(tableView);
        
        //add table cells (options)
        tablesArray = [
           
            
        ];
        /*tableView.delegate = self; tableView.dataSource = self;*/
        tableView.backgroundColor = modalView.backgroundColor;
		
		modalAlarmAddView = AddAlarmView();
		modalAlarmAddView!.setupModalView( getGeneralModalRect() );
		
    }
	
	func getGeneralModalRect() -> CGRect {
		return CGRectMake(CGFloat(50 * DeviceGeneral.scrRatio) , ((DeviceGeneral.scrSize?.height)! - CGFloat(480 * DeviceGeneral.scrRatio)) / 2 , (DeviceGeneral.scrSize?.width)! - CGFloat(100 * DeviceGeneral.scrRatio), CGFloat(480 * DeviceGeneral.scrRatio));
	}
	
    /// table setup
    /*
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return Languages.$("generalSettings");
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
    }*/
    
    ////////////////
    
    func setupModalView(frame:CGRect) {
        modalView.frame = frame;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alarmAddAction() {
        //Show alarm-add view
		//뷰는 단 하나의 추가 뷰만 present가 가능한 관계로..
		if #available(iOS 8.0, *) {
			modalAlarmAddView?.modalPresentationStyle = .OverFullScreen;
		} else {
			// Fallback on earlier versions
		};
		self.presentViewController(modalAlarmAddView!, animated: true, completion: nil);
		(modalAlarmAddView?.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = NSDate(); //date to current
    }
    
    func viewCloseAction() {
        //Close this view
        self.dismissViewControllerAnimated(true, completion: nil);
    }
	
	
	//Tableview cell view create
	func createAlarmListCell(name:String, defaultState:Bool, timeHour:Int, timeMin:Int, selectedGame:String, uuid:String ) -> UITableViewCell {
		//TODO-func 16.1.31 PM 11:50
		
		let tCell:UITableViewCell = UITableViewCell();
		let tLabel:UILabel = UILabel();
		let tSwitch:UISwitch = UISwitch();
		
		
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