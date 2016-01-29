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
    
    //기준에 대한 비율
    var scrRatio:Double = 1; var maxScrRatio:Double = 1; //최대가 1인 비율 크기
    
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
        
        naviItems.rightBarButtonItem = UIBarButtonItem(title: "닫기", style: .Plain, target: self, action: "viewCloseAction");
        naviItems.rightBarButtonItem?.tintColor = colorWithHexString("#FFFFFF");
        naviItems.title = "환경설정";
        navigation.items = [naviItems];
        navigation.frame = CGRectMake(0, 0, modalView.frame.width, CGFloat(42));
        modalView.addSubview(navigation);
        
        //add table to modal
        tableView.frame = CGRectMake(0, CGFloat(42), modalView.frame.width, modalView.frame.height - CGFloat(42));
        //stableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLineEtched; //구분선 제거.
        tableView.rowHeight = UITableViewAutomaticDimension;
        //tableView.in
        //tableView.indexPath
        modalView.addSubview(tableView);
        
        //add table cells (options)
        tablesArray = [
            [ /* SECTION 1 */
            /*createSettingsToggle("테스트", defaultState: false, settingsID: "test")
            , createSettingsToggle("대표 안 깨우기", defaultState: false, settingsID: "test2")*/
             createSettingsToggle("아이콘 배지 표시", defaultState: false, settingsID: "showIconBadge")
            , createSettingsToggle("iCloud 동기화 사용", defaultState: false, settingsID: "syncToiCloud")
            ],
            [ /* SECTION 2*/
                createSettingsOnlyLabel("시작 가이드", menuID: "startGuide")
                , createSettingsOnlyLabel("앱 평가하기", menuID: "ratingApplication")
                , createSettingsOnlyLabel("새로운 게임!", menuID: "newGame")
                , createSettingsOnlyLabel("AVNGraphic 바로가기", menuID: "gotoAVNGraphic")
            ]
            
        ];
        tableView.delegate = self; tableView.dataSource = self;
        tableView.backgroundColor = modalView.backgroundColor;
        
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
        
        
        //navigation.setTitleVerticalPositionAdjustment(CGFloat(6 * maxScrRatio), forBarMetrics: .Default);
        
    }
    
    //table touchevt
    func optionsTouchEventHandler(sender:UITapGestureRecognizer) {
        print("Touched");
        //print((sender.view as! CustomTableCell).cellID);
    }
    
    /// table setup
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
            case 0:
                return "일반 설정";
            case 1:
                return "도움말";
            default:
                return "-";
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tablesArray[section] as! Array<AnyObject>).count;
        
        /*if (section == 0) {
            return 1;
        } else {
            return 0;
        }*/
        //return tablesArray.count;
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
    func setupRatio( scR:Double, mScr:Double) {
        scrRatio = scR; maxScrRatio = mScr;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewCloseAction() {
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
        tCell.frame = CGRectMake(0, 0, self.modalView.frame.width, 45 /*CGFloat(45 * maxScrRatio)*/ );
        tCell.backgroundColor = colorWithHexString("#FFFFFF");
        
        
        //tSwitch.frame = CGRectMake(, , CGFloat(36 * maxScrRatio), CGFloat(24 * maxScrRatio));
        //tSwitch.transform = CGAffineTransformMakeScale(CGFloat(maxScrRatio), CGFloat(maxScrRatio));
        
        tSwitch.frame.origin.x = self.modalView.frame.width - tSwitch.frame.width - CGFloat(8);
        tSwitch.frame.origin.y = (tCell.frame.height - tSwitch.frame.height) / 2;
        tSwitch.selected = defaultState;
        
        tCell.addSubview(tLabel); tCell.addSubview(tSwitch);
        //tCell.d
        
        tLabel.text = name; //tLabel.font = UIFont(name: "", size: CGFloat(18 * maxScrRatio));
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