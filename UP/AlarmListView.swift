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
	var modalView:UIViewController = UIViewController();
	//Navigationbar view
	var navigationCtrl:UINavigationController = UINavigationController();
	
    //Table for menu
    internal var tableView:UITableView = UITableView(frame: CGRectMake(0, 0, 0, 42), style: UITableViewStyle.Grouped);
    var tablesArray:Array<AnyObject> = [];
	
	//Alarm-add view
	var modalAlarmAddView:AddAlarmView = GlobalSubView.alarmAddView;
	
    override func viewDidLoad() {
        super.viewDidLoad();
        self.view.backgroundColor = .clearColor()
		
        //ModalView
        modalView.view.backgroundColor = UIColor.whiteColor();
		
		let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()];
		navigationCtrl = UINavigationController.init(rootViewController: modalView);
		navigationCtrl.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject];
		navigationCtrl.navigationBar.barTintColor = UPUtils.colorWithHexString("#4D9429");
		navigationCtrl.view.frame = modalView.view.frame;
		modalView.title = Languages.$("alarmList");
		modalView.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Languages.$("generalClose"), style: .Plain, target: self, action: "viewCloseAction");
		modalView.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "alarmAddAction");
		modalView.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor();
		modalView.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor();
		self.view.addSubview(navigationCtrl.view);
		
		
        
        //add table to modal
        tableView.frame = CGRectMake(0, 0, modalView.view.frame.width, modalView.view.frame.height);
        modalView.view.addSubview(tableView);
        
        //add table cells (options)
        tablesArray = [
           
            
        ];
        /*tableView.delegate = self; tableView.dataSource = self;*/
        tableView.backgroundColor = UPUtils.colorWithHexString("#FAFAFA");
		
		
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
        modalView.view.frame = frame;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alarmAddAction() {
        //Show alarm-add view
		//뷰는 단 하나의 추가 뷰만 present가 가능한 관계로..
		modalAlarmAddView.showBlur = false;
		
		if #available(iOS 8.0, *) {
			modalAlarmAddView.modalPresentationStyle = .OverFullScreen;
		} else {
			// Fallback on earlier versions
		};
		self.presentViewController(modalAlarmAddView, animated: true, completion: nil);
		(modalAlarmAddView.getElementFromTable("alarmDatePicker") as! UIDatePicker).date = NSDate(); //date to current
		modalAlarmAddView.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false); //scroll to top
		(modalAlarmAddView.getElementFromTable("alarmName") as! UITextField).text = ""; //empty alarm name
		modalAlarmAddView.setSoundElement(UPAlarmSoundLists.list[0]); //default - first element of soundlist
		modalAlarmAddView.resetAlarmRepeatCell();
		
    }
    
    func viewCloseAction() {
        //Close this view
		ViewController.viewSelf?.showHideBlurview(false);
        self.dismissViewControllerAnimated(true, completion: nil);
    }
	
	
	//Tableview cell view create
	func createAlarmListCell(name:String, defaultState:Bool, timeHour:Int, timeMin:Int, selectedGame:String, uuid:String ) -> UITableViewCell {
		//TODO-func 16.1.31 PM 11:50
		
		let tCell:UITableViewCell = UITableViewCell();
		let tLabel:UILabel = UILabel();
		let tSwitch:UISwitch = UISwitch();
		
		
		//해상도에 따라 작을수록 커져야하기때문에 ratio 곱을 뺌
		tLabel.frame = CGRectMake(16, 0, self.modalView.view.frame.width * 0.75, 45);
		tCell.frame = CGRectMake(0, 0, self.modalView.view.frame.width, 45 /*CGFloat(45 * maxDeviceGeneral.scrRatio)*/ );
		tCell.backgroundColor = UIColor.whiteColor();
		
		
		//tSwitch.frame = CGRectMake(, , CGFloat(36 * maxDeviceGeneral.scrRatio), CGFloat(24 * maxDeviceGeneral.scrRatio));
		//tSwitch.transform = CGAffineTransformMakeScale(CGFloat(maxDeviceGeneral.scrRatio), CGFloat(maxDeviceGeneral.scrRatio));
		
		tSwitch.frame.origin.x = self.modalView.view.frame.width - tSwitch.frame.width - CGFloat(8);
		tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
		tSwitch.selected = defaultState;
		
		tCell.addSubview(tLabel); tCell.addSubview(tSwitch);
		//tCell.d
		
		tLabel.text = name; //tLabel.font = UIFont(name: "", size: CGFloat(18 * maxDeviceGeneral.scrRatio));
		tLabel.font = UIFont.systemFontOfSize(16);
		
		//tCell.selectionStyle = UITableViewCellSelectionStyle.None;
		//tCell.clipsToBounds = true;
		
		return tCell;
	}

}